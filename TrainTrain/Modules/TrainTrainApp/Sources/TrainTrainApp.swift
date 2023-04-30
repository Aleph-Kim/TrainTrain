import ComposableArchitecture
import SwiftUI

@main
struct TrainTrainApp: App {

  var body: some Scene {
    WindowGroup {
      RealtimeStationArrivalView(
        store: Store(
          initialState: RealtimeStationArrivalFeature.State(),
          reducer: RealtimeStationArrivalFeature()
        )
      )
    }
  }
}
