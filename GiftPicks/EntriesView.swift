import SwiftUI

struct EntriesView: View {
    @EnvironmentObject var settings: GlobalSettings
    var changePage: () -> Void

    var body: some View {
        VStack {
            Text("Entries Page")
            
            let groupedEntries = Dictionary(grouping: settings.entries, by: { $0.amount })
            ForEach(groupedEntries.keys.sorted(), id: \.self) { amount in
                VStack {
                    ForEach(groupedEntries[amount] ?? [], id: \.bet) { entry in
                        Text("\(entry.bet)")
                    }
                    Text("Bet Amount: \(amount)")
                }
                .padding() // Padding inside the box
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                )
                .padding(.horizontal) // Padding around the box to avoid touching the edges of the screen
            }

            Button("Back to Home") {
                changePage()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
