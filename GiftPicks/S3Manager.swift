import Foundation
import Combine
import AWSS3

struct MyDataModel: Codable {
    let playerID: String
    let name: String
    let position: String
    let team: String
    let league: String
    let opponent: String
    let gameID: String
    let lineScore: Double
    let statType: String
    let startTime: String
    
    enum CodingKeys: String, CodingKey {
        case playerID = "Player_ID"
        case name = "Name"
        case position = "Position"
        case team = "Team"
        case league = "League"
        case opponent = "Opponent"
        case gameID = "Game_ID"
        case lineScore = "Line_Score"
        case statType = "Stat_Type"
        case startTime = "Start_Time"
    }
}


class S3Downloader: ObservableObject {
    func downloadJsonFile() {
        print("checking if working")
        let transferUtility = AWSS3TransferUtility.default()
        print("checking if working")
        transferUtility.downloadData(
            
            fromBucket: "savedatafromlambda",
            key: "SHYR-12345.json",
            expression: AWSS3TransferUtilityDownloadExpression()) { (task, url, data, error) in
                if let error = error {
                    print("Error downloading data: \(error.localizedDescription)")
                    
                    return
                }
                guard let data = data else {
                    print("Error: Data was nil.")
                    return
                }
                
                // Directly print the raw JSON data as a string for inspection
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received JSON data: \(jsonString)")
                } else {
                    print("Failed to convert data to text.")
                }
        }
        print("checking if working")
    }
    
}

