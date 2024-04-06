import SwiftUI

struct ContentView: View {
    
    @Binding var isAuthenticated: Bool // Binding to the isAuthenticated state variable
    // SPORTS AND STATS ---------------------------------------------------------------------------
    @State private var selectedSport: String = "NBA"
    @State private var selectedStat: String = "NBA"
    @State private var sports: [String] = ["NBA", "MLB", "NFL", "Soccer", "Cricket", "Tennis"]

    
    @State private var isScrolling: Bool = false
    @State private var highlightedPlayer: Int? = nil
    @State private var isSecondWindowOpen = false
    @State private var overUnder: String = ""
    @State private var playerEntryCount = 0
    
    @State private var playerEntry: [String: [String]] = [
        "NBA": Array(repeating: "Lebron James", count: 30),
        "MLB": Array(repeating: "Shohei Ohtani", count: 30),
        "NFL": Array(repeating: "Christian McCaffrey", count: 30),
        "Soccer": Array(repeating: "Lionel Messi", count: 30),
        "Cricket": Array(repeating: "David Warner", count: 30),
        "Tennis": Array(repeating: "Rafael Nadl", count: 30)
    ]
    
    @State private var sportsStats: [String: [String]] = [
        "NBA": ["Points", "Rebounds", "Assists", "PRA", "RA", "PR", "PA"],
        "MLB": ["Hits", "Bases", "Strikeouts", "PRA", "RA", "PR", "PA"],
        "NFL": ["Catches", "Throwing", "Receiving", "Rushing", "RA", "PR", "PA"],
        "Soccer": ["Passes", "Goals", "Assists", "Saves", "RA", "PR", "PA"],
        "Cricket": ["Runs", "Fours", "Sixes", "Wickets", "RA", "PR", "PA"],
        "Tennis": ["Aces", "Break Points", "Serves", "PRA", "RA", "PR", "PA"]
    ]
    
    @State private var playerColors: [String: [Color]] = [
        "NBA": Array(repeating: .clear, count: 30),
        "MLB": Array(repeating: .clear, count: 30),
        "NFL": Array(repeating: .clear, count: 30),
        "Soccer": Array(repeating: .clear, count: 30),
        "Cricket": Array(repeating: .clear, count: 30),
        "Tennis": Array(repeating: .clear, count: 30)
    ]
    
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    HStack(spacing: 8) {
                        ForEach(sports, id: \.self) { sport in
                            Text(sport)
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(selectedSport == sport ? .white : .black)
                                .background(selectedSport == sport ? Color.purple : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    withAnimation {
                                        selectedSport = sport
                                    }
                                    scrollView.scrollTo(sport, anchor: .center)
                                    highlightedPlayer = nil
                                    //clearAllHighlightedPlayers(playerColors: &playerColors[sport]!) // Clear highlights of other players
                                }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .onChange(of: scrollViewOffset) { offset in
                    isScrolling = offset != .zero
                }
            }
            
            HStack {
                Spacer()
                    .frame(width: 16) // Adjust spacing for buttons
                Button(action: {
                    // Set player button color to red
                    if highlightedPlayer != nil{
                        playerColors[selectedSport]![highlightedPlayer ?? 0] = .red}
                    overUnder = "Under"
                    printSelection()
                }) {
                    Text("Under")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                Button(action: {
                    // Set player button color to green
                    if highlightedPlayer != nil{
                        playerColors[selectedSport]![highlightedPlayer ?? 0] = .green}
                    overUnder = "Over"
                    printSelection()
                }) {
                    Text("Over")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                Button(action: {
                    clearAllPlayerColors()
                    // Set all player buttons color to clear
                    overUnder = "Clear"
                    printSelection()
                }) {
                    Text("Clear")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            } // end HStack for buttons clear, over, under
            
            
            ZStack {
                if let players = playerEntry[selectedSport], let stats = sportsStats[selectedSport]{
                    generateSportsView(sport: selectedSport, stats: stats, players: players)
                } else {
                    Text("No players available")
                }
            }
            
            
            
            
            VStack {
                HStack{
                    Button(action: {
                        isSecondWindowOpen.toggle()
                    }) {
                        Text("Player Entry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: 150, y: 0)
                    .background(Color.clear)
                    .sheet(isPresented: $isSecondWindowOpen) {
                        SecondView(playerColors: playerColors)
                    }
                    
                    Button(action: {
                        isAuthenticated = false
                    }) {
                        Text("Return to Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: -160, y: 0)
                    .background(Color.clear)
                } // end hstack for return to login and player entry
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(["Entries", "Board", "Account", "Live"], id: \.self) { entry in
                                Button(action: {
                                    // Handle button action
                                }) {
                                    Text(entry)
                                        .font(.headline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.white)
                                        .background(Color.purple)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                .background(Color.black)
            } // end vstack for PLAYER ENTRY BUTTON and BOTTOM LIST
        } // end OG vstack
    } // end view
    
    
    
    
    private var scrollViewOffset: CGFloat {
        return UIScrollView.appearance().contentOffset.y
    }
    private func printSelection() {
        if let playerIndex = highlightedPlayer, let playerName = playerEntry[selectedSport]?[playerIndex] {
            print("Highlighted Player: \(playerName), Selection: \(overUnder)")
        }
    }

    
    func clearAllPlayerColors() {
        for sport in playerColors.keys {
            guard var sportColors = playerColors[sport] else {
                continue // Skip if the sport is not found in the dictionary
            }
            
            for i in 0..<sportColors.count {
                sportColors[i] = .clear
            }
            playerColors[sport] = sportColors
        }
    }

    func changePlayerColor(sport: String, playerIndex: Int, color: Color) {
        guard var sportColors = playerColors[sport] else {
            return // Sport not found in the dictionary
        }
        
        guard playerIndex >= 0 && playerIndex < sportColors.count else {
            return // Player index out of bounds
        }
        sportColors[playerIndex] = color
        playerColors[sport] = sportColors
    }

    func getPlayerColor(sport: String, playerIndex: Int) -> Color? {
        guard let sportColors = playerColors[sport] else {
            return nil // Sport not found in the dictionary
        }
        
        guard playerIndex >= 0 && playerIndex < sportColors.count else {
            return nil // Player index out of bounds
        }
        
        return sportColors[playerIndex]
    }

    func clearHighlightedPlayersSport(playerColors: inout [Color]) {
        for (index, color) in playerColors.enumerated() {
            if color == .gray {
                playerColors[index] = .clear
            }
        }
    }
    
    func checkIfGrayedPlayer(playerColors: inout [Color]) -> Bool{
        for (_, color) in playerColors.enumerated(){
            if color == .gray{
                return true
            }
        }
        return false
    }
    
    func clearAllHighlightedPlayers() {
        for sport in playerColors.keys {
            guard var sportColors = playerColors[sport] else {
                continue // Skip if the sport is not found in the dictionary
            }
            
            for i in 0..<sportColors.count {
                if sportColors[i] == .gray {
                    sportColors[i] = .clear
                }
            }
            playerColors[sport] = sportColors
        }
    }

    
    func generateSportsView(sport: String, stats: [String], players: [String]) -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    HStack(spacing: 8) {
                        ForEach(stats, id: \.self) { stat in
                            Text(stat)
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(selectedStat == stat ? .blue : .black)
                                .background(selectedSport == stat ? Color.yellow : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    withAnimation {
                                        selectedStat = stat
                                    }
                                    scrollView.scrollTo(stat, anchor: .center)
                                }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .onChange(of: scrollViewOffset) { offset in
                    isScrolling = offset != .zero
                }
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(players.indices, id: \.self) { index in
                        Button(action: {
                            let colorCheck = getPlayerColor(sport: sport, playerIndex: index)
                            clearHighlightedPlayersSport(playerColors: &playerColors[sport]!)
                            if highlightedPlayer == nil && colorCheck == .clear {
                                clearAllHighlightedPlayers()
                                changePlayerColor(sport: sport, playerIndex: index, color: .gray)
                                highlightedPlayer = index
                            }
                            else if colorCheck == .gray || colorCheck == .red || colorCheck == .green {
                                changePlayerColor(sport: sport, playerIndex: index, color: .clear)
                                highlightedPlayer = nil
                            }
                            else {
                                changePlayerColor(sport: sport, playerIndex: index, color: .gray)
                                highlightedPlayer = index
                            }
                        }) {
                            Text(players[index])
                                .padding(20) // Adjust padding to make the squares taller
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(getPlayerColor(sport: sport, playerIndex: index))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1) // Outline with black color and 1pt width
                                )
                        }
                        .buttonStyle(PlainButtonStyle()) // Remove button styling
                    }
                }
                .padding(.horizontal, 10) // Add horizontal padding to the grid
            }
        }
    }
} // end content view struct

struct SecondView: View {
    @State private var playerEntry: [String: [String]] = [
        "NBA": Array(repeating: "Lebron James", count: 30),
        "MLB": Array(repeating: "Shohei Ohtani", count: 30),
        "NFL": Array(repeating: "Christian McCaffrey", count: 30),
        "Soccer": Array(repeating: "Lionel Messi", count: 30),
        "Cricket": Array(repeating: "David Warner", count: 30),
        "Tennis": Array(repeating: "Rafael Nadl", count: 30)
    ]
    @Environment(\.presentationMode) var presentationMode
    let playerColors: [String: [Color]]

    var body: some View {
        ZStack(alignment: .topTrailing) { // Align elements to the top trailing corner
            
            VStack {
                Text("Current Entry:")
                    .font(.headline)
                    .padding()
                
                ForEach(playerColors.keys.sorted(), id: \.self) { sport in
                    if let colors = playerColors[sport], let players = playerEntry[sport]{
                        let coloredPlayers = colors.enumerated().filter { $0.element == .green || $0.element == .red }
                        ForEach(coloredPlayers, id: \.offset) { (offset, color) in
                            Text("\(sport): \(players[offset]) - \(color == .green ? "Over" : "Under")")
                                .padding()
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Return to Player Entries")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.trailing, 20) // Add trailing padding to move the button to the left
            }
            .padding()
        }
    }
}








struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isAuthenticated: .constant(false))
    }
}
