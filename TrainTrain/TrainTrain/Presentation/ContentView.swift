import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation: StationInfo
  @State private var directionStationID: String
  
  init(selectedStationID: String, directionStationID: String) {
    self.selectedStation = StationInfo.findStationInfo(from: selectedStationID)
    self.directionStationID = directionStationID
  }
  
  var body: some View {
    
    NewArrivalView(selectedStationInfo: $selectedStation, directionStationID: $directionStationID)
      .frame(maxWidth: .infinity)
      .frame(height: 200)
      .padding()
    
#if DEBUG
    ScrollView{
      SimplifiedArrivalView(
        selectedStation: $selectedStation,
        directionStationID: $directionStationID)
    }
#endif
    
    Divider()
    
    SelectionView(
      selectedStation: $selectedStation,
      directionStationID: $directionStationID)
  }
}

// MARK: SwiftUI previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(selectedStationID: "1002000222", directionStationID: "1002000221")
  }
}
