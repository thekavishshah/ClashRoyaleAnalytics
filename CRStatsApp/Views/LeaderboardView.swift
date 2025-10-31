//
//  LeaderboardView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var vm = LeaderboardViewModel()
    var body: some View {
        List(vm.top) { p in
            HStack {
                Text("#\(p.rank)").frame(width: 44, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(p.name)
                    Text(p.tag).font(.caption).foregroundStyle(.secondary)
                    if let c = p.clan?.name { Text(c).font(.caption2).foregroundStyle(.secondary) }
                }
            }
        }
        .task { await vm.load() }
        .overlay { if vm.isLoading { ProgressView() } }
        .overlay { if let e = vm.error { Text(e).foregroundStyle(.red) } }
        .navigationTitle("Top Players")
    }
}
