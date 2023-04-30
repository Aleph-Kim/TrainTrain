//
//  Dependencies.swift
//  Config
//
//  Created by Geonhee on 2023/03/18.
//

import ProjectDescription

let dependencies = Dependencies(
  carthage: nil,
  swiftPackageManager: SwiftPackageManagerDependencies([
    .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .branch("prerelease/1.0")),
    .remote(url: "https://github.com/simibac/ConfettiSwiftUI", requirement: .upToNextMajor(from: "1.0.1")),
  ]),
  platforms: [.iOS]
)
