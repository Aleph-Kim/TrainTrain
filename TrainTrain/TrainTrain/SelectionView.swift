import SwiftUI
import UIKit

struct SelectionView: View {

  @State private var selectionStep: SelectionStep = .one

  var body: some View {
    TabView(selection: $selectionStep) {
      page1
      page2
      page3
    }
    .tabViewStyle(.page(indexDisplayMode: .always))
    .frame(maxWidth: .infinity, maxHeight: 400)
    .border(.red, width: 1)
    .onAppear {
      UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.primary)
      UIPageControl.appearance().pageIndicatorTintColor = UIColor(.secondary)
    }
  }

  var page1: some View {
    VStack(spacing: 12) {
      HStack {
        Text("몇 호선 인가요?")
          .font(.title3.bold())
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
            Button(action: { print("\(line.rawValue) 호선 선택") }) {
              Capsule()
                .fill(line.color)
                .frame(height: 42)
                .overlay(alignment: .leading) {
                  Text("\(line.rawValue) 호선")
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

  var page2: some View {
    Text("Page 2")
      .tag(SelectionStep.two)
  }

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
