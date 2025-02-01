//
//  UtilsManager.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit
import MessageUI

final class UtilsManager: NSObject {
    static let shared = UtilsManager()
    private override init() { }
    
    func findValueInJson<T>(type: T.Type, key: String, json: [String: Any]) -> T? {
        for id in json.keys{
            if id == key, let value = json[id] as? T {
                return value
            } else if let innerJson = json[id] as? [String: Any] {
                let result = findValueInJson(type: type, key: key, json: innerJson)
                if let result {
                    return result
                }
            }
        }
        return nil
    }
    
    func generateAndGetPdfData(using images: [UIImage]) -> Data? {
        var pdfData: Data? = nil
        if let fileUrl = StorageManager.shared.generatePdf(from: images) {
            do {
                pdfData = try Data(contentsOf: fileUrl)
                try FileManager.default.removeItem(at: fileUrl)
            } catch {
                debugPrint("Error: \(error.localizedDescription)")
            }
        }
        return pdfData
    }
}
