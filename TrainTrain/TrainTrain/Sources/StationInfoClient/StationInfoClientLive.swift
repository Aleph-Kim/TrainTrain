//
//  StationInfoClientLive.swift
//  TrainTrain
//
//  Created by Geonhee on 2023/01/14.
//

import Foundation

extension StationInfoClient {
  static func live(bundle: Bundle = .main) -> Self {
    /// plist 에 포함된 모든 노선의 지하철 역 정보
    let allStationList: [StationInfo] = {
      let path = bundle.path(forResource: "StationList221023", ofType: "plist")!
      let arrOfDict = NSArray(contentsOfFile: path)! as! [[String: Any]]
      let stations = arrOfDict.map {
        StationInfo(
          subwayLineID: $0["SUBWAY_ID"]!,
          stationID: $0["STATN_ID"]!,
          stationName: $0["STATN_NM"]!,
          lowerStationID_1: $0["LOWER_STATN_ID_1"]!,
          lowerStationETA_1: $0["LOWER_STATN_ETA_1"]!,
          lowerStationID_2: $0["LOWER_STATN_ID_2"]!,
          lowerStationETA_2: $0["LOWER_STATN_ETA_2"]!,
          upperStationID_1: $0["UPPER_STATN_ID_1"]!,
          upperStationETA_1: $0["UPPER_STATN_ETA_1"]!,
          upperStationID_2: $0["UPPER_STATN_ID_2"]!,
          upperStationETA_2: $0["UPPER_STATN_ETA_2"]!
        )
      }
      return stations
    }()

    return Self(
      stationList: { subwayLine in
        return allStationList.filter { $0.subwayLineID == subwayLine.id }
      },
      findStationName: { stationID in
        return allStationList.first(where: { $0.stationID == stationID })?.stationName ?? ""
      },
      findStationInfo: { stationID in
        return allStationList.first(where: { $0.stationID == stationID })!
      }
    )
  }
}
