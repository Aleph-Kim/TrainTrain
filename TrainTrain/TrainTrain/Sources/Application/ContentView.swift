import SwiftUI

struct ContentView: View {

  private let stationInfoClient: StationInfoClient
  private let subwayClient: SubwayClient
  @State private var selectedStation: StationInfo
  @State private var directionStationID: String
  @State private var selectedSubwayLine: SubwayLine
  @FocusState private var isKeyboardUp: Bool
  
  private let arrivalViewHeight: CGFloat = 160
  
  init(
    stationInfoClient: StationInfoClient,
    subwayClient: SubwayClient,
    selectedStationID: String,
    directionStationID: String,
    subwayLine: SubwayLine
  ) {
    self.stationInfoClient = stationInfoClient
    self.subwayClient = subwayClient
    self.selectedStation = stationInfoClient.findStationInfo(from: selectedStationID)
    self.directionStationID = directionStationID
    self.selectedSubwayLine = subwayLine
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
    ArrivalView(
      stationInfoClient: stationInfoClient,
      subwayClient: subwayClient,
      selectedStationInfo: $selectedStation,
      directionStationID: $directionStationID,
      selectedSubwayLine: $selectedSubwayLine)
    .dynamicTypeSize(.medium)
    .frame(maxWidth: .infinity)
    .frame(height: arrivalViewHeight)
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
      stationInfoClient: stationInfoClient,
      selectedStation: $selectedStation,
      directionStationID: $directionStationID,
      selectedLine: $selectedSubwayLine,
      isKeyboardUp: _isKeyboardUp)
    .padding(.top)
    .padding(.bottom, 5)
    
    if !isKeyboardUp {
      noticeView()
    }
  }
  
  private func debugLogView() -> some View {
    ScrollView{
      DebugArrivalView(
        selectedStation: $selectedStation,
        directionStationID: $directionStationID,
        stationInfoClient: stationInfoClient,
        subwayClient: subwayClient)
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

// MARK: SwiftUI previews

struct ContentView_Previews: PreviewProvider {
  static let stationInfoClient: StationInfoClient = .live()
  static let subwayClient: SubwayClient = .live(
    apiClient: .live(),
    stationInfoClient: stationInfoClient
  )
  static var previews: some View {
    ContentView(
      stationInfoClient: stationInfoClient,
      subwayClient: subwayClient,
      selectedStationID: "1002000222",
      directionStationID: "1002000221",
      subwayLine: .line2)
  }
}
