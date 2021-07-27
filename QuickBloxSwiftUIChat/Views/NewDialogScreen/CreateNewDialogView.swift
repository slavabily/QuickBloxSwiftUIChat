//
//  CreateNewDialogView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 14.07.2021.
//

import SwiftUI

struct CreateNewDialogConstant {
    static let perPage:UInt = 100
    static let newChat = "New Chat"
    static let noUsers = "No user with that name"
}

struct CreateNewDialogView: View {
    
    @EnvironmentObject var settings: UserSettings
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var usersSelection = UsersSelection()
    
    @State private var users : [QBUUser] = []
    @State private var downloadedUsers : [QBUUser] = []
    private let chatManager = ChatManager.instance
    @State private var currentFetchPage: UInt = 1
    @State private var cancelFetch = false
    
    @State private var searchBarText = ""
    @State private var cancelSearchButtonisShown = false
    @State private var isSearch = false
    @State private var chatViewIsShown = false
    @State private var dialogID: String!
    
    var users_: [QBUUser] {
        if searchBarText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.fullName?.contains(searchBarText) ?? true
            }
        }
     }
    
    var navigationSubtitle: String {
        var users = "users"
        if usersSelection.multiselection.count == 1 {
            users = "user"
        }
        let numberOfUsers = "\(usersSelection.multiselection.count) \(users) selected"
        
        return numberOfUsers
    }
 
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                SearchBar(text: $searchBarText, isEditing: $cancelSearchButtonisShown)
                List(users_, id: \.self) { user in
                    UserCell(usersSelection: usersSelection, user: user)
                        .onTapGesture {
                            usersSelection.selection(of: user)
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { 
                    VStack {
                        Text(CreateNewDialogConstant.newChat).font(.headline)
                        Text(navigationSubtitle).font(.subheadline)
                    }
                    .foregroundColor(.white)
                    
                }
            }
            .sheet(isPresented: $chatViewIsShown, onDismiss: {
                presentationMode.wrappedValue.dismiss()
            }, content: {
                ChatView(dialogID: $dialogID)
                    .allowAutoDismiss { false }
            })
            .blueNavigation
            
            .navigationBarBackButtonHidden(true)
            
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image("chevron")
            }), trailing: Button(action: {
                // create chat view here
                createChatButtonPressed()
            }, label: {
                 Text("Create")
            }).disabled(usersSelection.multiselection.isEmpty))
            .onAppear {
                fetchUsers()
            }
        }
    }
     
    func createChatButtonPressed() {
        //TODO: implement network request for chat creation
        // and UI configuration as appropriate
        
        if Reachability.instance.networkConnectionStatus() == .notConnection {
             // TODO: show alert view asking user to check internet connection
            SVProgressHUD.dismiss()
            return
        }
        let selectedUsers = Array(usersSelection.multiselection)
        
        let isPrivate = selectedUsers.count == 1
        
        if isPrivate {
            // Creating private chat.
            SVProgressHUD.show()
            chatManager.storage.update(users: selectedUsers)
            guard let user = selectedUsers.first else {
                SVProgressHUD.dismiss()
                return
            }
            chatManager.createPrivateDialog(withOpponent: user, completion: { (response, dialog) in
                guard let d = dialog else {
                    if let error = response?.error {
                        SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
                    }
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)
                // TODO: submit opened new "dialog" to ChatView
//                self.openNewDialog(dialog)
                self.dialogID = d.id
                chatViewIsShown.toggle()
            })
        } else {
            print("Entering group dialog name...")
//            self.performSegue(withIdentifier: "enterChatName", sender: nil)
        }
        
        
    }
    
    private func fetchUsers() {
        SVProgressHUD.show()
        chatManager.fetchUsers(currentPage: currentFetchPage, perPage: CreateNewDialogConstant.perPage) { response, users, cancel in
            SVProgressHUD.dismiss()
            self.cancelFetch = cancel
            if cancel == false {
                self.currentFetchPage += 1
            }
            self.downloadedUsers.append(contentsOf: users)
            self.setupUsers(self.downloadedUsers )
        }
    }
    
    private func setupUsers(_ users: [QBUUser]) {
        var filteredUsers: [QBUUser] = []
        let currentUser = Profile()
        if currentUser.isFull == true {
            filteredUsers = users.filter({$0.id != currentUser.ID})
        }
        
        self.users = filteredUsers
        if usersSelection.multiselection.isEmpty == false {
            var usersSet = Set(users)
            for user in usersSelection.multiselection {
                if usersSet.contains(user) == false {
                    self.users.insert(user, at: 0)
                    usersSet.insert(user)
                }
            }
        }
//         checkCreateChatButtonState()
    }
}

struct CreateNewDialogView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewDialogView()
    }
}
