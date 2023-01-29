import WidgetKit
import SwiftUI

@main
@available(iOS 16.1, *)
struct TrainTrainWidgetBundle: WidgetBundle {
    var body: some Widget {
//        일반적인 위젯으로, 추후 위젯을 구현 시 활용합니다.
//        TrainTrainWidget()
        TrainTrainWidgetLiveActivity()
    }
}
