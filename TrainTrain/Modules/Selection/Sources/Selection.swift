import SharedModels

struct Selection {

  var selectedLine: SubwayLine?
  var selectedStation: StationInfo?
  var directionStationID: String?

  var isSelectionCompleted: Bool {
    selectedLine != nil &&
    selectedStation != nil &&
    directionStationID != nil
  }

  mutating func removeAllSelction() {
    selectedLine = nil
    selectedStation = nil
    directionStationID = nil
  }
}
