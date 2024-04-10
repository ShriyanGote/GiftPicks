import Foundation

// Define the model to represent each entry in the CSV file
struct PlayerEntry: Identifiable {
    let id = UUID()
    var playerID: String
    var name: String
    var position: String
    var team: String
    var sport: String
    var opponent: String
    var gameID: String
    var lineScore: String
    var statType: String
    var startTime: String
}

// Function to parse the CSV data into PlayerEntry objects
func parseCSV(contents: String) -> [PlayerEntry] {
    var result: [PlayerEntry] = []

    // Split the CSV text into lines, skipping the header line
    let lines = contents.components(separatedBy: "\n").dropFirst()

    // Iterate over each line
    for line in lines {
        let columns = line.components(separatedBy: ",")

        if columns.count == 10 {
            let entry = PlayerEntry(
                playerID: columns[0],
                name: columns[1],
                position: columns[2],
                team: columns[3],
                sport: columns[4],
                opponent: columns[5],
                gameID: columns[6],
                lineScore: columns[7],
                statType: columns[8],
                startTime: columns[9]
            )
            result.append(entry)
        }
    }

    return result
}

// CSVParserService class to load and parse the CSV file
class CSVParserService {
    func loadCSVData(fileName: String, fileType: String = "csv") -> [PlayerEntry] {
        var playerEntries: [PlayerEntry] = []

        if let path = Bundle.main.path(forResource: fileName, ofType: fileType) {
            do {
                let contents = try String(contentsOfFile: path)
                playerEntries = parseCSV(contents: contents)
            } catch {
                print("Error reading the CSV file: \(error)")
            }
        } else {
            print("CSV file not found")
        }

        return playerEntries
    }
}
