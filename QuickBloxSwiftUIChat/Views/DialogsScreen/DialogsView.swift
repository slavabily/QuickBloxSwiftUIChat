//
//  DialogsView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 09.07.2021.
//

import SwiftUI

struct DialogsConstant {
    static let dialogsPageLimit:Int = 100
    static let segueGoToChat = "goToChat"
    static let selectOpponents = "SelectOpponents"
    static let infoSegue = "PresentInfoViewController"
    static let deleteChats = "Delete Chats"
    static let forward = "Forward to"
    static let deleteDialogs = "deleteDialogs"
    static let chats = "Chats"
}

extension String: Identifiable {
    public var id: Int {
        return String().count
    }
}

struct DialogsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    private let chatManager = ChatManager.instance
    
    @StateObject var chatStorage = ChatStorage()
    
    @State var cndvIsPresented = false
 
    private var navigationTitle: String {
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return "Unknown user"
        }
        return currentUser.fullName.count > 0 ? currentUser.fullName : currentUser.login
    }
    
    var body: some View {
            List {
                ForEach(chatStorage.dialogs, id: \.self) { dialog in
                    NavigationLink(destination: ChatView(dialogID: dialog.id, chatStorage: chatStorage)) {
                        Text(dialog.name!)
                    }
                }
                .onDelete {
                    deleteDialogs(at: $0)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Button(action: {
                                        didTapLogout()
                                    }, label: {
                                        Image("exit")
                                    }),
                                trailing: HStack(spacing: 30) {
                                    Button {
                                        // TODO: navigation to info view
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .scaleEffect(1.5)
                                    }
                                    Button {
                                        cndvIsPresented.toggle()
                                    } label: {
                                        Image("add")
                                    }
                                })
            .navigationBarTitle(navigationTitle, displayMode: .inline)
            .blueNavigation
            .onAppear {
                fetchDialogs()
            }
            .sheet(isPresented: $cndvIsPresented) {
                CreateNewDialogView(chatStorage: chatStorage)
            }
    }
    
    func deleteDialogs(at offsets: IndexSet) {
        let i = Array<Int>(offsets)[0]
            
        let dialog = chatStorage.dialogs[i]
        
        guard let dialogID = dialog.id else {
            return
        }
        
        QBRequest.deleteDialogs(withIDs: Set([dialogID]),
                                forAllUsers: false,
                                successBlock: {
                                    response,
                                    deletedObjectsIDs, notFoundObjectsIDs, wrongPermissionsObjectsIDs in
                                    
                                    chatStorage.deleteDialog(withID: dialogID)
                                    
        }, errorBlock: { response in
            if (response.status == .notFound || response.status == .forbidden), dialog.type != .publicGroup {
                chatStorage.deleteDialog(withID: dialogID)
            }
            debugPrint(response.status)
        })
    }
    
    private func fetchDialogs() {
        let responsePage = QBResponsePage(limit: 50, skip: 0)
         QBRequest.dialogs(for: responsePage, extendedRequest: nil,
                          successBlock: { response, dialogs, dialogsUsersIDs, page in
 
                            chatStorage.update(dialogs:dialogs)
        }, errorBlock: { response in
            debugPrint("[ChatManager] loadDialog error: ...")
        })
    }
    
     private func didTapLogout() {
        guard Reachability.instance.networkConnectionStatus() != .notConnection else {
            debugPrint(LoginConstant.checkInternetMessage)
//            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            return
        }
        
        SVProgressHUD.show(withStatus: "SA_STR_LOGOUTING".localized)
        SVProgressHUD.setDefaultMaskType(.clear)
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let uuidString = identifierForVendor.uuidString
        #if targetEnvironment(simulator)
        disconnectUser()
        #else
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
//            if let subscriptions = subscriptions {
//                for subscription in subscriptions {
//                    if let subscriptionsUIUD = subscriptions.first?.deviceUDID,
//                       subscriptionsUIUD == uuidString,
//                       subscription.notificationChannel == .APNS {
//                        self.unregisterSubscription(forUniqueDeviceIdentifier: uuidString)
//                        return
//                    }
//                }
//            }
            self.disconnectUser()
            
        }) { (response) in
            if response.status.rawValue == 404 {
                self.disconnectUser()
            }
        }
        #endif
    }
    
    //MARK: - logOut flow
    private func disconnectUser() {
        QBChat.instance.disconnect(completionBlock: { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            self.logOut()
        })
    }
    
    private func logOut() {
        QBRequest.logOut(successBlock: { response in
            //ClearProfile
            Profile.clearProfile()
            self.chatManager.storage.clear()
//            CacheManager.shared.clearCache()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                presentationMode.wrappedValue.dismiss()
            }
            SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
        }) { response in
            debugPrint("[DialogsViewController] logOut error: \(response)")
        }
    }
}

struct DialogsView_Previews: PreviewProvider {
    static var previews: some View {
        DialogsView()
    }
}
