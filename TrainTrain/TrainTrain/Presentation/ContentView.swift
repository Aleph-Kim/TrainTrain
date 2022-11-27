import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation: StationInfo
  @State private var directionStationID: String
  @FocusState private var isKeyboardUp: Bool
  
  init(selectedStationID: String, directionStationID: String) {
    self.selectedStation = StationInfo.findStationInfo(from: selectedStationID)
    self.directionStationID = directionStationID
  }
  
  var body: some View {
    VStack {
      Group {
        NewArrivalView(selectedStationInfo: $selectedStation, directionStationID: $directionStationID)
          .frame(maxWidth: .infinity)
          .frame(height: 160)
          .padding()

        #if DEBUG
          ScrollView{
            SimplifiedArrivalView(
              selectedStation: $selectedStation,
              directionStationID: $directionStationID)
          }
        #endif

        Divider()
          .padding(.horizontal)
      }
      .onTapGesture {
        isKeyboardUp = false
      }

      SelectionView(
        selectedStation: $selectedStation,
        directionStationID: $directionStationID,
        isKeyboardUp: _isKeyboardUp)
        .padding(.vertical)

      if !isKeyboardUp {
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
  }
}

// MARK: SwiftUI previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(selectedStationID: "1002000222", directionStationID: "1002000221")
  }
}
