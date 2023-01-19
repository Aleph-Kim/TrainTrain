//
//  StationInfoClient.swift
//  TrainTrain
//
//  Created by Geonhee on 2023/01/14.
//

/// 역 정보를 제공하는 타입.
struct StationInfoClient {
  var stationList: (SubwayLine) -> [StationInfo]
  var findStationName: (String) -> String
  var findStationInfo: (String) -> StationInfo

  /// 특정 호선의 모든 역 정보를 반환합니다.
  /// - Parameter line: 호선
  /// - Returns: 특정 호선의 모든 역 정보
  func stationList(on line: SubwayLine) -> [StationInfo] {
    return stationList(line)
  }

  /// 역의 ID 를 통해 역의 이름을 찾습니다.
  /// - Parameter line: 호선
  /// - Returns: 역의 이름
  func findStationName(from stationID: String) -> String {
    return findStationName(stationID)
  }

  /// 역의 ID 를 통해 역의 정보를 찾습니다.
  /// - Parameter stationID: 역의 ID
  /// - Returns: 역의 정보
  func findStationInfo(from stationID: String) -> StationInfo {
    return findStationInfo(stationID)
  }
}
