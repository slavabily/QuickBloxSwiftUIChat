//
//  UsersSelection.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 24.07.2021.
//

import Foundation

class UsersSelection: ObservableObject {
    @Published var multiselection = Set<QBUUser>()
    
    func isSelected(_ user: QBUUser) -> Bool {
        for _ in multiselection {
            if multiselection.contains(user) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func selection(of user: QBUUser) {
         
        if multiselection.contains(user) {
            multiselection.remove(user)
        } else {
            multiselection.insert(user)
        }
    }
}
