import SwiftUI

struct NewTrainProgressView: View {

  let trainInfo: TrainInfo

  var body: some View {
    Circle()
      .frame(width: 15, height: 15)
      .foregroundColor(.yellow)
  }
}

struct NewTrainProgressView_Previews: PreviewProvider {
  static var previews: some View {

    let mock = TrainInfo(
      subwayLineID: "1002",
      trainDestination: "성수행 - 역삼방면",
      previousStationID: "1002000223",
      nextStationID: "1002000221",
      stationID: "1002000222",
      stationName: "강남",
      trainType: TrainType.normal,
      eta: "119",
      terminusStationID: "88",
      terminusStationName: "성수",
      createdAt: "2022-11-19 16:12:40.0",
      firstMessage: "전역 도착",
      secondMessage: "교대",
      arrivalState: TrainInfo.ArrivalState.previousArrived,
      id: "3245")

    NewTrainProgressView(trainInfo: mock)
  }
}
