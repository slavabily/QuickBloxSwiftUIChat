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
    
    @State private var dataSource: ChatDataSource = {
        let dataSource = ChatDataSource()
        return dataSource
    }()
    
    @State var composedMessage: String = ""
 
    var body: some View {
            NavigationView {
                VStack {
                    List {
    //                    ForEach(dataSource.messages, id: \.self) { msg in
    //                        Text(msg.text ?? "No text")
    //                    }
                        Text("test msg")
                        Text("test msg")
                        Text("test msg")
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
         
//        if let messageText = currentlyComposedMessageText(), messageText.isEmpty == false {
//            send(withMessageText: messageText)
//        }
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
