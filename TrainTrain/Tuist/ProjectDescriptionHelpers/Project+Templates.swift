import ProjectDescription

// MARK: - Versions
public let appVersion: InfoPlist.Value = "2.0.1"
public let buildNumber: InfoPlist.Value = "1"
public let deploymentTarget: DeploymentTarget = .iOS(targetVersion: "15.0", devices: .iphone)

// MARK: - Helpers
extension Project {

  static let bundleIdPrefix: String = "space.codable"

  public static func app(
    name: String,
    dependencies: [TargetDependency],
    widgetDependencies: [TargetDependency],
    unitTestDependencies: [TargetDependency],
    packages: [Package] = [],
    additionalFiles: [FileElement] = []
  ) -> Project {
    let mainTarget = Target(
      name: name,
      platform: .iOS,
      product: .app,
      bundleId: "\(bundleIdPrefix).trainHard",
      deploymentTarget: deploymentTarget,
      infoPlist: .app(version: appVersion, buildNumber: buildNumber),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      entitlements: nil,
      scripts: makeLintScript(for: .app),
      dependencies: [
        [.target(name: "TrainTrainWidget")],
        dependencies,
      ].flatMap { $0 },
      settings: .settings(
        configurations: [
          .debug(name: .dev, xcconfig: .appDevXCConfig),
          .release(name: .release, xcconfig: .appDevXCConfig),
        ]
      ),
      coreDataModels: [],
      launchArguments: [],
      additionalFiles: []
    )
    let widgetTarget = Target(
      name: "TrainTrainWidget",
      platform: .iOS,
      product: .appExtension,
      productName: "TrainTrainWidget",
      bundleId: "\(bundleIdPrefix).trainHard.TrainTrainWidget",
      infoPlist: .extendingDefault(with: [
        "NSExtension": ["NSExtensionPointIdentifier": "com.apple.widgetkit-extension"],
      ]),
      sources: ["../Subway/Widget/Sources/**"],
      scripts: makeLintScript(for: .appExtension),
      dependencies: widgetDependencies,
      settings: .settings(
        configurations: [
          .debug(name: .dev, xcconfig: .widgetExtensionDevXCConfig),
          .release(name: .release, xcconfig: .widgetExtensionDevXCConfig),
        ]
      ),
      coreDataModels: [],
      environment: [:],
      launchArguments: [],
      additionalFiles: [],
      buildRules: []
    )
    let unitTestTarget = Target(
      name: "\(name)Tests",
      platform: .iOS,
      product: .unitTests,
      bundleId: "\(bundleIdPrefix).\(name)Tests",
      deploymentTarget: deploymentTarget,
      infoPlist: .default,
      sources: ["Tests/Sources/**", "Tests/Resources/**"],
      dependencies: [
        [.target(name: name)],
        [.xctest],
        unitTestDependencies,
      ].flatMap { $0 }
    )
    return Project(
      name: name,
      packages: packages,
      targets: [mainTarget, unitTestTarget, widgetTarget],
      additionalFiles: additionalFiles
    )
  }

  public static func feature(
    name: String,
    targetConfigurations: [TargetConfiguration],
    packages: [Package] = [],
    additionalFiles: [FileElement] = []
  ) -> Project {
    var projectTargets: [Target] = []

    targetConfigurations.forEach { configuration in
      let mainTarget = Target(
        name: configuration.name,
        platform: .iOS,
        product: configuration.productType,
        bundleId: "\(bundleIdPrefix).\(configuration.name)",
        deploymentTarget: deploymentTarget,
        infoPlist: .default,
        sources: ["\(configuration.name)/Sources/**"],
        resources: ResourceFileElements(resources: configuration.resources.map { "\(configuration.name)/Resources/\($0)" }),
        scripts: makeLintScript(for: configuration.productType),
        dependencies: configuration.dependencies,
        additionalFiles: additionalFiles + ["\(configuration.name)/Resources/\(configuration.name).docc/**"]
      )
      projectTargets.append(mainTarget)

      if configuration.targetTypes.contains(.unitTest) {
        let unitTestTarget = Target(
          name: "\(configuration.name)Tests",
          platform: .iOS,
          product: .unitTests,
          bundleId: "\(bundleIdPrefix).\(configuration.name)Tests",
          deploymentTarget: deploymentTarget,
          infoPlist: .default,
          sources: [
            "\(configuration.name)/Tests/Sources/**",
            "\(configuration.name)/Tests/Resources/**",
          ],
          dependencies: [
            [.target(name: configuration.name)],
            [.xctest],
            configuration.unitTestDependencies
          ].flatMap { $0 }
        )
        projectTargets.append(unitTestTarget)
      }

      if configuration.targetTypes.contains(.preview) {
        let previewAppTarget = Target(
          name: "\(configuration.name)PreviewApp",
          platform: .iOS,
          product: .app,
          bundleId: "\(bundleIdPrefix).\(configuration.name)PreviewApp",
          deploymentTarget: deploymentTarget,
          infoPlist: .app(
            version: appVersion,
            buildNumber: buildNumber
          ),
          sources: ["\(configuration.name)/Preview/Sources/**"],
          resources: ["\(configuration.name)/Preview/Resources/**"],
          scripts: [],
          dependencies: [
            .target(name: configuration.name)
          ]
        )
        projectTargets.append(previewAppTarget)
      }
    }

    return Project(
      name: name,
      options: .options(disableSynthesizedResourceAccessors: true),
      packages: packages,
      targets: projectTargets
    )
  }

  public static func designSystemFramework(
    name: String,
    dependencies: [TargetDependency] = [],
    packages: [Package] = [],
    additionalFiles: [FileElement] = []
  ) -> Project {
    let mainTarget = Target(
      name: name,
      platform: .iOS,
      product: .framework,
      bundleId: "\(bundleIdPrefix).\(name)",
      deploymentTarget: deploymentTarget,
      sources: ["Sources/**"],
      resources: ["Resources/*"],
      scripts: [
        makeLintScript(for: .framework),
        makeSwiftGenScript(),
      ].flatMap { $0 },
      dependencies: dependencies,
      additionalFiles: additionalFiles
    )
    return Project(
      name: name,
      options: .options(disableSynthesizedResourceAccessors: true),
      packages: packages,
      targets: [mainTarget]
    )
  }
}

extension TargetScript {
  static let appSwiftLint: Self = .pre(
    script: Script.appSwiftLint,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
  )
  static let moduleSwiftLint: Self = .pre(
    script: Script.moduleSwiftLint,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
  )
  static let swiftGen: Self = .pre(
    script: Script.swiftGen,
    name: "SwiftGen",
    basedOnDependencyAnalysis: false
  )
}

extension InfoPlist {

  static func app(
    version: InfoPlist.Value,
    buildNumber: InfoPlist.Value
  ) -> Self {
    return .extendingDefault(
      with: [
        "CFBundleShortVersionString": version,
        "CFBundleVersion": buildNumber,
        "UIMainStoryboardFile": "",
        "UILaunchStoryboardName": "LaunchScreen",
        "NSAppTransportSecurity": ["NSAllowsArbitraryLoads": true],
        "NSSupportsLiveActivities": true,
      ]
    )
  }
}

extension TargetScript.Script {

  static let appSwiftLint = """
    if test -d "/opt/homebrew/bin/"; then
      PATH="/opt/homebrew/bin/:${PATH}"
    fi
    export PATH
    if which swiftlint >/dev/null; then
      swiftlint
    else
      echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
    """

  static let moduleSwiftLint = """
    if test -d "/opt/homebrew/bin/"; then
      PATH="/opt/homebrew/bin/:${PATH}"
    fi
    export PATH
    if which swiftlint >/dev/null; then
      swiftlint --config ../TrainTrainApp/.swiftlint.yml
    else
      echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
    """

  static let swiftGen = """
    if test -d "/opt/homebrew/bin/"; then
      PATH="/opt/homebrew/bin/:${PATH}"
    fi

    export PATH

    if which swiftgen >/dev/null; then
      swiftgen run xcassets "${SRCROOT}/Resources/Colors.xcassets" "${SRCROOT}/Resources/Images.xcassets" -p "${SRCROOT}/Resources/Templates/Assets.stencil" -o "${SRCROOT}/Sources/Generated/Assets+Generated.swift"
    else
      echo "warning: SwiftGen is not installed."
    fi
  """
}

private func makeLintScript(for product: Product) -> [TargetScript] {
  guard !Environment.isCI.getBoolean(default: false) else { return [] }

  switch product {
  case .app:
    return [.appSwiftLint]

  case .unitTests, .uiTests:
    return []

  default:
    return [.moduleSwiftLint]
  }
}

private func makeSwiftGenScript() -> [TargetScript] {
  guard !Environment.isCI.getBoolean(default: false) else { return [] }
  return [.swiftGen]
}
