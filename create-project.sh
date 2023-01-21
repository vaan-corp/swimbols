APP_NAME="Template"

echo "☠️  Killing Xcode..."
killall Xcode 2>/dev/null

echo "🧹 Removing project..."
rm -rf $APP_NAME.xcodeproj

echo "🛠  Regenerating project..."
xcodegen

# echo "🚀 Opening project!"
open $APP_NAME.xcodeproj
# open -a "AppCode" $APP_NAME.xcodeproj