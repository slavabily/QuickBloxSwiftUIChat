//
//  DialogsView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 09.07.2021.
//

import SwiftUI

struct DialogsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    private let chatManager = ChatManager.instance
    
    @State private var dialogs: [QBChatDialog] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(cells, id: \.self) { cell in
                    Text(cell.textLabelText)
                }
             }
            .navigationBarItems(leading:
                                    Button(action: {
                                        didTapLogout()
                                    }, label: {
                                         Image("exit")
                                    }),
                                trailing: HStack {
                                    Button {
                                         
                                    } label: {
                                         
                                    }
                                    Button {
                                        
                                    } label: {
                                        
                                    }
                                })
            .navigationBarTitle(navigationTitle, displayMode: .inline)
            .blueNavigation
            .onAppear {
                dialogs = chatManager.storage.dialogsSortByUpdatedAt()
            }
        }
    }
    
    private var navigationTitle: String {
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return "Unknown user"
        }
        return currentUser.fullName.count > 0 ? currentUser.fullName : currentUser.login
    }
    
    private var cells: [DialogTableViewCellModel] {
        let cells = dialogs.map {
            DialogTableViewCellModel(dialog: $0)
        }
        return cells
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
            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    if let subscriptionsUIUD = subscriptions.first?.deviceUDID,
                       subscriptionsUIUD == uuidString,
                       subscription.notificationChannel == .APNS {
                        self.unregisterSubscription(forUniqueDeviceIdentifier: uuidString)
                        return
                    }
                }
            }
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
