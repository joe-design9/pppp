#!/bin/sh
# Double-click on a Mac to open Leonida Hub in Xcode.
cd "$(dirname "$0")"
if ! xcodebuild -version 2>/dev/null | grep -q "Xcode 2[6-9]"; then
  echo "Leonida Hub needs Xcode 26 or newer for Liquid Glass."
  echo "Opening the Mac App Store page for Xcode..."
  open "macappstore://apps.apple.com/app/xcode/id497799835"
  exit 1
fi
open LeonidaHub.xcodeproj
echo ""
echo "Xcode is opening. Then:"
echo "  1. Click LeonidaHub in the sidebar > Signing & Capabilities > Team: pick your Apple ID"
echo "  2. Plug in your iPhone and choose it at the top of the window"
echo "  3. Press the Play button (Cmd+R)"
