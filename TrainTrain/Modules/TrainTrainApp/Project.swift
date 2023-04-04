import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .app(
  name: "TrainTrainApp",
  dependencies: [
    .project(target: "Arrival", path: "../Subway"),
    .project(target: "Selection", path: "../Subway"),
  ],
  widgetDependencies: [
    .project(target: "WidgetHelper", path: "../Subway"),
  ],
  unitTestDependencies: [],
  additionalFiles: [
    ".swiftlint.yml",
  ]
)
