import APIClient
import SubwayModels
import StationInfoClient
import SubwayInfoClient
import SwiftUI
import UserDefaultsClient

@main
struct TrainTrainApp: App {

  private let userDefaultsManager: UserDefaultsManager
  private let stationInfoClient: StationInfoClient
  private let subwayInfoClient: SubwayInfoClient

  init() {
    self.userDefaultsManager = UserDefaultsManager()
    self.stationInfoClient = .live()
    self.subwayInfoClient = .live(
      apiClient: .live(session: .shared),
      stationInfoClient: stationInfoClient
    )
  }

  var body: some Scene {
    WindowGroup {
      ContentView(
        stationInfoClient: stationInfoClient,
        subwayInfoClient: subwayInfoClient,
        userDefaultsManager: userDefaultsManager
      )
    }
  }
}
