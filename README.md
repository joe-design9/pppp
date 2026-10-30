# Leonida Hub

An unofficial GTA VI fan hub for PC and iPhone. It has:
- a launch countdown
- official screenshots
- Leonida's regions
- the characters
- a launch-day checklist

The site and the app share one design: Liquid Glass panels over an animated Vice City sunset.

Not affiliated with Rockstar Games or Take-Two Interactive. Screenshots are © Rockstar Games and load directly from rockstargames.com. None are copied into this project.

## Install it

Pick the row that matches what you have.

| You have | Method | Time |
|---|---|---|
| Any iPhone or PC | **Home Screen app** (website) | 20 seconds |
| A Windows PC + iPhone on iOS 26 | **Native app with Sideloadly** | 10 minutes |
| A Mac + iPhone on iOS 26 | **Native app with Xcode** | 5 minutes |

### 1. Home Screen app (easiest)

1. Put the `web/` folder on any static host. The fastest way is to drag the folder onto https://app.netlify.com/drop.
2. **iPhone:** open the link in Safari → tap **Share** → **Add to Home Screen** → **Add**.
3. **PC:** open the link in Chrome or Edge → click the install icon in the address bar.

It opens full screen like an app and works offline. Screenshots need a connection.

### 2. Native app from a Windows PC (Sideloadly)

1. Put this folder in a GitHub repo and push it to `main`. The included workflow (`.github/workflows/build-ipa.yml`) builds `LeonidaHub.ipa` in the cloud for free.
2. On GitHub, open **Releases → latest** and download `LeonidaHub.ipa`.
3. Install [Sideloadly](https://sideloadly.io) and iTunes (from apple.com, not the Microsoft Store).
4. Plug in your iPhone, drag the `.ipa` into Sideloadly, enter your Apple ID and click **Start**.
5. On the iPhone, go to Settings → General → VPN & Device Management and trust your Apple ID. Then go to Settings → Privacy & Security and turn on Developer Mode.

### 3. Native app from a Mac (Xcode)

1. Install **Xcode 26** from the Mac App Store.
2. Double-click **`ios/Open in Xcode.command`**, or open `ios/LeonidaHub.xcodeproj` directly.
3. Click **LeonidaHub** in the sidebar → **Signing & Capabilities** → **Team** → pick your Apple ID.
4. Plug in your iPhone, select it at the top of the window and press **▶︎** (⌘R).
5. On the iPhone, trust the developer and turn on Developer Mode, as in step 5 above.

With a free Apple ID, apps you install yourself expire after 7 days. Re-run the install, or let Sideloadly's auto-refresh handle it. A paid Apple Developer account ($99/yr) removes the limit and allows TestFlight.

## What's Liquid Glass in the app

The app uses Apple's real Liquid Glass from the iOS 26 SDK. These are system APIs, not imitations:

- `glassEffect(_:in:)` on every card, chip and caption, with `.interactive()` so the glass flexes and glows under your finger
- `GlassEffectContainer` + `glassEffectID`, so the "Release & platforms" pill splits into PS5 / Xbox chips and region chips flow into each other like liquid
- `.buttonStyle(.glass)` and `.glassProminent` buttons
- The system Liquid Glass tab bar with `tabBarMinimizeBehavior(.onScrollDown)` and a live countdown in `tabViewBottomAccessory`
- Glass toolbars, zoom transitions into a full-screen screenshot viewer, and soft scroll-edge effects

On the website, Chrome and Edge on desktop bend the background through an SVG displacement lens, which works like real refraction. Safari and phones fall back to frosted glass.

## Project layout

```
web/            Website (index.html is generated from hub.html by build.sh)
ios/            SwiftUI app (open LeonidaHub.xcodeproj)
.github/        Cloud build that produces LeonidaHub.ipa
```
