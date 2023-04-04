//
//  SubwayAPI.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import Foundation

public enum SubwayAPI {
  /// [서울시 지하철 실시간 도착정보](https://data.seoul.go.kr/dataList/OA-12764/F/1/datasetView.do)
  case realTimeStationArrival(RealTimeStationArrival)

  /// 샘플 URL: http://swopenAPI.seoul.go.kr/api/subway/(인증키)/json/realtimeStationArrival/0/5/서울
  public struct RealTimeStationArrival {
    public let authKey: String
    public var startIndex: Int
    public var endIndex: Int
    public var stationName: String

    public init(
      authKey: String = "4448686271696d6f35337449787245",
      startIndex: Int = 0,
      endIndex: Int = 10,
      stationName: String
    ) {
      self.authKey = authKey
      self.startIndex = startIndex
      self.endIndex = endIndex
      self.stationName = stationName
    }
  }
}
