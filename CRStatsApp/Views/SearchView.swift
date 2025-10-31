import SwiftUI
import SwiftData

struct SearchView: View {
    @ObservedObject var vm: PlayerViewModel
    var onSave: (PlayerDTO) -> Void
    var saved: [SavedPlayer]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Enter player tag (e.g. #ABC123)", text: $vm.queryTag)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Button("Go") { Task { await vm.loadAll() } }
            }.padding(.horizontal)
            if let e = vm.error { Text(e).foregroundStyle(.red) }
            if vm.isLoading { ProgressView() }
            if let p = vm.player {
                VStack(alignment: .leading, spacing: 6) {
                    Text(p.name).font(.title2)
                    Text(p.tag)
                    HStack {
                        if let t = p.trophies { Label("\(t)", systemImage: "shield") }
                        if let bt = p.bestTrophies { Label("Best \(bt)", systemImage: "star") }
                    }
                    if let c = p.clan?.name { Label(c, systemImage: "person.3") }
                    Button("Save") { onSave(p) }
                }.padding()
            }
            List {
                Section("Saved") {
                    ForEach(saved) { s in
                        VStack(alignment: .leading) {
                            Text(s.name)
                            Text(s.tag).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Clash Royale")
    }
}
