import SwiftUI

struct EntriesView: View {
    @EnvironmentObject var settings: GlobalSettings
    var changePage: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Entries Page")
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button("Back to Board") {
                    changePage()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            ScrollView {
                let groupedEntries = Dictionary(grouping: settings.entries, by: { $0.id })
                ForEach(groupedEntries.keys.sorted(by: >), id: \.self) { key in
                    VStack(alignment: .leading) {
                        ForEach(groupedEntries[key] ?? [], id: \.bet) { entry in
                            Text("\(entry.bet)")
                        }
                        if let firstEntry = groupedEntries[key]?.first {
                            Text("Bet Amount: \(firstEntry.amount)")
                        }
                    }
                    .padding() // Padding inside the box
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                    )
                    .padding(.horizontal) // Padding around the box to avoid touching the edges of the screen
                    .padding(Edge.Set.top)
                }
            }
        }
        .padding(.bottom) // Add padding at the bottom if needed
        .padding(.trailing, 30)
    }
}
