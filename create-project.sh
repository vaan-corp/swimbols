APP_NAME="Swimbols"

echo "☠️  Killing Xcode..."
killall Xcode 2>/dev/null

echo "🧹 Removing project..."
rm -rf $APP_NAME.xcodeproj

echo "🛠  Regenerating project..."
xcodegen

echo "🚧 Resolving dependencies"
xcodebuild -resolvePackageDependencies

# echo "🚀 Opening project!"
open $APP_NAME.xcodeproj
# open -a "AppCode" $APP_NAME.xcodeproj