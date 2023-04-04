//
//  SubwayInfoClient.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import Foundation
import SubwayModels

public struct SubwayInfoClient {
  public var fetchTrainInfos: @Sendable (StationInfo?, String?) async throws -> [TrainInfo]

  public init(
    fetchTrainInfos: @Sendable @escaping (StationInfo?, String?) async throws -> [TrainInfo]
  ) {
    self.fetchTrainInfos = fetchTrainInfos
  }

  /// 특정 지하철역을 기준으로, 이전 지하철역에서 다가오는 열차들과, 특정 지하철역을 떠난 열차들의 리스트를 배열 형태로 가져옵니다.
  ///
  /// 특정 지하철역을 떠난 경우도 포괄하기 위해, ``fetch(targetStation:directionStationID:)`` 메서드 한 번으로
  /// 방금 떠난 열차들도 보여줄 수 있도록 만들었습니다.
  ///
  /// - Parameters:
  ///   - targetStation: 실시간 도착정보의 기준이 되는 지하철역 타입
  ///   - directionStationID: 진행하고자 하는 방향의 첫 번째 지하철역 ID
  ///
  /// - Returns: 실시간 도착정보의 배열
  public func fetchTrainInfos(targetStation: StationInfo?, directionStationID: String?) async throws -> [TrainInfo] {
      return try await self.fetchTrainInfos(targetStation, directionStationID)
  }
}
