import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation = StationInfo(
    subwayLineID: "1002",
    stationID: "1002000222",
    stationName: "강남",
    lowerStationID_1: "1002000223",
    lowerStationETA_1: 60,
    lowerStationID_2: "",
    lowerStationETA_2: "",
    upperStationID_1: "1002000221",
    upperStationETA_1: 60,
    upperStationID_2: "",
    upperStationETA_2: "")

  @State private var directionStationID: String = "1002000221"

  var body: some View {

    ScrollView {
      NewArrivalView(selectedStationInfo: $selectedStation, directionStationID: $directionStationID)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding()

//      ArrivalView(selectedStationInfo: $selectedStation, directionStationID: $directionStationID)
//        .frame(maxWidth: .infinity)
//        .frame(height: 200)
//        .padding()

      SimplifiedArrivalView(
        selectedStation: $selectedStation,
        directionStationID: $directionStationID)

      Divider()

      SelectionView(
        selectedStation: $selectedStation,
        directionStationID: $directionStationID)
    }
  }
}

// MARK: SwiftUI previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
