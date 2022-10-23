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
  static let allStationList: [StationInfo] = {
    let path = Bundle.main.path(forResource: "StationList221023", ofType: "plist")!
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
    
  func makeThreeStationList() -> (Self, Self, Self) {
      /// 2호선 서울대입구역
      let dummy1 = StationInfo(
        subwayLineID: "1002",
        stationID: "1002000228",
        stationName: "서울대입구",
        nextStationName: "낙성대",
        previousStationName: "봉천")

      /// 2호선 봉천역
      let dummy2 = StationInfo(
        subwayLineID: "1002",
        stationID: "1002000229",
        stationName: "봉천",
        nextStationName: "서울대입구",
        previousStationName: "신림")

      /// 2호선 신림역
      let dummy3 = StationInfo(
        subwayLineID: "1002",
        stationID: "1002000230",
        stationName: "신림",
        nextStationName: "봉천",
        previousStationName: "신대방")
      
      return (dummy1, dummy2, dummy3)
  }
}
