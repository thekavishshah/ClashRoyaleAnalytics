//
//  ProfileView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: PlayerViewModel
    var body: some View {
        VStack(spacing: 12) {
            if let p = vm.player {
                VStack(alignment: .leading, spacing: 8) {
                    Text(p.name).font(.largeTitle)
                    Text(p.tag).font(.callout).foregroundStyle(.secondary)
                    HStack {
                        if let lv = p.expLevel { Label("Lv \(lv)", systemImage: "bolt") }
                        if let tr = p.trophies { Label("\(tr)", systemImage: "shield") }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding()
            } else {
                Text("Search a player to view profile")
            }
            Spacer()
        }
        .navigationTitle("Profile")
    }
}
