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
    private var alertController: AlertController?
    
    var launchCount: Int {
        get {
            if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                if let launchCount = UserDefaults.standard.value(forKey: "\(UserDefaultsKeys.launchCountInV)\(currentVersion)") as? Int {
                    return launchCount
                } else {
                    UserDefaults.standard.setValue(0, forKey: "\(UserDefaultsKeys.launchCountInV)\(currentVersion)")
                    return 0
                }
            }
            return 0
        } set {
            if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                UserDefaults.standard.setValue(newValue, forKey: "\(UserDefaultsKeys.launchCountInV)\(currentVersion)")
            }
        }
    }
    
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
    
    func sendContactUsEmail(from viewController: UIViewController)
    {
        guard MFMailComposeViewController.canSendMail() else {
            self.alertController = AlertController(message: "mailOpenFail".localize())
            self.alertController?.setBtn(title: "okayBtnTitle".localize(), handler: { })
            self.alertController?.showAlertBox()
            return
        }
        let mailComposeViewController = configuredMailComposeViewController()
        viewController.present(mailComposeViewController, animated: true, completion: nil)
    }
    
    func shareApp(from viewController: UIViewController) {
        let appShareMessage = [String(format: "appShareMessage".localize(), "appName".localize(), "")]
        let activityVC = UIActivityViewController(activityItems: appShareMessage, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        viewController.present(activityVC, animated: true, completion: nil)
    }
}

// MARK: - Private Methods
extension UtilsManager {
    private func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self

        mailComposeVC.setToRecipients([""])
        mailComposeVC.setSubject("\("appName".localize()) \("mailSubject".localize())")
        
        var appVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
            appVersion = version
        }
        let messageBody = String(format: "mailMessage".localize(), "appName".localize(), "\(UIDevice.current.systemVersion)", appVersion)
        
        mailComposeVC.setMessageBody(messageBody, isHTML: false)

        return mailComposeVC
    }
}

extension UtilsManager: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            debugPrint("Mail cancelled")
        case .saved:
            debugPrint("Mail saved")
        case .sent:
            debugPrint("Mail sent")
        case .failed:
            debugPrint("Mail sent failure: \(String(describing: error?.localizedDescription))")
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
