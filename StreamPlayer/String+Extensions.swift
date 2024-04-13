//
//  String+Extensions.swift
//  StreamPlayer
//
//  Created by Knut on 08/04/2024.
//

import Foundation


extension String {
    
    var isValidWebURL: Bool {
        
        guard let asURL = URL(string: self),
              ["http", "https"].contains(asURL.scheme) &&
                asURL.host?.isEmpty == false else {
            return false
        }
        return true
    }
}
