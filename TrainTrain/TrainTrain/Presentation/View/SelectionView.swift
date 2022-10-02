import SwiftUI
import UIKit

struct SelectionView: View {

  @State private var selectionStep: SelectionStep = .pre
  @State private var selectedLine: SubwayLine? // 나중에 View 합쳐질 때 @Binding 으로 외부와 연결시킬 듯
  @State private var selectedStation: StationInfo?
  @State private var stationList: [StationInfo] = []

  // MARK: - body
  var body: some View {
    TabView(selection: $selectionStep) {
      preSelectionPage.tag(SelectionStep.pre)
//        .gesture(DragGesture())
      lineNumberSelectionPage.tag(SelectionStep.lineNumber)
//        .gesture(DragGesture())
      stationSelectionPage.tag(SelectionStep.station)
//        .gesture(DragGesture())
      directionSelectionPage.tag(SelectionStep.direction)
//        .gesture(DragGesture())
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4) // 화면 높이의 40% 사용
    .border(.red, width: 1)
  }

  // MARK: - preSelectionPage
  private var preSelectionPage: some View {
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

  // MARK: - lineNumberSelectionPage
  private var lineNumberSelectionPage: some View {
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

  // MARK: - stationSelectionPage
  private var stationSelectionPage: some View {
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

        Text("어느 역에서 탑승하시나요?")
          .bold()
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(.quaternary)
          .clipShape(Capsule())
        Spacer()
      }

      VStack {
        List(stationList, id: \.stationID) { station in
          Button {
            withAnimation {
              selectedStation = station
              selectionStep = .direction
            }
          } label: {
            HStack {
              Text(station.stationName + "역")
              Spacer()
              Image(systemName: "chevron.right")
                .fontWeight(.light)
            }
          }
        }
        .listStyle(.plain)
        .cornerRadius(20)
        .padding(10)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.quaternary)
      .background(selectedLine?.color)
      .cornerRadius(20)
    }
    .padding(.horizontal)
  }

  // MARK: - directionSelectionPage
  private var directionSelectionPage: some View {
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
    let filtered = stations.filter { $0.subwayLineID == line.id }
    return filtered
  }
}

fileprivate enum SelectionStep {
  case pre
  case lineNumber
  case station
  case direction
}

// 필요 없어지면 삭제할 예정! -- modifier 를 조건문에 따라 적용하기 위한 메서드임
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
