//
//  RootView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 09.07.2021.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        if QBChat.instance.isConnected {
            print("\n Already connected to the chat\n")
            return AnyView(DialogsView())
        } else {
            print("\n Not connected to the chat\n")
            return AnyView(AuthView())
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
