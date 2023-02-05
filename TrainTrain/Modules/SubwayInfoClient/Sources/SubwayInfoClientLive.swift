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
    /// 특정 지하철역을 기준으로, 접근하는 모든 방향의 실시간 도착정보를 배열 형태로 가져옵니다.
    @Sendable
    func fetch(stationID: String) async throws -> ArrivalInfo {
      let stationName = stationInfoClient.findStationName(from: stationID)

      return try await apiClient.request(
        .realTimeStationArrival(.init(stationName: stationName)),
        as: ArrivalInfo.self
      )
    }

    return Self(
      fetchTrainInfos: { targetStation, directionStationID in
        guard let targetStation, let directionStationID else { return [] }

        do {
          async let arrivalInfo = fetch(stationID: targetStation.stationID)
          async let nextInfo = fetch(stationID: directionStationID)

          let filteredList = try await arrivalInfo.realtimeArrivalList.filter {
            $0.trainDestination.contains(stationInfoClient.findStationName(from: directionStationID))
              && $0.secondMessage != targetStation.stationName // 중복 방지
          }

          let nextList = try await nextInfo.realtimeArrivalList.filter {
            $0.previousStationID == targetStation.stationID
            && ($0.arrivalState == .previousArrived || $0.arrivalState == .previousApproaching)
          }

          return nextList + filteredList
        } catch {
          print("⚠️ 통신 중 에러 발생 -> \(error)")
          return []
        }
      }
    )
  }
}
