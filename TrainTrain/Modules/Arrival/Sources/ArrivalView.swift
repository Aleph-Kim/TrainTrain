import ActivityKit
import SharedModels
import StationInfoClient
import SubwayInfoClient
import SwiftUI
import TTDesignSystem
import TTFoundation
import WidgetHelper

public struct ArrivalView: View {

  private let stationInfoClient: StationInfoClient
  private let subwayInfoClient: SubwayInfoClient

  @Binding var selectedStationInfo: StationInfo
  @Binding var directionStationID: String
  @Binding var selectedSubwayLine: SubwayLine
  @Environment(\.scenePhase) var scenePhase
  
  @State private var upcomingTrainInfos: [TrainInfo] = []
  @State private var upcomingTrainInfoETAs: [Int] = []
  
  private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  private let movingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  public init(
    stationInfoClient: StationInfoClient,
    subwayInfoClient: SubwayInfoClient,
    selectedStationInfo: Binding<StationInfo>,
    directionStationID: Binding<String>,
    selectedSubwayLine: Binding<SubwayLine>,
    upcomingTrainInfos: [TrainInfo] = [],
    upcomingTrainInfoETAs: [Int] = []
  ) {
    self.stationInfoClient = stationInfoClient
    self.subwayInfoClient = subwayInfoClient
    self._selectedStationInfo = selectedStationInfo
    self._directionStationID = directionStationID
    self._selectedSubwayLine = selectedSubwayLine
    self.upcomingTrainInfos = upcomingTrainInfos
    self.upcomingTrainInfoETAs = upcomingTrainInfoETAs
  }

  public var body: some View {
    let subwayLineColor: Color = selectedSubwayLine.color

    ZStack {
      backgroundView()

      VStack(spacing: .zero) {
        HStack {
          subwayLineIndicatorCircle(lineColor: subwayLineColor)
          stationName()
          Spacer()
          nextStationIndicator()
        }
        .padding()
        .padding(.bottom, 5)

        Spacer(minLength: 16)

        ZStack {
          strokedLine()
          goalLineWithCircle()
          trainProgressStack(of: upcomingTrainInfos)
        }
        .frame(height: 12)
        .padding(.horizontal)

        Spacer(minLength: 12)

        ZStack {
          secondaryBackgroundView()
          secondaryInformationView()
        }
      }
      .onReceive(timer) { _ in
        fetchSome()
      }
      .onChange(of: directionStationID) { _ in
        fetchAll()
      }
      .onChange(of: scenePhase) { newScenePhase in
        switch newScenePhase {
        case .active:
          fetchAll()
        case .background:
          if #available(iOS 16.1, *) { Task { await handleLiveActivity() } }
        default: return
        }
      }
    }
  }

  private func backgroundView() -> some View {
    let roundedRectangleCornerRadius: CGFloat = 20.0

    return RoundedRectangle(cornerRadius: roundedRectangleCornerRadius)
      .foregroundColor(.secondarySystemBackground)
  }

  private func subwayLineIndicatorCircle(lineColor: Color) -> some View {
    let borderWidth: CGFloat = 4.0
    let frameSize: CGFloat = 28.0
    let subwayLinePrefix = selectedSubwayLine.name.prefix(1)

    return Circle()
      .strokeBorder(lineWidth: borderWidth)
      .frame(width: frameSize, height: frameSize)
      .foregroundColor(lineColor)
      .overlay {
        Text(subwayLinePrefix)
          .font(.body)
          .fontWeight(.bold)
          .foregroundColor(.additionalGray4)
      }
  }

  private func stationName() -> some View {
    Text(selectedStationInfo.stationName)
      .font(.title3)
      .fontWeight(.bold)
      .foregroundColor(.additionalGray4)
  }

  private func nextStationIndicator() -> some View {
    let spacing: CGFloat = 2.0
    let horizontalPadding: CGFloat = 4.0
    let verticalPadding: CGFloat = 2.0
    let backgroundCornerRadius: CGFloat = 2.0

    return  HStack(spacing: spacing) {
      Text("다음역")
        .font(.footnote)

      let stationName = stationInfoClient.findStationName(from: directionStationID)
      Text(stationName)
        .font(.footnote)
        .fontWeight(.bold)
    }
    .foregroundColor(.additionalGray3)
    .padding(.horizontal, horizontalPadding)
    .padding(.vertical, verticalPadding)
    .background {
      RoundedRectangle(cornerRadius: backgroundCornerRadius)
        .foregroundColor(.systemGray5)
    }
  }

  private func strokedLine() -> some View {
    let lineWidth: CGFloat = 2.0
    let dash: [CGFloat] = [5.0]
    let dashPhase: CGFloat = 2.0
    let trailingPadding: CGFloat = 35.0
    let yOffset: CGFloat = 6.0

    return Line()
      .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: dash, dashPhase: dashPhase))
      .foregroundColor(.systemGray5)
      .padding(.trailing, trailingPadding)
      .offset(y: yOffset)
  }

  private func goalLineWithCircle() -> some View {
    let hStackSpacing: CGFloat = 4.0
    let strokeBorderLineWidth: CGFloat = 3.0
    let frameSize: CGFloat = 16.0
    let yOffset: CGFloat = -2.0
    let lineWidth: CGFloat = 2.0
    let lineFrameWidth: CGFloat = 12.0
    let lineYOffset: CGFloat = 6.0

    return HStack(spacing: hStackSpacing) {
      Spacer()
      Circle()
        .strokeBorder(lineWidth: strokeBorderLineWidth)
        .frame(width: frameSize, height: frameSize)
        .offset(y: yOffset)
        .foregroundColor(selectedSubwayLine.color)
      Line()
        .stroke(style: StrokeStyle(lineWidth: lineWidth))
        .foregroundColor(.systemGray5)
        .frame(width: lineFrameWidth)
        .offset(y: lineYOffset)
    }
  }

  private func trainProgressStack(of trainInfos: [TrainInfo]) -> some View {
    let trailingPadding: CGFloat = 16.0

    return ForEach(trainInfos) { trainInfo in
      TrainProgressView(
        trainInfo: trainInfo,
        targetStation: selectedStationInfo,
        directionStationID: directionStationID,
        subwayLineColor: selectedSubwayLine.color,
        movingTimer: movingTimer
      )
      .padding(.trailing, trailingPadding)
    }
  }

  private func secondaryBackgroundView() -> some View {
    let cornerRadius: CGFloat = 20.0
    
    return Rectangle()
      .cornerRadius(cornerRadius, corners: .bottomLeft)
      .cornerRadius(cornerRadius, corners: .bottomRight)
      .foregroundColor(.accessibleSystemGray6)
  }

  @ViewBuilder
  private func secondaryInformationView() -> some View {
    let hasSecondUpcomingTrain = (upcomingTrainInfoETAs[safe: 1] != nil)

    VStack(spacing: hasSecondUpcomingTrain ? 6 : .zero) {
      secondaryInformationMainTimerView()
      secondaryInformationSecondaryTimerView()
    }
    .padding(.vertical, 12)
  }

  func secondaryInformationMainTimerView() -> some View {
    VStack(spacing: .zero) {
      if let firstTrainETA = upcomingTrainInfoETAs[safe: 0] {
        if firstTrainETA >= 30 {
          HStack(spacing: 4) {
            Text("도착예정")
              .foregroundColor(.additionalGray5)
            Text(firstTrainETA.asClock)
              .fontWeight(.bold)
              .foregroundColor(.accessibleSystemIndigo)
              .onReceive(movingTimer) { timer in
                if firstTrainETA > 0 && upcomingTrainInfoETAs.isNotEmpty {
                  upcomingTrainInfoETAs[0] -= 1
                }
              }
            Text("후")
              .foregroundColor(.additionalGray5)
          }
          .font(.title2)
        } else {
          Text("곧 도착")
            .fontWeight(.bold)
            .foregroundColor(.accessibleSystemIndigo)
            .font(.title2)
        }
      } else {
        Text("도착예정 열차가 없습니다.")
          .font(.body)
          .foregroundColor(.additionalGray4)
      }
    }
  }

  @ViewBuilder
  func secondaryInformationSecondaryTimerView() -> some View {
    if let secondTrainETA = upcomingTrainInfoETAs[safe: 1] {
      HStack {
        Text("다음열차 약 \(secondTrainETA/60)분 후")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
    }
  }

  /// 실시간 열차의 배열에 새로운 열차를 append 하고, 떠난 열차는 remove 합니다.
  private func fetchSome() {
    Task {
      let newTrainInfos = try await subwayInfoClient.fetchTrainInfos(
        targetStation: selectedStationInfo,
        directionStationID: directionStationID)

      for newTrainInfo in newTrainInfos {
        appendTrainInfoIfNew(newTrainInfo)
        updateTrainInfoIfExists(newTrainInfo)
      }

      for oldTrainInfo in upcomingTrainInfos {
        removeTrainInfoIfDeparted(newTrainInfos: newTrainInfos, oldTrainInfo: oldTrainInfo)
      }

      upcomingTrainInfoETAs = filterAvailableETAs(from: upcomingTrainInfos)
    }

    @Sendable
    func appendTrainInfoIfNew(_ trainInfo: TrainInfo) {
      // id 가 일치하는 열차가 없으면서, 그 열차의 secondMessage 가 타겟역이 아닌 경우에만
      // 기존 열차 배열에 새로운 열차를 추가함
      let isNewTrain: Bool = upcomingTrainInfos
        .notContains(where: { $0.id == trainInfo.id || trainInfo.secondMessage == selectedStationInfo.stationName })

      if isNewTrain {
        upcomingTrainInfos.append(trainInfo)
      }
    }
    @Sendable
    func updateTrainInfoIfExists(_ trainInfo: TrainInfo) {
      let existingTrainIndex = upcomingTrainInfos.firstIndex(where: { $0.id == trainInfo.id })

      if let existingTrainIndex {
        upcomingTrainInfos[existingTrainIndex] = trainInfo
      }
    }
    @Sendable
    func removeTrainInfoIfDeparted(newTrainInfos: [TrainInfo], oldTrainInfo: TrainInfo) {
      // 기존 열차 배열에 존재했던 열차의 id 가, 새로운 열차 배열에서 사라졌다면
      // 기존 열차 배열에서 그 id 를 가진 열차를 삭제함 (이미 떠난 열차)
      let hasDeparted = newTrainInfos.notContains(where: { $0.id == oldTrainInfo.id })

      if hasDeparted {
        upcomingTrainInfos.removeAll(where: { $0.id == oldTrainInfo.id })
      }
    }
  }

  /// 실시간 열차의 배열을 전부 새롭게 갱신합니다.
  private func fetchAll() {
    Task {
      upcomingTrainInfos.removeAll()
      upcomingTrainInfoETAs.removeAll()
      upcomingTrainInfos = try await subwayInfoClient.fetchTrainInfos(
        targetStation: selectedStationInfo,
        directionStationID: directionStationID)
      upcomingTrainInfoETAs = filterAvailableETAs(from: upcomingTrainInfos)
    }
  }

  private func filterAvailableETAs(from trainInfos: [TrainInfo]) -> [Int] {
    return trainInfos
      .filter(\.isNotArrived)
      .compactMap { Int($0.eta) }
  }

  @available(iOS 16.1, *)
  private func handleLiveActivity() async {
    let availableETAs = filterAvailableETAs(from: upcomingTrainInfos)
    guard let eta = availableETAs[safe: 0] else { return }

    let attributes = TrainTrainWidgetAttributes()
    let contentState = TrainTrainWidgetAttributes.ContentState(
      eta: eta,
      selectedStationName: selectedStationInfo.stationName,
      directionStationName: stationInfoClient.findStationName(from: directionStationID),
      subwayLineName: String(selectedSubwayLine.name.prefix(1))
    )
    let existingActivities = Activity<TrainTrainWidgetAttributes>.activities
    let hasExistingActivity = existingActivities.isNotEmpty

    if hasExistingActivity {
      await updateActivity(existingActivities: existingActivities, contentState: contentState)
    } else {
      _ = createActivity(attributes: attributes, contentState: contentState)
    }
  }

  @available(iOS 16.1, *)
  private func updateActivity(
    existingActivities: [Activity<TrainTrainWidgetAttributes>],
    contentState: Activity<TrainTrainWidgetAttributes>.ContentState
  ) async {
    // Activity는 하나 이상 생성하지 않으므로 유일한 업데이트 대상임
    await existingActivities.first?.update(using: contentState)
  }

  @available(iOS 16.1, *)
  private func createActivity(
    attributes: TrainTrainWidgetAttributes,
    contentState: Activity<TrainTrainWidgetAttributes>.ContentState
  ) -> Activity<TrainTrainWidgetAttributes>? {
    do {
      return try Activity<TrainTrainWidgetAttributes>.request(
        attributes: attributes,
        contentState: contentState,
        pushType: nil
      )
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}

struct ArrivalView_Previews: PreviewProvider {
  static let stationInfoClient: StationInfoClient = .live()
  static let subwayInfoClient: SubwayInfoClient = .live(
    apiClient: .live(),
    stationInfoClient: stationInfoClient
  )

  static var previews: some View {
    let gangNam = stationInfoClient.findStationInfo(from: "1002000222")

    ArrivalView(
      stationInfoClient: stationInfoClient,
      subwayInfoClient: subwayInfoClient,
      selectedStationInfo: .constant(gangNam),
      directionStationID: .constant("1002000221"),
      selectedSubwayLine: .constant(.line2)
    )
  }
}
