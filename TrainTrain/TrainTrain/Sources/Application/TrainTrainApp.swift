import SwiftUI

 @main
struct TrainTrainApp: App {
  /// MARK: UserDefaults - 강남역의 ID 로 시작
  @AppStorage("selectedStationID") private var selectedStationID: String = "1002000222"

  /// MARK: UseDefaults - 역삼역의 ID 로 시작
  @AppStorage("directionStationID") private var directionStationID: String = "1002000221"

  /// MARK: UseDefaults - 2호선으로 시작
  @AppStorage("subwayLine") private var subwayLine: SubwayLine = .line2

  var body: some Scene {
    WindowGroup {
      ContentView(
        selectedStationID: selectedStationID,
        directionStationID: directionStationID,
        subwayLine: subwayLine)
    }
  }
}
