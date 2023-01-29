import ActivityKit

struct TrainTrainWidgetAttributes: ActivityAttributes {

  public struct ContentState: Codable, Hashable {
    // 열차의 남은 시간은 동적이므로, 수정 가능한 방식으로 변경합니다.
    var eta: Int
    var selectedStationName: String
    var directionStationName: String
    var subwayLineName: String
  }
}
