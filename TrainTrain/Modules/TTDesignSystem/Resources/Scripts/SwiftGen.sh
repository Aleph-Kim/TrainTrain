APP_TARGET_NAME="TrainTrain"
PACKAGE_PATH=$(echo "$(pwd)")
RESOURCE_PATH=$(echo "$PACKAGE_PATH/Resources")
GENERATED_SOURCES_PATH=$(echo "$PACKAGE_PATH/Sources/Generated")
ASSET_TEMPLATE_PATH=$(echo "$RESOURCE_PATH/Templates")

swiftgen run xcassets \
  "$RESOURCE_PATH/Colors.xcassets" \
  "$RESOURCE_PATH/Images.xcassets" \
  -p "$ASSET_TEMPLATE_PATH/Assets.stencil" \
  -o "$GENERATED_SOURCES_PATH/Assets+Generated.swift"
