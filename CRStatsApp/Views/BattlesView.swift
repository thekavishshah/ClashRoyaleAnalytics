//
//  BattlesView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//

import SwiftUI

struct BattlesView: View {
    @ObservedObject var vm: PlayerViewModel
    var body: some View {
        List(vm.battles) { b in
            VStack(alignment: .leading) {
                let teamCrowns = b.team.first?.crowns ?? 0
                let oppCrowns = b.opponent.first?.crowns ?? 0
                let r = teamCrowns == oppCrowns ? "Draw" : (teamCrowns > oppCrowns ? "Win" : "Loss")
                Text(r)
                HStack {
                    Text("You: \(teamCrowns)")
                    Text("Opp: \(oppCrowns)")
                }.font(.caption).foregroundStyle(.secondary)
                Text(b.battleTime).font(.caption2)
            }
        }
        .overlay { if vm.battles.isEmpty { Text("No battles yet") } }
        .navigationTitle("Battles")
    }
}
