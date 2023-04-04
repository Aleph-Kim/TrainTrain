import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
  name: "Platform",
  targetConfigurations: [
    TargetConfiguration(
      name: "APIClient",
      targetTypes: [],
        productType: .framework,
        dependencies: []
    ),
    TargetConfiguration(
      name: "TTFoundation",
      targetTypes: [],
        productType: .framework,
        dependencies: []
    ),
    TargetConfiguration(
      name: "UserDefaultsClient",
      targetTypes: [],
        productType: .framework,
        dependencies: []
    ),
  ],
  packages: [],
  additionalFiles: []
)
