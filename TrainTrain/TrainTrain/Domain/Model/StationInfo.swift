import Foundation

struct StationInfo: Equatable {

  /// 지하철 호선 ID
  let subwayLineID: String
  /// 지하철역 ID
  let stationID: String
  /// 지하철역명
  let stationName: String
  /// 다음 지하철역명
  var nextStationName: String?
  /// 이전 지하철역명
  var previousStationName: String?

  init(subwayLineID: Any, stationID: Any, stationName: Any) {
    self.subwayLineID = "\(subwayLineID)"
    self.stationID = "\(stationID)"
    self.stationName = "\(stationName)" + "역"
  }

  init(subwayLineID: Any, stationID: Any, stationName: Any, nextStationName: String?, previousStationName: String?) {
    self.subwayLineID = "\(subwayLineID)"
    self.stationID = "\(stationID)"
    self.stationName = "\(stationName)"
    self.nextStationName = nextStationName
    self.previousStationName = previousStationName
  }

  /// plist 에 포함된 모든 노선의 지하철 역 정보의 배열
  static private let allStationList: [StationInfo] = {
    let path = Bundle.main.path(forResource: "StationList220622", ofType: "plist")!
    let arrOfDict = NSArray(contentsOfFile: path)! as! [[String: Any]]
    let stations = arrOfDict.map {
      StationInfo(
        subwayLineID: $0["SUBWAY_ID"]!,
        stationID: $0["STATN_ID"]!,
        stationName: $0["STATN_NM"]!)
    }
    return stations
  }()

  /// 특정 호선의 모든 역 정보를 배열 형태로 가져오기
  static func fetchStationList(of line: SubwayLine) -> [StationInfo] {
    Self.allStationList.filter { $0.subwayLineID == line.id }
  }
}
