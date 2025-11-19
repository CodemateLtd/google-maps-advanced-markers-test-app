# Google Maps Advanced Markers Test

This app demonstrates how 5 different types of advanced markers are rendered on a map using the Google Maps SDK for iOS.

## Setup

1. Copy `Keys.plist.sample` as `Keys.plist` and add your proper Google Maps API key
2. Run the application on your device or simulator

## What This App Shows

This project displays 5 advanced markers arranged in a horizontal row on the map. Each marker demonstrates a different way to create advanced markers.

### How the 5 Markers are Built

Each marker showcases a different customization approach:

1. **Basic Marker** - Uses the default advanced marker appearance with no custom styling
2. **Custom Image Marker** - Uses a custom pink star image created from SF Symbols (`star.fill`)
3. **Custom Background Marker** - Uses `GMSPinImage` with a custom teal background color
4. **Custom Glyph Marker** - Uses `GMSPinImage` with custom text "GM" displayed in white
5. **Custom UIView Marker** - Uses a fully custom UIView with rounded corners, shadow, and "UIView" label

The markers are positioned using a spacing of 0.001 degrees longitude around the center coordinate (37.422, -122.084), creating a visible row of different marker styles.

When you run the app, you should visually verify that all 5 markers are displayed on the map, each showing its distinct visual style.

## Testing Focus: GMSPinImage Marker Visibility

**This project specifically demonstrates a known issue where markers created with `GMSPinImage` may not display on certain devices.**

When testing, pay special attention to:
- **Marker #3 (Custom Background)** - Teal colored pin created with `GMSPinImage`
- **Marker #4 (Custom Glyph)** - Pin with "GM" text created with `GMSPinImage`

**Expected results:**
- Markers #1, #2, and #5 should always be visible (they don't use `GMSPinImage`)
- Markers #3 and #4 may be missing or not display correctly on some devices

If you cannot see markers #3 and #4, this confirms the issue documented at: https://issuetracker.google.com/issues/370536110

### Debug Console Output

When the GMSPinImage issue occurs, you may see this error in the Xcode console:
```
((null)) was false: Failed to allocate texture space for marker
```

This log message indicates that the `GMSPinImage` marker failed to render due to texture allocation issues on the device.

## What You Should See

On devices that support advanced markers, you should see all 5 markers displayed in a row. If markers #3 and #4 (the GMSPinImage markers) are missing, this demonstrates the known rendering issue.

### Example screenshot 
Screenshot with 2 missing markers (mapID with cloud-based styling used):

<img width="400"  alt="Simulator Screenshot - iPhone 17 Pro - 2025-11-19 at 15 11 08" src="https://github.com/user-attachments/assets/efaaa0e3-92b0-45fe-bc96-a1afbb94311d" />
