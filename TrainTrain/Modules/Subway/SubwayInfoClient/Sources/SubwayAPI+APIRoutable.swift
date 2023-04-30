//
//  SubwayAPIRoute.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import APIClient
import Foundation

extension SubwayAPI: APIRoutable {
  public var baseURL: URL {
    return URL(string: "http://swopenAPI.seoul.go.kr/api/subway")!
  }

  public var route: Route {
    switch self {
    case .realtimeStationArrival(let arrival):
      return .get("/\(arrival.authKey)/json/realtimeStationArrival/\(arrival.startIndex)/\(arrival.endIndex)/\(arrival.stationName)")
    }
  }

  public var headers: [String: String]? {
    return nil
  }
}
