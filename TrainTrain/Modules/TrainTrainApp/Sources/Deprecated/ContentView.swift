import Arrival
import ComposableArchitecture
import Selection
import SubwayModels
import StationInfoClient
import SubwayInfoClient
import SwiftUI
import UserDefaultsClient

@available(*, deprecated, renamed: "RealtimeStationArrivalView")
struct ContentView: View {

  private let stationInfoClient: StationInfoClient
  private let subwayInfoClient: SubwayInfoClient
  private let userDefaultsClient: UserDefaultsClient
  @State private var selectedStation: StationInfo
  @State private var directionStationID: String
  @State private var selectedSubwayLine: SubwayLine
  @FocusState private var isKeyboardUp: Bool

  init() {
    @Dependency(\.stationInfoClient) var stationInfoClient
    @Dependency(\.subwayInfoClient) var subwayInfoClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    self.stationInfoClient = stationInfoClient
    self.subwayInfoClient = subwayInfoClient
    self.userDefaultsClient = userDefaultsClient
    self.selectedStation = stationInfoClient.findStationInfo(from: userDefaultsClient.selectedStationID)
    self.directionStationID = userDefaultsClient.directionStationID
    self.selectedSubwayLine = SubwayLine(rawValue: userDefaultsClient.subwayLine) ?? .line2
  }

  var body: some View {
    VStack {
      upperSectionView()
        .onTapGesture {
          isKeyboardUp = false
        }

      lowerSectionView()
    }
  }

  @ViewBuilder
  private func upperSectionView() -> some View {
    ArrivalDashboardView(
      store: Store(
        initialState: ArrivalDashboardFeature.State(
          trainLane: TrainLaneFeature.State(
            trains: []
          ),
          etaSummary: ETASummaryFeature.State()
        ),
        reducer: ArrivalDashboardFeature()
      )
    )
    .dynamicTypeSize(.medium)
    .padding()

    #if DEBUG
    debugLogView()
    #endif

    Divider()
      .padding(.horizontal)
  }

  @ViewBuilder
  private func lowerSectionView() -> some View {
    SelectionView(
      store: Store(
        initialState: SelectionFeature.State(),
        reducer: SelectionFeature()
      )
    )
    .padding(.top)
    .padding(.bottom, 5)

    if !isKeyboardUp {
      noticeView()
    }
  }

  private func debugLogView() -> some View {
    ScrollView {
      DebugArrivalView(
        selectedStation: $selectedStation,
        directionStationID: $directionStationID,
        stationInfoClient: stationInfoClient,
        subwayInfoClient: subwayInfoClient)
    }
  }

  private func noticeView() -> some View {
    Group {
      Text("NOTICE")
        .font(.system(size: 12))
        .bold()
        .padding(.vertical, 5)
      Text("실시간 정보는 서울시만 제공하는 공공데이터로,")
      Text("서울을 제외한 지역의 실시간 정보는 아직 제공되지 않습니다.")
      Text("빠르게 타 지자체도 제공해주시기를 바라고 있습니다.🙏🏻")
    }
    .foregroundColor(.secondary)
    .font(.system(size: 10))
  }
}
