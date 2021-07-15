//
//  CreateNewDialogView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 14.07.2021.
//

import SwiftUI

struct CreateNewDialogView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var users : [QBUUser] = []
    
    @State private var searchText = ""
    
    var body: some View {
        
        VStack {
            SearchBar(text: $searchText)
 
            List(users.filter({ searchText.isEmpty ? true : $0.fullName!.contains(searchText)}), id: \.self) { user in
                Text(user.fullName!)
            }
        }
        .navigationBarTitle("New Chat", displayMode: .inline)
        
        .blueNavigation
        
        .navigationBarBackButtonHidden(true)
        
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image("chevron")
        }), trailing: Button(action: {
            // TODO: create new chat
        }, label: {
            Text("Create")
                .font(.title)
        }))
    }
        
}

struct CreateNewDialogView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewDialogView()
    }
}
