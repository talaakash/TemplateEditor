//
//  StorageManager.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

enum Folders: String {
    case preview = "Previews"
    case images = "Images"
    case json = "Json"
    case pdfs = "Pdfs"
}

class StorageManager {
    static let shared = StorageManager()
    private init() { }
    
    func storeJson(with name: String, json: [String: Any], in folder: Folders) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            debugPrint("Failed to find document directory.")
            return nil
        }
        let folderURL = documentDirectory.appendingPathComponent(folder.rawValue)
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("Error creating folder: \(error)")
                return nil
            }
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let fileName = "\(name).json"
            let fileURL = folderURL.appendingPathComponent(fileName)
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            debugPrint("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getJson<T: Decodable>(inType: T.Type,with name: String) -> T? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentDirectory?.appendingPathComponent("\(name).json")
        do {
            let jsonData = try Data(contentsOf: fileURL ?? URL(fileURLWithPath: ""))
            let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
            return decodedObject
        } catch {
            debugPrint("Error reading JSON from file: \(error)")
            return nil
        }
    }
    
    func storeImage(image: UIImage, in folder: Folders) -> String? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            debugPrint("Failed to find document directory.")
            return nil
        }
        let folderURL = documentDirectory.appendingPathComponent(folder.rawValue)
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("Error creating folder: \(error)")
                return nil
            }
        }
        let fileName = UUID().uuidString.appending(".png")
        let fileURL = folderURL.appendingPathComponent(fileName)
        do {
            try image.pngData()?.write(to: fileURL)
            debugPrint("Image saved at path: \(fileURL.path)")
            return "\(folder.rawValue)/\(fileName)"
        } catch {
            debugPrint("Error saving image: \(error)")
            return nil
        }
    }
    
    func getImage(fileName: String) -> UIImage? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentDirectory?.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL ?? URL(fileURLWithPath: ""))
            return UIImage(data: imageData)
        } catch {
            debugPrint("Error loading image: \(error)")
            return nil
        }
    }
    
    func deleteFile(fileName: String) {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first, fileName != "" else {
            debugPrint("Failed to find document directory.")
            return
        }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        do {
            try fileManager.removeItem(at: fileURL)
            debugPrint("File deleted successfully: \(fileURL.path)")
            return
        } catch {
            debugPrint("Error deleting file: \(error.localizedDescription)")
            return
        }
    }
    
    func generatePdf(from images: [UIImage]) -> URL? {
        guard images.count > 0 else { return nil }
        let tempDirectory = FileManager.default.temporaryDirectory
        let pdfURL = tempDirectory.appendingPathComponent("\(UUID().uuidString).pdf")
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: images.first!.size.width, height: images.first!.size.height))
        
        do {
            try renderer.writePDF(to: pdfURL) { context in
                for image in images {
                    context.beginPage()
                    let imageSize = image.size
                    let aspectRatio = imageSize.width / imageSize.height
                    let pdfWidth: CGFloat = image.size.width
                    let pdfHeight: CGFloat = image.size.height
                    
                    // Calculate the frame for the image to maintain aspect ratio
                    let targetWidth = min(pdfWidth, pdfHeight * aspectRatio)
                    let targetHeight = min(pdfHeight, pdfWidth / aspectRatio)
                    let x = (pdfWidth - targetWidth) / 2
                    let y = (pdfHeight - targetHeight) / 2
                    let frame = CGRect(x: x, y: y, width: targetWidth, height: targetHeight)
                    
                    image.draw(in: frame)
                }
            }
            debugPrint("Temporary PDF Url: \(pdfURL)")
            return pdfURL
        } catch {
            print("Failed to create PDF: \(error)")
            return nil
        }
    }
}
