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
}
