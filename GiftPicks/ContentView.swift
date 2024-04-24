import SwiftUI
import UIKit
import Foundation
import AWSS3


import SwiftUI









enum AppPage {
    case board
    case entries
    case account
    case help
} // end app page

class GlobalSettings: ObservableObject {
    @Published var checkIfPlaced: Bool = false
    @Published var betID: Int = 0
    @Published var entries: [(id: Int, bet: String, amount: String)] = []
    @Published var playerEntries: [PlayerEntry] = []

    init() {
        loadCSVData()
    }
    

    private func loadCSVData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Custom date format
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        let currentDate = Date()
        //let formattedDate = dateFormatter.string(from: currentDate) + "_All_Odds"
        let csvService = CSVParserService()
        self.playerEntries = csvService.loadCSVData(fileName: "2024-04-10_All_Odds")
    }
} // end global settings


struct ContentView: View {
    
    @EnvironmentObject var settings: GlobalSettings
    let goldColor = Color(red: 225/255, green: 200/255, blue: 134/255)
    
    @Binding public var isAuthenticated: Bool
    @State private var currentPage: AppPage = .board
    @State private var isScrolling: Bool = false // checks if scrolling
    @State private var highlightedPlayer: Int? = nil //highlighted player index
    @State private var isEntryWindowOpen = false // entry place window
    @State private var overUnder: String = "" // green/red
    @State private var playerEntryCount = 0 // id?

    private var sports: [String] {
        Set(settings.playerEntries.map { $0.sport }).sorted()
    }
    
    private var playerEntry: [String: [String: [String]]] {
        settings.playerEntries.reduce(into: [String: [String: [String]]]()) { result, entry in
            result[entry.sport, default: [String: [String]]()][entry.statType, default: [String]()].append(entry.name)
        }.mapValues { statDict in
            statDict.mapValues { names in
                names.sorted()
            }
        }
    }

    private var sportsStats: [String: [String]] {
        Dictionary(grouping: settings.playerEntries, by: { $0.sport })
            .mapValues { entries in
                Set(entries.map { $0.statType }).sorted()
            }
    }
    @State private var playerColors: [String: [String: [Color]]]
    @State private var selectedStat: String?
    @State private var selectedSport: String = "NBA" {
        didSet {
            if oldValue != selectedSport {
                selectedStat = sportsStats[selectedSport]?.first
            }
        }
    }

    init(isAuthenticated: Binding<Bool>, settings: GlobalSettings) {
            self._isAuthenticated = isAuthenticated
            
            // Temporary variable to hold sports stats until it's used to initialize selectedStat
            let tempSportsStats = Dictionary(grouping: settings.playerEntries, by: { $0.sport })
                .mapValues { entries in
                    Set(entries.map { $0.statType }).sorted()
                }
            
            // Initialize playerColors and selectedStat
            var initialColors = [String: [String: [Color]]]()
            for entry in settings.playerEntries {
                if initialColors[entry.sport] == nil {
                    initialColors[entry.sport] = [String: [Color]]()
                }
                if initialColors[entry.sport]?[entry.statType] == nil {
                    let count = settings.playerEntries.filter { $0.sport == entry.sport && $0.statType == entry.statType }.count
                    initialColors[entry.sport]?[entry.statType] = Array(repeating: Color.clear, count: count)
                }
            }

            self._playerColors = State(initialValue: initialColors)
            self._selectedStat = State(initialValue: tempSportsStats[selectedSport]?.first)
        } // end global settings conversion
    
    


    
    
    private func BoardView() ->  some View {
        GeometryReader { geometry in
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
                                .background(selectedSport == sport ? goldColor : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    withAnimation {
                                        selectedSport = sport
                                    }
                                    scrollView.scrollTo(sport, anchor: .center)
                                    highlightedPlayer = nil
                                }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.trailing, 30)
                }
            }

            HStack {
                Button(action: {
                    // Set player button color to red
                    if let index = highlightedPlayer {
                        playerColors[selectedSport]?[selectedStat!]?[index] = .red
                    }
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
                    if let index = highlightedPlayer {
                        playerColors[selectedSport]?[selectedStat!]?[index] = .green
                    }
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
                
                Button("Place Entry") {
                    //print("checking time")
                    isEntryWindowOpen.toggle()
                }
                //.frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.08)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(goldColor)
                    .cornerRadius(8)
                    .sheet(isPresented: $isEntryWindowOpen) {
                        CurrentEntry(playerColors: playerColors)
                    }

            }
            .padding(.trailing, 30)
            


            if playerEntry[selectedSport] != nil && sportsStats[selectedSport] != nil {
                generateSportsView(sport: selectedSport)
            } else {
                Text("No players or statistics available for \(selectedSport)")
            }

            
            
            //navigationBar(geometry: geometry)
            //.background(Color.purple.opacity(0.5))
            }

        }
        
    } // end board view
    
    
    var body: some View {
//        Image("logo 1") // Assumes "AppLogo" is the name of your image set
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 100, height: 100) // Adjust size as needed
        
            GeometryReader { geometry in
                ZStack {
                    Color(.systemGray5) // Very light grey background
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        //Spacer()
                        
                        // Content switcher
                        switch currentPage {
                        case .entries:
                            EntriesView(changePage: { self.currentPage = .board })
                        case .board:
                            BoardView()
                        case .account:
                            AccountView(changePage: { self.currentPage = .board })
                        case .help:
                            HelpView(changePage: { self.currentPage = .board })
                        }
                    }
                    
                    VStack {
                         Spacer()// Pushes the navigation bar to the bottom
                        navigationBar(geometry: geometry)
                    }
                }
            }
            //.edgesIgnoringSafeArea(.bottom) // Ensure the navigation bar can extend into the safe area if needed
            .onReceive(settings.$checkIfPlaced) { checkIfPlaced in
                if checkIfPlaced {
                    clearAllPlayerColors()
                    settings.checkIfPlaced = false
                }
            }
        } // end var body view
    
    
    private func navigationBar(geometry: GeometryProxy) -> some View {
        
        HStack(spacing: 30) {
            Button("Entries") { currentPage = .entries }
            Button("Board") { currentPage = .board }
            Button("Account") { currentPage = .account }
            Button("Help") { currentPage = .help }
        }
        .frame(width: geometry.size.width * 0.95, height: 50)
        .font(.headline)
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(goldColor)
        .padding(.trailing, 30)
    } // end nav bar
    
    
    private var scrollViewOffset: CGFloat {
        return UIScrollView.appearance().contentOffset.y
    }
    
    private func printSelection() {
        if let playerIndex = highlightedPlayer, let playerName = playerEntry[selectedSport]?[selectedStat ?? "IDK"] {
            print("Highlighted Player: \(playerName[playerIndex]), Selection: \(overUnder)")
        }
    }
    
    public func clearAllPlayerColors() {
        for (sport, statTypes) in playerColors {
            for (statType, colors) in statTypes {
                playerColors[sport]?[statType] = Array(repeating: .clear, count: colors.count)
            }
        }
    }


    func changePlayerColor(sport: String, statType: String, playerIndex: Int, color: Color) {
        guard playerIndex >= 0, let statColors = playerColors[sport]?[statType], playerIndex < statColors.count else {
            return
        }
        playerColors[sport]?[statType]?[playerIndex] = color
    }


    func getPlayerColor(sport: String, statType: String, playerIndex: Int) -> Color? {
        guard playerIndex >= 0, let statColors = playerColors[sport]?[statType], playerIndex < statColors.count else {
            return nil
        }
        return statColors[playerIndex]
    }


    func clearHighlightedPlayersSport(sport: String, statType: String) {
        if let playerColorsForStat = playerColors[sport]?[statType] {
            playerColors[sport]?[statType] = playerColorsForStat.map { $0 == .gray ? .clear : $0 }
        }
    }


    func checkIfGrayedPlayer(sport: String, statType: String) -> Bool {
        return playerColors[sport]?[statType]?.contains(.gray) ?? false
    }


    func clearAllHighlightedPlayers() {
        for (sport, statTypes) in playerColors {
            for (statType, _) in statTypes {
                clearHighlightedPlayersSport(sport: sport, statType: statType)
            }
        }
    }



    func generateSportsView(sport: String) -> some View {
        let players: [String]
        if let statsDict = playerEntry[selectedSport], let names = statsDict[selectedStat ?? "IDK"] {
            players = names
        } else {
            players = []
        }

        let stats = sportsStats[sport] ?? []
        //print(players, stats)
        let playerEntries = settings.playerEntries.filter { $0.sport == sport && (selectedStat == nil || $0.statType == selectedStat) }

        return VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { scrollView in
                        HStack(spacing: 8) {
                            ForEach(stats, id: \.self) { stat in
                                Text(stat)
                                    .font(.headline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .foregroundColor(selectedStat == stat ? .blue : .black)
                                    .background(selectedStat == stat ? Color.yellow : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        withAnimation {
                                            if selectedStat != stat {
                                                selectedStat = stat
                                                scrollView.scrollTo(stat, anchor: .center)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                } .padding(.trailing, 30)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(playerEntries, id: \.id) { entry in
                        Button(action: {
                            let playerIndex = players.firstIndex(of: entry.name) ?? 0
                            let colorCheck = getPlayerColor(sport: sport, statType: entry.statType, playerIndex: playerIndex)
                            clearHighlightedPlayersSport(sport: sport, statType: entry.statType)
                            if highlightedPlayer == nil && colorCheck == .clear {
                                print("everything is cleared before")
                                clearAllHighlightedPlayers()
                                changePlayerColor(sport: sport, statType: entry.statType, playerIndex: playerIndex, color: .gray)
                                //print(playerColors[sport]?[entry.statType] ?? ["NBA"] as Any)
                                highlightedPlayer = playerIndex
                            }
                            else if colorCheck == .gray || colorCheck == .red || colorCheck == .green {
                                print("unhighlighting")
                                changePlayerColor(sport: sport, statType: entry.statType, playerIndex: playerIndex, color: .clear)
                                //print(playerColors[sport]?[entry.statType] ?? ["NBA"] as Any)
                                highlightedPlayer = nil
                            }
                            else {
                                print("there was/is something highlighted before")
                                changePlayerColor(sport: sport, statType: entry.statType, playerIndex: playerIndex, color: .gray)
                                //print(playerColors[sport]?[entry.statType] ?? ["NBA"] as Any)
                                highlightedPlayer = playerIndex
                            }
                        }) {
                            VStack {
                                    Text("\(entry.team) - \(entry.position)")
                                        .font(.caption)
                                        .padding(.bottom, 0.5)
                                    Text(entry.name)
                                        .font(.headline)
                                        .padding(.bottom, 1)
                                    Text("\(entry.statType) - \(entry.lineScore)")
                                        .font(.caption)
                                        .padding(.top, 1)
                                    Text("vs \(entry.opponent)")
                                        .font(.caption)
                                        .padding(.top, 1)
                                }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(getPlayerColor(sport: sport, statType: entry.statType,playerIndex: players.firstIndex(of: entry.name) ?? 0))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 2)
                            ) // end overlay
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .padding(.trailing, 35)
                .padding(.bottom, 75)
            }
        }
    } // end genreate sports
} // end content view

// Define your PrimaryButtonStyle for a consistent look across buttons
struct PrimaryButtonStyle: ButtonStyle {
    let goldColor = Color(red: 225/255, green: 200/255, blue: 134/255)
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(goldColor)
            .cornerRadius(8)
    }
}

struct BottomButtons: ButtonStyle {
    let goldColor = Color(red: 225/255, green: 200/255, blue: 134/255)
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.subheadline) // Adjust font size
            .padding(.horizontal, 6) // Adjust horizontal padding
            .padding(.vertical, 4) // Adjust vertical padding
            .foregroundColor(.white)
            .background(goldColor)
            .cornerRadius(6) // Adjust corner radius
    }
}


struct CurrentEntry: View {
    @EnvironmentObject var settings: GlobalSettings
    @Environment(\.presentationMode) var presentationMode
    var playerColors: [String: [String: [Color]]]
    

    @State private var printedPlayers: [(sport: String, name: String, statType: String, color: Color)] = []
    @State private var dollarAmount: String = ""

    private var coloredPlayers: [(sport: String, player: PlayerEntry, color: Color)] {
        settings.playerEntries.compactMap { player in
            guard let statTypeColors = playerColors[player.sport]?[player.statType] else {
                return nil
            }
            
            // Find the index of the player in the list for the specific sport and stat type
            let playersForSportAndStat = settings.playerEntries.filter { $0.sport == player.sport && $0.statType == player.statType }
            guard let playerIndex = playersForSportAndStat.firstIndex(where: { $0.id == player.id }) else {
                return nil
            }

            let color = statTypeColors[playerIndex]
            return color == .green || color == .red ? (player.sport, player, color) : nil
        }
    }




    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Text("Current Entry:")
                    .font(.headline)
                    .padding()

                ForEach(coloredPlayers, id: \.player.id) { entry in
                    let displayText = "\(entry.player.name) (\(entry.player.statType)) - \(entry.color == .green ? "Over" : "Under")"
                    Text(displayText)
                        .padding()
                        .background(entry.color == .green ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onAppear {
                            printedPlayers.append((sport: entry.sport, name: entry.player.name, statType: entry.player.statType, color: entry.color))
                        }
                }

                HStack {
                    TextField("Dollar Amount", text: $dollarAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Confirm and Place") {
                        print(coloredPlayers)
                        settings.checkIfPlaced = true
                        for player in printedPlayers {
                            settings.entries.append((id: settings.betID, bet: "\(player.sport): \(player.name) - \(player.statType)", amount: dollarAmount))
                        }
                        settings.betID += 1
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
} // end entry view


// Your other view structs like EntriesView, BoardView, etc...
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = GlobalSettings()
        ContentView(isAuthenticated: .constant(false), settings: settings)
    }
}

