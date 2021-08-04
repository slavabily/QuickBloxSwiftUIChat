//
//  ChatView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 15.07.2021.
//

import SwiftUI

struct ChatView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    private let chatManager = ChatManager.instance
    
    /**
     *  This property is required when creating a ChatViewController.
     */
    @Binding var dialogID: String!
    
    @State private var dialog: QBChatDialog!
    
    @State private var currentUserID: UInt = 0
    
    @State private var opponentUser = QBUUser()
    @State private var fullName = ""
    
    @StateObject private var dataSource = ChatDataSource()
    
    @State var composedMessage: String = ""
 
    var body: some View {
            NavigationView {
                VStack {
                    List {
                        ForEach(dataSource.messages, id: \.self) {
                            Text( $0.text ?? "No text")
                        }
                    }
                    HStack {
                        // this textField generates the value for the composedMessage @State var
                        TextField("Message...", text: $composedMessage)
                            .frame(minHeight: CGFloat(30))
                        // the button triggers the sendMessage() function written in the end of current View
                        Button(action: didPressSend) {
                            Text("Send")
                        }
                    }
                    .frame(minHeight: CGFloat(50)).padding()
                }
                
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack {
                                Label(fullName, systemImage: "person.crop.circle")
                                Text(fullName)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .navigationBarItems(leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                         Image("chevron")
                    }))
                    .navigationBarBackButtonHidden(true)
                    .blueNavigation
                    .onAppear {
                        self.dialog = chatManager.storage.dialog(withID: dialogID)
                        print("The current dialog is: \(dialog!)")
                        
                        let currentUser = Profile()
                        guard currentUser.isFull == true else {
                            return
                        }
                        
                        currentUserID = currentUser.ID
                        setupTitleView()
                        loadMessages(with: 0)
                    }
            }       
     }
    
    //MARK: Actions
    private func didPressSend() {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
//            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
//            inputToolbar.toggleSendButtonEnabled(isUploaded: self.isUploading)
            SVProgressHUD.dismiss()
            return
        }
         
        if composedMessage.isEmpty == false {
            send(withMessageText: composedMessage)
        }
    }
    
    private func send(withMessageText text: String) {
        let message = QBChatMessage.markable()
        message.text = text
        message.senderID = currentUserID
        message.dialogID = dialogID
        message.deliveredIDs = [(NSNumber(value: currentUserID))]
        message.readIDs = [(NSNumber(value: currentUserID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        sendMessage(message: message)
    }
    
    private func sendMessage(message: QBChatMessage) {
        chatManager.send(message, to: dialog) { (error) in
            if let error = error {
                debugPrint("[ChatViewController] sendMessage error: \(error.localizedDescription)")
                return
            }
            self.dataSource.addMessage(message)
            self.finishSendingMessage(animated: true)
        }
    }
    
    private func finishSendingMessage(animated: Bool) {
         
        composedMessage = ""
        
        loadMessages(with: 0)
    }
    
    private func loadMessages(with skip: Int = 0) {
        SVProgressHUD.show()
        chatManager.messages(withID: dialogID, skip: skip, limit: ChatManagerConstant.messagesLimitPerDialog, successCompletion: { (messages, cancel) in
            
            dataSource.messages = messages
            
            self.dataSource.addMessages(messages)
            SVProgressHUD.dismiss()
        }, errorHandler: { (error) in
            if error == ChatManagerConstant.notFound {
                self.dataSource.clear()
                self.dialog.clearTypingStatusBlocks()
            }
            SVProgressHUD.dismiss()
        })
    }
    
    
    //MARK: - Setup
    fileprivate func setupTitleView() {
        if dialog.type == .private {
            if let userID = dialog.occupantIDs?.filter({$0.uintValue != self.currentUserID}).first as? UInt {
                if let opponentUser = chatManager.storage.user(withID: userID) {
//                    chatPrivateTitleView.setupPrivateChatTitleView(opponentUser)
                    self.opponentUser = opponentUser
                    fullName = opponentUser.fullName ?? "Unknown user"
                } else {
                    ChatManager.instance.loadUser(userID) { (opponentUser) in
                        if let opponentUser = opponentUser {
                            
                            self.opponentUser = opponentUser
                            fullName = opponentUser.fullName ?? "Unknown user"
                        }
                    }
                }
            }
            
        } else {
//            title = dialog.name
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(dialogID: .constant("dialogID"))
    }
}
