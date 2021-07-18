//
//  CreateNewDialogView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 14.07.2021.
//

import SwiftUI

struct CreateNewDialogView: View {
    
//    @EnvironmentObject var settings: UserSettings
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var users : [QBUUser] = []
    private var selectedUsers: Set<QBUUser> = []
    private let chatManager = ChatManager.instance
    
    @State private var searchBarText = ""
    @State private var cancelSearchButtonisShown = false
    @State private var isSearch = false
    @State private var chatViewIsShown = false
 
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchBarText, isEditing: $cancelSearchButtonisShown)
     
                List(users.filter({ searchBarText.isEmpty ? true : $0.fullName!.contains(searchBarText)}), id: \.self) { user in
                    Text(user.fullName!)
                }
            }
            .sheet(isPresented: $chatViewIsShown, content: {
                ChatView()
                    .allowAutoDismiss { false }
            })
            .navigationBarTitle("New Chat", displayMode: .inline)
            
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
            }))
//            .environmentObject(settings)
//            .onAppear {
//                if settings.connected {
//
//                }
//            }
        }
        
    }
    
    func createChatButtonPressed() {
        //TODO: implement network request for chat creation
        // and UI configuration as appropriate
        
        chatViewIsShown.toggle()
    }
}

struct CreateNewDialogView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewDialogView()
    }
}
