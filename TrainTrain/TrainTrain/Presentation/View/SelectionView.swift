import SwiftUI
import UIKit

struct SelectionView: View {

  @State private var selectionStep: SelectionStep = .pre
  @State private var selectedLine: SubwayLine? // 나중에 View 합쳐질 때 @Binding 으로 외부와 연결시킬 듯
  @State private var selectedStation: StationInfo?
  @State private var stationList: [StationInfo] = []
  @State private var searchText = ""

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
      .cornerRadius(16)
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
      .cornerRadius(16)
    }
    .padding(.horizontal)
  }

  // MARK: - stationSelectionPage
  private var stationSelectionPage: some View {
    VStack(spacing: 10) {
      HStack {
        if let selectedLine {
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

      VStack(spacing: .zero) {
        TextField("➡️ 탑승역 검색", text: $searchText)
          .textFieldStyle(.roundedBorder)
          .cornerRadius(10)
          .padding(.horizontal, 8)
          .padding(.top, 8)
          .submitLabel(.search)
          .onChange(of: searchText) { newValue in
            searchText = newValue.cleaned
          }

        List(searchText.isEmpty
             ? stationList
             : stationList.filter { $0.stationName.contains(searchText) }
             , id: \.stationID) { station in
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
          .listRowInsets(.init(top: .zero, leading: 7, bottom: .zero, trailing: 16))
        }
        .listStyle(.plain)
        .cornerRadius(10)
        .padding(8)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.quaternary)
      .background(selectedLine?.color)
      .cornerRadius(16)
    }
    .padding(.horizontal)
  }

  // MARK: - directionSelectionPage
  private var directionSelectionPage: some View {
    VStack(spacing: 10) {
      HStack {
        Text("어느 방향으로 가시나요?")
          .bold()
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(.quaternary)
          .clipShape(Capsule())
        Spacer()
      }

      HStack(spacing: .zero) {
        Button(action: { print("✅ \(previousStationName) 눌림!") }) {
          Text(previousStationName)
            .bold()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        Rectangle()
          .trim(from: 0, to: 0.5)
          .stroke(style: .init(lineWidth: 2, dash: [5]))
          .frame(width: 2)

        Button(action: { print("✅ \(nextStationName) 눌림!") }) {
          Text(nextStationName)
            .bold()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .font(.largeTitle)
      .foregroundColor(.white)
      .background(.quaternary)
      .background(selectedLine?.color)
      .cornerRadius(16)
      .overlay(alignment: .top) {
        Text(selectedStation?.stationName ?? "" + "역")
          .bold()
          .foregroundColor(.black)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(.white)
          .clipShape(Capsule())
          .offset(y: 24)
      }
    }
    .padding(.horizontal)
  }

  // MARK: - 이전(왼쪽) 역
  private var previousStationName: String {
    guard let selectedStation else { return "" }
    guard let index = stationList.firstIndex(where: { $0.stationID == selectedStation.stationID }) else { return "" }
    guard index < (stationList.count - 1) else { return "" }
    return stationList[index + 1].stationName
  }

  // MARK: - 다음(오른쪽) 역
  private var nextStationName: String {
    guard let selectedStation else { return "" }
    guard let index = stationList.firstIndex(where: { $0.stationID == selectedStation.stationID }) else { return "" }
    guard index > 0 else { return "" }
    return stationList[index - 1].stationName
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
