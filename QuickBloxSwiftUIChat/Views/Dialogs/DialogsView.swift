//
//  DialogsView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 09.07.2021.
//

import SwiftUI

struct DialogsView: View {
    
    private let chatManager = ChatManager.instance
    
    @State private var dialogs: [QBChatDialog] = []
    
    var cells: [DialogTableViewCellModel] {
        let cells = dialogs.map {
            DialogTableViewCellModel(dialog: $0)
        }
        return cells
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(cells, id: \.self) { cell in
                    Text(cell.textLabelText)
                }
             }
            .navigationBarTitle("Dialogs View", displayMode: .inline)
            .onAppear {
                dialogs = chatManager.storage.dialogsSortByUpdatedAt()
            }      
        }
    }
}

struct DialogsView_Previews: PreviewProvider {
    static var previews: some View {
        DialogsView()
    }
}
