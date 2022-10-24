import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation: StationInfo?
  @State private var directionStationID: String?
  
  let placeHolder = StationInfo(
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

  var body: some View {

    ScrollView {
//      if let selectedStation, let directionStationID {
//        ArrivalView(selectedStationInfo: selectedStation, directionStationID: directionStationID)
//          .frame(maxWidth: .infinity)
//          .frame(height: 200)
//          .padding()
//      } else {
//        ArrivalView(selectedStationInfo: placeHolder, directionStationID: "1002000223")
//          .frame(maxWidth: .infinity)
//          .frame(height: 200)
//          .padding()
//      }

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
