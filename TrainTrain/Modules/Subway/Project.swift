import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
  name: "Subway",
  targetConfigurations: [
    TargetConfiguration(
      name: "Arrival",
      targetTypes: [],
      productType: .staticLibrary,
      dependencies: [
        .target(name: "SubwayInfoClient"),
        .target(name: "WidgetHelper"),
        .project(target: "TTFoundation", path: "../Platform"),
      ]
    ),
    TargetConfiguration(
      name: "Selection",
      targetTypes: [],
      productType: .staticLibrary,
      dependencies: [
        .target(name: "StationInfoClient"),
        .project(target: "UserDefaultsClient", path: "../Platform"),
        .external(name: "ConfettiSwiftUI"),
      ]
    ),
    TargetConfiguration(
      name: "StationInfoClient",
      targetTypes: [],
      productType: .framework,
      resources: [
        "StationList221023.plist",
      ],
      dependencies: [
        .target(name: "SubwayModels"),
      ]
    ),
    TargetConfiguration(
      name: "SubwayInfoClient",
      targetTypes: [],
      productType: .framework,
      dependencies: [
        .target(name: "StationInfoClient"),
        .project(target: "APIClient", path: "../Platform"),
      ]
    ),
    TargetConfiguration(
      name: "SubwayModels",
      targetTypes: [],
      productType: .framework,
      dependencies: []
    ),
    TargetConfiguration(
      name: "WidgetHelper",
      targetTypes: [],
      productType: .framework,
      dependencies: [
        .project(target: "TTDesignSystem", path: "../TTDesignSystem"),
      ]
    ),
  ],
  packages: [],
  additionalFiles: []
)
