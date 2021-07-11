//
//  DialogsView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 09.07.2021.
//

import SwiftUI

struct DialogsView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Dialogs View")
                Text("Dialogs View")
            }
            .navigationBarTitle("Dialogs View", displayMode: .inline)
                
        }
    }
}

struct DialogsView_Previews: PreviewProvider {
    static var previews: some View {
        DialogsView()
    }
}
