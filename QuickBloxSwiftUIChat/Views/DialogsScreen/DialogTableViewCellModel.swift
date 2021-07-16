//
//  DialogTableViewCellModel.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 11.07.2021.
//

import Foundation

class DialogTableViewCellModel: NSObject {
    
    //MARK: - Properties
      var textLabelText: String = ""
      var unreadMessagesCounterLabelText : String?
      var unreadMessagesCounterHiden = true
      var dialogIcon : UIImage?
    
    //MARK: - Life Cycle
    init(dialog: QBChatDialog) {
        super.init()
        
        textLabelText = dialog.name ?? "UN"
        
        // Unread messages counter label
        if dialog.unreadMessagesCount > 0 {
            var trimmedUnreadMessageCount = ""
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            unreadMessagesCounterHiden = false
        } else {
            unreadMessagesCounterLabelText = nil
            unreadMessagesCounterHiden = true
        }
        // Dialog icon
        if dialog.type == .private {
            dialogIcon = UIImage(named: "user")
            
            if dialog.recipientID == -1 {
                return
            }
            // Getting recipient from users.
            if let recipient = ChatManager.instance.storage.user(withID: UInt(dialog.recipientID)),
                let fullName = recipient.fullName {
                self.textLabelText = fullName
            } else {
                ChatManager.instance.loadUser(UInt(dialog.recipientID)) { [weak self] (user) in
                    self?.textLabelText = user?.fullName ?? user?.login ?? ""
                }
            }
        } else {
            self.dialogIcon = UIImage(named: "group")
        }
    }
}
