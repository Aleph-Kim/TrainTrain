import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation: StationInfo?
  @State private var directionStationID: String?
  
  let placeHolder = StationInfo(subwayLineID: "1002",
                                stationID: "1002000222",
                                stationName: "강남",
                                lowerStationID_1: "1002000223",
                                lowerStationETA_1: 60,
                                lowerStationID_2: nil,
                                lowerStationETA_2: nil,
                                upperStationID_1: "1002000221",
                                upperStationETA_1: 60,
                                upperStationID_2: nil,
                                upperStationETA_2: nil)

  var body: some View {
      
    ScrollView {
        if let selectedStation, let directionStationID {
            ArrivalView(selectedStationInfo: selectedStation, directionStationID: directionStationID)
              .frame(maxWidth: .infinity)
              .frame(height: 200)
              .padding()
        } else {
            ArrivalView(selectedStationInfo: placeHolder, directionStationID: "1002000223")
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
