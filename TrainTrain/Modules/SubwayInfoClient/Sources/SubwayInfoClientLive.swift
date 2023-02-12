//
//  SubwayClientLive.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import APIClient
import SharedModels
import StationInfoClient

public extension SubwayInfoClient {
  static func live(
    apiClient: APIClient<SubwayAPI>,
    stationInfoClient: StationInfoClient
  ) -> Self {
    /// 특정 지하철역을 기준으로 접근하는 모든 방향의 실시간 도착정보를 배열 형태로 가져옵니다.
    @Sendable
    func fetch(stationID: String) async throws -> ArrivalInfo {
      let stationName = stationInfoClient.findStationName(from: stationID)

      return try await apiClient.request(
        .realTimeStationArrival(.init(stationName: stationName)),
        as: ArrivalInfo.self
      )
    }

    /// 목표역과 방향이 일치하면서 목표역에 근접한 열차를 제외한 열차 목록을 가져옵니다.
    /// 목표역에 근접한 열차를 제외하는 이유는 공공 데이터 API에서 제공하는 열차 목록이 역에 근접할수록 신뢰도가 낮아지기 때문입니다.
    /// - Parameters:
    ///   - targetStation: 목표역
    ///   - directionStationID: 방향역 ID
    /// - Throws: REST API 에러 응답
    /// - Returns: 목표역과 방향이 일치하면서 목표역에 근접한 열차를 제외한 열차 목록
    @Sendable
    func sameDirectionExceptApproachingTrainInfoList(
      targetStation: StationInfo,
      directionStationID: String
    ) async throws -> [TrainInfo] {
      let arrivalInfo = try await fetch(stationID: targetStation.stationID)
      let directionStationName = stationInfoClient.findStationName(from: directionStationID)
      let isSameDirection: (TrainInfo) -> Bool = { trainInfo in
        return trainInfo.trainDestination.contains(directionStationName)
      }
      let isNotAtTargetStation: (TrainInfo) -> Bool = { trainInfo in
        // 목표역 근처에서 정확도가 낮으므로 목표역에 있는 열차를 제외. 목표역 근처 열차는 nextList에서 획득한 열차를 사용
        return trainInfo.secondMessage != targetStation.stationName
      }
      return arrivalInfo.realtimeArrivalList
        .filter(isSameDirection)
        .filter(isNotAtTargetStation)
    }

    /// 목표역의 다음역에서 목표역에 근접한 열차 목록을 가져옵니다.
    /// - Parameters:
    ///   - targetStation: 목표역
    ///   - directionStationID: 방향역 ID
    /// - Throws: REST API 에러 응답
    /// - Returns: 목표역에 근접한 열차 목록
    @Sendable
    func approachingTrainInfoList(
      targetStation: StationInfo,
      directionStationID: String
    ) async throws -> [TrainInfo] {
      let nextInfo = try await fetch(stationID: directionStationID)
      let isNextStationOfTargetStation: (TrainInfo) -> Bool = { trainInfo in
        return (trainInfo.previousStationID == targetStation.stationID)
      }
      let hasArrivedStation: (TrainInfo) -> Bool = { trainInfo in
        return (trainInfo.arrivalState == .previousApproaching) ||
        (trainInfo.arrivalState == .previousArrived)
      }
      return nextInfo.realtimeArrivalList
        .filter(isNextStationOfTargetStation)
        .filter(hasArrivedStation)
        .map { TrainInfo(from: $0, eta: "0") } // 도착한 열차이므로 ETA는 0 (기존 ETA는 목표역 다음역에 도착하기까지의 ETA)
    }

    return Self(
      fetchTrainInfos: { targetStation, directionStationID in
        guard let targetStation, let directionStationID else { return [] }

        do {
          // 열차가 출발역에 도착하기 30초 이전 정도부터 정확도가 떨어지는 이슈가 있음
          // 따라서 같은 방향 열차 목록을 가져올 때 목표역에 근접한 열차는 제외함
          async let sameDirectionExceptApproachingTrainInfoList = sameDirectionExceptApproachingTrainInfoList(
            targetStation: targetStation,
            directionStationID: directionStationID
          )
          // 다음역에서 열차를 조회해 목표역인 전역 접근 정보로 목표역 접근 정보를 보완함
          async let approachingTrainInfoList = approachingTrainInfoList(
            targetStation: targetStation,
            directionStationID: directionStationID
          )
          return try await (sameDirectionExceptApproachingTrainInfoList + approachingTrainInfoList)
        } catch {
          print("⚠️ 통신 중 에러 발생 -> \(error)")
          return []
        }
      }
    )
  }
}
