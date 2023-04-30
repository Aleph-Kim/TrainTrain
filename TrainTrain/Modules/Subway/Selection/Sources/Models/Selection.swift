import SubwayModels

public struct Selection: Equatable {

  public var selectedLine: SubwayLine?
  public var selectedStation: StationInfo?
  public var directionStationID: String?

  public init(
    selectedLine: SubwayLine? = nil,
    selectedStation: StationInfo? = nil,
    directionStationID: String? = nil
  ) {
    self.selectedLine = selectedLine
    self.selectedStation = selectedStation
    self.directionStationID = directionStationID
  }

  var isSelectionCompleted: Bool {
    selectedLine != nil &&
    selectedStation != nil &&
    directionStationID != nil
  }

  mutating func removeAllSelection() {
    selectedLine = nil
    selectedStation = nil
    directionStationID = nil
  }
}
