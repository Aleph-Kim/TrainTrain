//
//  TrainProgressView.swift
//  TrainTrain
//
//  Created by daco daco on 2022/10/09.
//

import SwiftUI

struct TrainProgressView: View {
    private let isMovingNow: Bool
    @State private var progressPercentage: CGFloat
    var arrivalState: TrainInfo.ArrivalState
    
    init(arrivalState: TrainInfo.ArrivalState) {
        self.arrivalState = arrivalState
        switch arrivalState {
        case .enter:
            progressPercentage = 0
            isMovingNow = true
        case .arrival:
            progressPercentage = 0.5
            isMovingNow = false
        case .depart:
            progressPercentage = 0.5
            isMovingNow = true
        default:
            progressPercentage = 0.5
            isMovingNow = false
        }
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Image(systemName: "train.side.middle.car")
                    .font(.system(size: 13))
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 13))
                Circle()
                    .frame(width: 5, height: 5)
                    .offset(CGSize(width: -3, height: 3))
                    .foregroundColor(.yellow)
                    .opacity(isMovingNow ? 1.0 : 0.0)
            }
            .offset(x: (progressPercentage * proxy.size.width) - 19.5, y: proxy.size.height - 13)
        }
        .onAppear {
            if arrivalState == .enter {
                progressPercentage = 0
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    if progressPercentage < 0.5 {
                        progressPercentage += 0.015
                    }
                }
            } else if arrivalState == .arrival {
                progressPercentage = 0.5
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    if progressPercentage <= 0.5 {
                        progressPercentage += 0.015
                    }
                }
            } else if arrivalState == .depart {
                progressPercentage = 0.5
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    if progressPercentage <= 1 {
                        progressPercentage += 0.015
                    }
                }
            }
        }
    }
}

// MARK: SwiftUI previews

struct TrainProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            HStack {
                TrainProgressView(arrivalState: .depart)
                    .foregroundColor(.white)
                    .padding(30)
                    .frame(width: 150, height: 160)
            }
        }
        
    }
}
