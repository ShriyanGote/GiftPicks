//import Foundation
//import AWSS3
//
//class S3Manager {
//    private let bucketName = "savedatafromlambda"
//
//    func fetchAndParseJsonData(date: Date, completion: @escaping (Result<[String: Any], Error>) -> Void) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        let fileName = "\(dateFormatter.string(from: date)).json"
//
//        let expression = AWSS3TransferUtilityDownloadExpression()
//        expression.progressBlock = { (task, progress) in
//            DispatchQueue.main.async {
//                // This is where you can update a progress bar or similar UI component
//                print("Download Progress: \(progress.fractionCompleted)")
//            }
//        }
//
//        let transferUtility = AWSS3TransferUtility.default()
//        transferUtility.downloadData(
//            fromBucket: bucketName,
//            key: fileName,
//            expression: expression
//        ) { (task, url, data, error) in
//            DispatchQueue.main.async {
//                if let error = error {
//                    completion(.failure(error))
//                } else if let data = data {
//                    do {
//                        // Parse the JSON data
//                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                            completion(.success(json))
//                            print("JSON Data: \(json)")
//                        }
//                    } catch let parseError {
//                        completion(.failure(parseError))
//                    }
//                }
//            }
//        }
//    }
//}
//
