//
//  SubwayAPIRoute.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import Foundation

extension SubwayAPI: APIRoutable {
  var baseURL: URL {
    return URL(string: "http://swopenAPI.seoul.go.kr/api/subway")!
  }

  var route: Route {
    switch self {
    case .realTimeStationArrival(let arrival):
      return .get("/\(arrival.authKey)/json/realtimeStationArrival/\(arrival.startIndex)/\(arrival.endIndex)/\(arrival.stationName)")
    }
  }

  var headers: [String: String]? {
    return nil
  }
}
