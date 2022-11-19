import SwiftUI

struct NewArrivalView: View {

  @Binding var selectedStationInfo: StationInfo
  @Binding var directionStationID: String

  @State private var trainInfos: [TrainInfo] = []

  private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
  private let networkManager = NetworkManager()

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundColor(.black)

      Group {
        Capsule()
          .foregroundColor(.gray)
          .frame(height: 15)

        HStack {
          Circle()
            .frame(width: 15, height: 15)
            .foregroundColor(.white)

          Spacer()

          Circle()
            .frame(width: 15, height: 15)
            .foregroundColor(.white)
        }

        ForEach(trainInfos) { trainInfo in
          NewTrainProgressView(
            trainInfo: trainInfo,
            targetStation: selectedStationInfo,
            directionStationID: directionStationID)
        }
      }
      .frame(height: 15)
      .padding(.horizontal)
    }
    .onReceive(timer) { _ in
      Task {
        let newTrainInfos = await networkManager.fetch(
          targetStation: selectedStationInfo,
          directionStationID: directionStationID)
        
        for newTrainInfo in newTrainInfos {
          if !trainInfos.contains(where: {$0.id == newTrainInfo.id}) {
            trainInfos.append(newTrainInfo)
          }
        }
        
        for oldTrainInfo in trainInfos {
          if !newTrainInfos.contains(where: {$0.id == oldTrainInfo.id}) {
            trainInfos.removeAll(where: {$0.id == oldTrainInfo.id})
          }
        }
      }
    }
    .onAppear {
      Task {
        trainInfos = await networkManager.fetch(
          targetStation: selectedStationInfo,
          directionStationID: directionStationID)
        .filter {
          $0.secondMessage != selectedStationInfo.stationName
        }
      }
    }
  }
}

struct NewArrivalView_Previews: PreviewProvider {
  static var previews: some View {

    let gangNam = StationInfo(
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

    NewArrivalView(selectedStationInfo: .constant(gangNam), directionStationID: .constant("1002000221"))
  }
}
