import ActivityKit

public struct TrainTrainWidgetAttributes: ActivityAttributes {

  public init() {}

  public struct ContentState: Codable, Hashable {

    public init(
      eta: Int,
      selectedStationName: String,
      directionStationName: String,
      subwayLineName: String
    ) {
      self.eta = eta
      self.selectedStationName = selectedStationName
      self.directionStationName = directionStationName
      self.subwayLineName = subwayLineName
    }

    // 열차의 남은 시간은 동적이므로, 수정 가능한 방식으로 변경합니다.
    public var eta: Int
    public var selectedStationName: String
    public var directionStationName: String
    public var subwayLineName: String
  }
}
