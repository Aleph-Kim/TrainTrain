import SwiftUI

struct ContentView: View {
  
  @State private var selectedStation: StationInfo?

  var body: some View {
    ScrollView {
      ArrivalView()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding()
        
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
