//
//  AuthReponse.swift
//  OAuth-exemple
//
//  Created by Gabriel Lopes on 22/10/24.
//

import Foundation


struct AuthReponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
