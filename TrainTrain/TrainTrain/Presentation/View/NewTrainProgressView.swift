import SwiftUI

struct NewTrainProgressView: View {

  let trainInfo: TrainInfo

  var body: some View {
    Circle()
      .frame(width: 15, height: 15)
      .foregroundColor(.yellow)
  }
}

//struct NewTrainProgressView_Previews: PreviewProvider {
//  static var previews: some View {
//    NewTrainProgressView()
//  }
//}
