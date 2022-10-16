import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation: StationInfo?
    let dummy =  StationInfo(
        subwayLineID: "1002",
        stationID: "1002000228",
        stationName: "서울대입구",
        nextStationName: "낙성대",
        previousStationName: "봉천")

  var body: some View {
      
    ScrollView {
        if let selectedStation = selectedStation {
            ArrivalView(selectedStationInfo: selectedStation)
              .frame(maxWidth: .infinity)
              .frame(height: 200)
              .padding()
        } else {
            ArrivalView(selectedStationInfo: dummy)
              .frame(maxWidth: .infinity)
              .frame(height: 200)
              .padding()
        }
        
      SimplifiedArrivalView(
        selectedStation: $selectedStation)

      Divider()

      SelectionView(
        selectedStation: $selectedStation)
    }
  }
}

// MARK: SwiftUI previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
