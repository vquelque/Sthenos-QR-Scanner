//
//  User.swift
//  SthenosScanner
//
//  Created by Valentin Quelquejay on 05.02.21.
//

import Foundation

struct User: Decodable {
    let firstName: String
    let lastName: String
    let gender: String
    let birthdate: Date
    let validSubscription: String
    let purchasedEntry: Date
    
    var genderString: String? {
        switch gender {
        case "male":
            return "Homme"
        case "female":
            return "Femme"
        case "other":
            return "Autre"
        default:
            return ""
        }
    }
}
