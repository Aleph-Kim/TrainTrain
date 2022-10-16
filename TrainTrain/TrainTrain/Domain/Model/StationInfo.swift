import Foundation

struct StationInfo {

  /// 지하철 호선 ID
  let subwayLineID: String
  /// 지하철역 ID
  let stationID: String
  /// 지하철역명
  let stationName: String
  /// 다음역 ID
  var nextStationID: String?
  /// 이전역 ID
  var previousStationID: String?

  init(subwayLineID: Any, stationID: Any, stationName: Any) {
    self.subwayLineID = "\(subwayLineID)"
    self.stationID = "\(stationID)"
    self.stationName = "\(stationName)" + "역"
  }

  init(subwayLineID: Any, stationID: Any, stationName: Any, nextStationID: String, previousStationID: String) {
    self.subwayLineID = "\(subwayLineID)"
    self.stationID = "\(stationID)"
    self.stationName = "\(stationName)" + "역"
    self.nextStationID = nextStationID
    self.previousStationID = previousStationID
  }
}
