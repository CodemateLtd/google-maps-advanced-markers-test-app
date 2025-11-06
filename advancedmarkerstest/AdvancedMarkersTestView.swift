// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CoreLocation
import GoogleMaps
import SwiftUI
import UIKit

struct AdvancedMarkersTestView: View {
  private let centerCoordinate = CLLocationCoordinate2D(latitude: 37.422, longitude: -122.084)
  @State private var capabilityStatus = "Waiting map capabilities..."

  var body: some View {
    VStack(spacing: 0) {
      AdvancedMarkerMapView(centerCoordinate: centerCoordinate, capabilityStatus: $capabilityStatus)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .top)

      Text(capabilityStatus)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.thinMaterial)
    }
  }
}

struct AdvancedMarkerMapView: UIViewRepresentable {
  let centerCoordinate: CLLocationCoordinate2D
  @Binding var capabilityStatus: String
  private let markerSpacing: CLLocationDegrees = 0.001

  class Coordinator: NSObject, GMSMapViewDelegate {
    var markers: [GMSAdvancedMarker] = []
    var hasAddedMarkers = false
    var isMapReady = false
    private let capabilityStatus: Binding<String>

    init(capabilityStatus: Binding<String>) {
      self.capabilityStatus = capabilityStatus
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
      if !isMapReady {
        isMapReady = true
        checkCapabilitiesAndAddMarkers(mapView)
      }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
      if !isMapReady {
        isMapReady = true
        checkCapabilitiesAndAddMarkers(mapView)
      }
    }

    func mapView(_ mapView: GMSMapView, didChangeMapCapabilities mapCapabilities: GMSMapCapabilityFlags) {
      if isMapReady {
        checkCapabilitiesAndAddMarkers(mapView)
      }
    }
    
    func checkCapabilitiesAndAddMarkers(_ mapView: GMSMapView) {
      guard !hasAddedMarkers else { return }
      
      let mapCapabilities = mapView.mapCapabilities
      let supportsAdvancedMarkers = mapCapabilities.contains(.advancedMarkers)
      
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        if supportsAdvancedMarkers {
          self.addTestMarkers(to: mapView)
          self.hasAddedMarkers = true
          self.capabilityStatus.wrappedValue = "Advanced markers available - 5 test markers displayed"
        } else {
          self.capabilityStatus.wrappedValue = "Advanced markers unavailable"
        }
      }
    }
    
    func addTestMarkers(to mapView: GMSMapView) {
      let markerTypes: [MarkerType] = [.basic, .customImage, .customBackground, .customGlyph, .customUIView]
      let markerSpacing: CLLocationDegrees = 0.001
      let centerCoordinate = CLLocationCoordinate2D(latitude: 37.422, longitude: -122.084)
      
      for (index, type) in markerTypes.enumerated() {
        let longitude = centerCoordinate.longitude + (Double(index) - 2.0) * markerSpacing
        let position = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: longitude)
        
        let marker = GMSAdvancedMarker(position: position)
        setupMarker(marker, type: type)
        marker.map = mapView
        
        markers.append(marker)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(capabilityStatus: $capabilityStatus)
  }

  func makeUIView(context: Context) -> GMSMapView {
    let options = GMSMapViewOptions()
    options.camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: 15)
    
    if let mapID = loadMapID() {
      options.mapID = mapID
    } else {
      options.mapID = GMSMapID(identifier: "DEMO_MAP_ID")
    }

    let mapView = GMSMapView(options: options)
    mapView.delegate = context.coordinator
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      if !context.coordinator.isMapReady {
        context.coordinator.isMapReady = true
        context.coordinator.checkCapabilitiesAndAddMarkers(mapView)
      }
    }
    
    return mapView
  }

  func updateUIView(_ mapView: GMSMapView, context: Context) {
  }
  
  private func loadMapID() -> GMSMapID? {
    guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let identifier = plist["GMSMapID"] as? String,
          !identifier.isEmpty else { return nil }
    return GMSMapID(identifier: identifier)
  }
}

// MARK: - Marker Types
private enum MarkerType {
  case basic
  case customImage
  case customBackground
  case customGlyph
  case customUIView
}

private func setupMarker(_ marker: GMSAdvancedMarker, type: MarkerType) {
  switch type {
  case .basic:
    print("Marker #1 - Using basic/default marker")
    break
    
  case .customImage:
    let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
    if let image = UIImage(systemName: "star.fill", withConfiguration: config) {
      let tintedImage = image.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
      print("Marker #2 - Created custom image: \(tintedImage)")
      marker.icon = tintedImage
      print("Marker #2 - Assigned icon to marker: \(marker.icon != nil ? "SUCCESS" : "FAILED - icon is nil")")
    } else {
      print("Marker #2 - FAILED to create SF Symbol image")
    }
    
  case .customBackground:
    // MARKER #3 - KNOWN ISSUE: This GMSPinImage marker may not display on some devices
    // See: https://issuetracker.google.com/issues/370536110
    let options = GMSPinImageOptions()
    options.backgroundColor = UIColor.systemTeal
    print("Marker #3 - Creating GMSPinImage with options: \(options)")
    let pinImage = GMSPinImage(options: options)
    print("Marker #3 - Created GMSPinImage: \(pinImage)")
    marker.icon = pinImage
    print("Marker #3 - Assigned icon to marker: \(marker.icon != nil ? "SUCCESS" : "FAILED - icon is nil")")
    
  case .customGlyph:
    // MARKER #4 - KNOWN ISSUE: This GMSPinImage marker may not display on some devices
    // See: https://issuetracker.google.com/issues/370536110
    let options = GMSPinImageOptions()
    let glyph = GMSPinImageGlyph(text: "GM", textColor: UIColor.white)
    print("Marker #4 - Created glyph: \(glyph)")
    options.glyph = glyph
    print("Marker #4 - Creating GMSPinImage with options: \(options)")
    let pinImage = GMSPinImage(options: options)
    print("Marker #4 - Created GMSPinImage: \(pinImage)")
    marker.icon = pinImage
    print("Marker #4 - Assigned icon to marker: \(marker.icon != nil ? "SUCCESS" : "FAILED - icon is nil")")
    
  case .customUIView:
    let customView = CustomMarkerView()
    print("Marker #5 - Created custom UIView: \(customView)")
    marker.iconView = customView
    print("Marker #5 - Assigned iconView to marker: \(marker.iconView != nil ? "SUCCESS" : "FAILED - iconView is nil")")
  }
}

// MARK: - Custom UIView Marker
private class CustomMarkerView: UIView {
  private let titleLabel = UILabel()
  
  init() {
    super.init(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    backgroundColor = UIColor.systemIndigo
    layer.cornerRadius = 20
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.25
    layer.shadowOffset = CGSize(width: 0, height: 3)
    layer.shadowRadius = 6
    
    titleLabel.text = "UIView"
    titleLabel.textColor = .white
    titleLabel.font = .boldSystemFont(ofSize: 14)
    titleLabel.textAlignment = .center
    titleLabel.adjustsFontSizeToFitWidth = true
    titleLabel.minimumScaleFactor = 0.7
    titleLabel.frame = bounds
    titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(titleLabel)
  }
}


#Preview {
  AdvancedMarkersTestView()
}
