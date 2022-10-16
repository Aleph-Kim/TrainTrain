import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation: StationInfo?
  @State private var selectedDirection: String? // "OO방면"

  var body: some View {
    ScrollView {
      ArrivalView()
            .frame(width: 350, height: 200)
            .padding()
        
      SimplifiedArrivalView(
        selectedStation: $selectedStation,
        selectedDirection: $selectedDirection)

      Divider()

      SelectionView(
        selectedStation: $selectedStation,
        selectedDirection: $selectedDirection)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
