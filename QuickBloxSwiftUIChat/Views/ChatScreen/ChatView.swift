//
//  ChatView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 15.07.2021.
//

import SwiftUI

struct ChatView: View {
    
    @Environment(\.presentationMode) var presentationMode
 
    var body: some View {
            NavigationView {
                Text("Chat View")
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
        ChatView()
    }
}
