import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .designSystemFramework(
  name: "TTDesignSystem",
  dependencies: [
    .project(target: "SubwayModels", path: "../Subway"),
  ],
  packages: [],
  additionalFiles: [
    "Resources/Scripts/*",
    "Resources/Templates/*",
    "Resources/TTDesignSystem.docc",
  ]
)
