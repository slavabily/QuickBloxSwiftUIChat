//
//  ChatView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 15.07.2021.
//

import SwiftUI

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

struct ChatView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    private let chatManager = ChatManager.instance
    
    var dialogID: String!
    
    @State private var dialog: QBChatDialog?
    
    @State private var currentUserID: UInt = 0
    
    @State private var opponentUser = QBUUser()
    @State private var fullName = ""
    
    @StateObject private var dataSource = ChatDataSource()
    @ObservedObject var chatStorage: ChatStorage
    
    @State var composedMessage: String = ""
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
 
    var body: some View {
                 VStack {
                    ScrollView {
                        HStack {
                            Spacer()
                            LazyVStack(alignment: .leading) {
                                ForEach(dataSource.messages.reversed(), id: \.self) { message in
                                    if message.senderID != currentUserID, message.readIDs?.contains(NSNumber(value: currentUserID)) == false {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(opponentUser.fullName ?? "No name")
                                                    .font(.footnote)
                                                Text( message.text ?? "No text")
                                                    .bold()
                                                    .padding(10)
                                                    .foregroundColor(Color.white)
                                                    .background(Color.gray)
                                                    .cornerRadius(20)
                                            }
                                        }
                                        .flip()
                                    } else {
                                        HStack {
                                            Spacer()
                                            VStack(alignment: .leading) {
                                                 Text("You")
                                                    .font(.footnote)
                                                 Text( message.text ?? "No text")
                                                    .bold()
                                                    .padding(10)
                                                    .foregroundColor(Color.white)
                                                    .background(Color.blue)
                                                    .cornerRadius(20)
                                            }
                                        }
                                        .flip()
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    .flip()
                    Spacer()
                    HStack {
                        TextField("Message...", text: $composedMessage)
                            .frame(minHeight: CGFloat(30))
                        Button(action: didPressSend) {
                            Text("Send")
                        }
                    }
                    .frame(minHeight: CGFloat(50)).padding()
                }
                .navigationBarBackButtonHidden(true)
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
                        timer.upstream.connect().cancel()
                    }, label: {
                         Image("chevron")
                    }))
                    .navigationBarBackButtonHidden(true)
                    .blueNavigation
                    .onAppear {
                        dialog = chatStorage.dialog(withID: dialogID)
                        print("The current dialog is: \(dialog!)")
                        
                        let currentUser = Profile()
                        guard currentUser.isFull == true else {
                            return
                        }
                        
                        currentUserID = currentUser.ID
                        setupTitleView()
                        loadMessages()
                    }
                    .onReceive(timer) { time in
                     loadMessages()
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
        chatManager.send(message, to: dialog!) { (error) in
            if let error = error {
                debugPrint("[ChatViewController] sendMessage error: \(error.localizedDescription)")
                return
            }
            self.dataSource.addMessage(message)
            chatManager.updateDialog(with: dialogID, with: message)
            self.finishSendingMessage(animated: true)
        }
    }
    
    private func finishSendingMessage(animated: Bool) {
         
        composedMessage = ""
        
        loadMessages()
    }
    
    private func loadMessages(with skip: Int = 0) {
        chatManager.messages(withID: dialogID, skip: skip, limit: ChatManagerConstant.messagesLimitPerDialog, successCompletion: { (messages, cancel) in
            
            dataSource.messages = messages
            
            self.dataSource.addMessages(messages)
            SVProgressHUD.dismiss()
        }, errorHandler: { (error) in
            if error == ChatManagerConstant.notFound {
                self.dataSource.clear()
                self.dialog!.clearTypingStatusBlocks()
            }
            SVProgressHUD.dismiss()
        })
    }
    
    
    //MARK: - Setup
    fileprivate func setupTitleView() {
        if dialog!.type == .private {
            if let userID = dialog!.occupantIDs?.filter({$0.uintValue != self.currentUserID}).first as? UInt {
                if let opponentUser = chatManager.storage.user(withID: userID) {
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
        let chatStorage = ChatStorage()
        ChatView(dialogID: chatStorage.dialogs[0].id, chatStorage: ChatStorage())
    }
}
