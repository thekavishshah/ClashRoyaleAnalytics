//
//  WorldMapView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//

import SwiftUI
import MapKit

struct WorldMapView: View {
    @StateObject private var loc = LocationManager()
    var body: some View {
        Map(position: .constant(.region(loc.region)))
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("World Map")
    }
}
