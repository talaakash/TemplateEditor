//
//  UserType.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation

enum UserType {
    case free, paid
}

final class UserManager {
    static let shared = UserManager()
    var currentUserType: UserType = .free {
        didSet {
            switch currentUserType {
            case .free:
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isPremiumUnlocked)
            case .paid:
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isPremiumUnlocked)
            }
        }
    }
    
    var isUserLoggedIn: Bool {
//        return AuthManager.shared.loginStatus()
        return false
    }
    var currentUserId: String?
    
    private init(){ }
 
    func getUserType() -> UserType {
        return currentUserType
    }
    
    func setUserType(type: UserType){
        self.currentUserType = type
    }
}
