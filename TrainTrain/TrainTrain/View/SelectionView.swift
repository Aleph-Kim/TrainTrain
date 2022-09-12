import SwiftUI
import UIKit

struct SelectionView: View {

  @State private var selectionStep: SelectionStep = .one
  @State private var selectedLine: SubwayLine? // 나중에 View 합쳐질 때 @Binding 으로 외부와 연결시킬 듯

  // MARK: - body
  var body: some View {
    TabView(selection: $selectionStep) {
      page1
      page2
      page3
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4) // 화면 높이의 40% 사용
//    .onAppear {
//      UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.primary)
//      UIPageControl.appearance().pageIndicatorTintColor = UIColor(.secondary)
//    }
  }

  // MARK: - page1
  var page1: some View {
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
          Spacer(minLength: 5)
          ForEach(SubwayLine.allCases) { line in
            Button {
              withAnimation {
                print("🚂 \(line.rawValue) 선택")
                selectedLine = line
                selectionStep = .two
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
          Spacer(minLength: 5)
        }
        .frame(maxWidth: .infinity)
      }
      .background(.quaternary)
      .cornerRadius(20)
    }
    .tag(SelectionStep.one)
    .padding(.horizontal)
  }

  // MARK: - page2
  var page2: some View {
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
        VStack {
          Spacer()
        }
        .frame(maxWidth: .infinity)
      }
      .background(.quaternary)
      .background(selectedLine?.color)
      .cornerRadius(20)
    }
    .tag(SelectionStep.two)
    .padding(.horizontal)
  }

  // MARK: - page3
  var page3: some View {
    Text("Page 3")
      .tag(SelectionStep.three)
  }
}

struct SelectionView_Previews: PreviewProvider {
  static var previews: some View {
    SelectionView()
  }
}
