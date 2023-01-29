import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct TrainTrainWidgetLiveActivity: Widget {

  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TrainTrainWidgetAttributes.self) { context in
      let selectedStationName = context.state.selectedStationName
      let directionStationName = context.state.directionStationName
      let subwayLineName = Int(context.state.subwayLineName)

      VStack {
        if let lineColor = makeLineNumberToColor(lineNumber: subwayLineName),
           let subwayLineName {
          HStack {
            subwayLineIndicatorCircle(borderWidth: 4.0, lineNumber: subwayLineName, lineColor: lineColor)
            stationName(selectedStationName: selectedStationName)
            Spacer()
            nextStationIndicator(directionStationName: directionStationName)
          }
        }
        secondaryInformationView(eta: context.state.eta)
      }
      .padding()
      .activityBackgroundTint(.secondarySystemBackground)
      .activitySystemActionForegroundColor(Color.black)
    } dynamicIsland: { context in
      dynamicIsland(context: context)
    }
  }

  private func subwayLineIndicatorCircle(borderWidth: CGFloat, lineNumber: Int, lineColor: Color) -> some View {
    let frameSize: CGFloat = 25.0
    let subwayLinePrefix = String(lineNumber)

    return Circle()
      .strokeBorder(lineWidth: borderWidth)
      .frame(width: frameSize, height: frameSize)
      .foregroundColor(lineColor)
      .overlay {
        Text(subwayLinePrefix)
          .bold()
          .foregroundColor(.additionalGray4)
      }
  }

  private func stationName(selectedStationName: String) -> some View {
    Text(selectedStationName)
      .font(.title3)
      .bold()
      .foregroundColor(.additionalGray4)
  }

  private func nextStationIndicator(directionStationName: String) -> some View {
    let spacing: CGFloat = 2.0
    let fontSize: CGFloat = 13.0
    let horizontalPadding: CGFloat = 4.0
    let verticalPadding: CGFloat = 2.0
    let backgroundCornerRadius: CGFloat = 2.0

    return  HStack(spacing: spacing) {
      Text("다음역")
        .font(.system(size: fontSize))
      Text(directionStationName)
        .font(.system(size: fontSize))
        .bold()
    }
    .foregroundColor(.additionalGray3)
    .padding(.horizontal, horizontalPadding)
    .padding(.vertical, verticalPadding)
    .background {
      RoundedRectangle(cornerRadius: backgroundCornerRadius)
        .foregroundColor(.systemGray5)
    }
  }

  private func secondaryInformationView(eta: Int) -> some View {
    HStack {
      Text("도착예정")
        .foregroundColor(.additionalGray5)
      Text(timerInterval: Date.now...Date.now.addingTimeInterval(TimeInterval(eta)), countsDown: true)
        .bold()
        .foregroundColor(.accessibleSystemIndigo)
        .frame(width: 50)
      Text("후")
        .foregroundColor(.additionalGray5)
    }
    .font(.title2)
  }

  private func dynamicIsland(context: ActivityViewContext<TrainTrainWidgetAttributes>) -> DynamicIsland {
    let timer = Text(timerInterval: Date.now...Date.now.addingTimeInterval(TimeInterval(context.state.eta)), countsDown: true)
    let targetStationName = context.state.selectedStationName
    let subwayLineName = Int(context.state.subwayLineName)

    return DynamicIsland {
      DynamicIslandExpandedRegion(.leading) {
        makeTargetStationIndicator()
      }
      DynamicIslandExpandedRegion(.bottom) {
        secondaryInformationView(eta: context.state.eta)
      }
    } compactLeading: {
      makeTargetStationIndicator()
    } compactTrailing: {
      timer
        .frame(width: 40)
    } minimal: {
      timer
    }

    @ViewBuilder
    func makeTargetStationIndicator() -> some View {
      if let lineColor = makeLineNumberToColor(lineNumber: subwayLineName),
         let subwayLineName {
        HStack {
          subwayLineIndicatorCircle(borderWidth: 3.0, lineNumber: subwayLineName, lineColor: lineColor)
          stationName(selectedStationName: targetStationName)
        }
      }
    }
  }

  private func makeLineNumberToColor(lineNumber: Int?) -> Color? {
    switch lineNumber {
    case 1: return .line1
    case 2: return .line2
    case 3: return .line3
    case 4: return .line4
    case 5: return .line5
    case 6: return .line6
    case 7: return .line7
    case 8: return .line8
    case 9: return .line9
    default: return nil
    }
  }
}
