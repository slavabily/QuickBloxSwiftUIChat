//
//  UsersSelection.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 24.07.2021.
//

import Foundation

class UsersSelection: ObservableObject {
    @Published var selectedUsers: Set<QBUUser> = []
    
    func isSelected(_ user: QBUUser) -> Bool {
        for _ in selectedUsers {
            if selectedUsers.contains(user) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func selection(of user: QBUUser) {
         
        if selectedUsers.contains(user) {
            selectedUsers.remove(user)
        } else {
            selectedUsers.insert(user)
        }
    }
}
