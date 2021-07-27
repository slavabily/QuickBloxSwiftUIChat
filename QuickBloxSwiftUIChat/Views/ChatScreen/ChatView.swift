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
    @Binding var dialogID: String! {
        didSet {
            self.dialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    @State private var dialog: QBChatDialog!
 
    var body: some View {
            NavigationView {
                Text("New dialogID: \(String(describing: dialogID))")
                    .navigationBarTitle("Chat Name", displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                         Image("chevron")
                    }))
                    .navigationBarBackButtonHidden(true)
                    .blueNavigation
            }       
     }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(dialogID: .constant("dialogID"))
    }
}
