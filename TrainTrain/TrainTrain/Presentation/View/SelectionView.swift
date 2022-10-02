import SwiftUI
import UIKit

struct SelectionView: View {

  @State private var selectionStep: SelectionStep = .preSelection
  @State private var selectedLine: SubwayLine? // 나중에 View 합쳐질 때 @Binding 으로 외부와 연결시킬 듯
  @State private var selectedStation: StationInfo?
  @State private var stationList: [StationInfo] = []

  // MARK: - body
  var body: some View {
    TabView(selection: $selectionStep) {
      page1.tag(SelectionStep.preSelection)
//        .gesture(DragGesture())
      page2.tag(SelectionStep.lineNumber)
//        .gesture(DragGesture())
      page3.tag(SelectionStep.station)
//        .gesture(DragGesture())
      page4.tag(SelectionStep.direction)
//        .gesture(DragGesture())
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4) // 화면 높이의 40% 사용
  }

  // MARK: - page1
  private var page1: some View {
    VStack(spacing: 10) {
      HStack {
        Text("Pre Selection Page")
          .bold()
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(.quaternary)
          .clipShape(Capsule())
        Spacer()
      }

      VStack {
        Button("시작하기") {
          withAnimation {
            selectionStep = .lineNumber
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.quaternary)
      .cornerRadius(20)
    }
    .padding(.horizontal)
  }

  // MARK: - page2
  private var page2: some View {
    VStack(spacing: 10) {
      HStack {
        Text("몇 호선 인가요?")
          .bold()
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(.quaternary)
          .clipShape(Capsule())
        Spacer()
      }

      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 20) {
          ForEach(SubwayLine.allCases) { line in
            Button {
              withAnimation {
                selectedLine = line
                selectionStep = .station
                stationList = fetchStationList(of: line)
              }
            } label: {
              Capsule()
                .fill(line.color)
                .frame(height: 42)
                .overlay(alignment: .leading) {
                  Text(line.rawValue)
                    .foregroundColor(.black)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white)
                    .clipShape(Capsule())
                    .padding(.leading, 10)
                }
                .padding(.leading, 20)
            }
          }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .background(.quaternary)
      .cornerRadius(20)
    }
    .padding(.horizontal)
  }

  // MARK: - page3
  private var page3: some View {
    VStack(spacing: 10) {
      HStack {
        if let selectedLine = selectedLine {
          Text(selectedLine.rawValue)
            .bold()
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
              Capsule()
                .inset(by: 2)
                .stroke(selectedLine.color, lineWidth: 2)
            )
        }

        Text("어느 역인가요?")
          .bold()
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(.quaternary)
          .clipShape(Capsule())
        Spacer()
      }

      VStack {
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.quaternary)
      .background(selectedLine?.color)
      .cornerRadius(20)
    }
    .padding(.horizontal)
  }

  // MARK: - page4
  private var page4: some View {
    Text("Page 4")
  }

  // MARK: - 역정보 가져오기
  private func fetchStationList(of line: SubwayLine) -> [StationInfo] {
    let path = Bundle.main.path(forResource: "StationList220622", ofType: "plist")!
    let arrOfDict = NSArray(contentsOfFile: path)! as! [[String: Any]]
    let stations = arrOfDict.map {
      StationInfo(
        subwayLineID: $0["SUBWAY_ID"]!,
        stationID: $0["STATN_ID"]!,
        stationName: $0["STATN_NM"]!)
    }
    let filtered = stations.filter { $0.stationID == line.id }
    return filtered
  }
}

fileprivate enum SelectionStep {
  case preSelection
  case lineNumber
  case station
  case direction
}

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

struct SelectionView_Previews: PreviewProvider {
  static var previews: some View {
    SelectionView()
  }
}
