//
//  AuthView.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 09.07.2021.
//

import SwiftUI

struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToChat = NSLocalizedString("Enter to chat", comment: "")
    static let fullNameDidChange = NSLocalizedString("Full Name Did Change", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("No Internet Connection", comment: "")
    static let checkInternetMessage = NSLocalizedString("Make sure your device is connected to the internet", comment: "")
    static let enterUsername = NSLocalizedString("Enter your login and display name", comment: "")
    static let loginHint = NSLocalizedString("Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter.", comment: "")
    static let usernameHint = NSLocalizedString("Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row.", comment: "")
    static let defaultPassword = "quickblox"
    static let infoSegue = "ShowInfoScreen"
    static let showDialogs = "ShowDialogsViewController"
}

enum ErrorDomain: UInt {
    case signUp
    case logIn
    case logOut
    case chat
}

struct AuthView: View {
    
    @State private var login = ""
    @State private var displayName = ""
    @State private var dialogsViewIsPresented = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Login")) {
                    TextField("", text: $login)
                }
                Section(header: Text("Display name")) {
                    TextField("", text: $displayName)
                }
                
                 
                    Button("Login") {
                                signUp(fullName: displayName, login: login)
                    }
                    .font(.headline)
                    .padding()
                    .padding([.leading, .trailing], 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(30)
                    .position(x: 150, y: 25)
                
            }
            .navigationBarTitle("Enter to chat", displayMode: .inline)
            .sheet(isPresented: $dialogsViewIsPresented, content: {
                 DialogsView()
            })
            
        }   
    }
    
    //MARK: - Internal Methods
    /**
     *  Signup and login
     */
    private func signUp(fullName: String, login: String) {
        beginConnect()
        
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = LoginConstant.defaultPassword
        
        QBRequest.signUp(newUser) { response, user in
            self.login(fullName: fullName, login: login)
        } errorBlock: { response  in
            if response.status == QBResponseStatusCode.validationFailed {
                // The user with existent login was created earlier
                self.login(fullName: fullName, login: login)
                return
            }
            self.handleError(response.error?.error, domain: ErrorDomain.signUp)
        }
    }
    
    /**
     *  login
     */
    private func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
        beginConnect()
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { response, user in
                            user.password = password
                            Profile.synchronize(user)
                            
                            if user.fullName != fullName {
                                self.updateFullName(fullName: fullName, login: login)
                            } else {
                                self.connectToChat(user: user)
                            }
                            
            }, errorBlock: { response in
                self.handleError(response.error?.error, domain: ErrorDomain.logIn)
                if response.status == QBResponseStatusCode.unAuthorized {
                    // Clean profile
                    Profile.clearProfile()
//                    self.defaultConfiguration()
                }
        })
    }
    
    /**
     *  Update User Full Name
     */
    private func updateFullName(fullName: String, login: String) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: { response, user in
             
            Profile.update(user)
            self.connectToChat(user: user)
            
            }, errorBlock: { response in
                self.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
    
    /**
     *  connectToChat
     */
    private func connectToChat(user: QBUUser) {
         
        if QBChat.instance.isConnected == true {
            //did Login action
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                dialogsViewIsPresented.toggle()
            }
        } else {
            QBChat.instance.connect(withUserID: user.id,
                                    password: LoginConstant.defaultPassword,
                                    completion: { error in
                                         
                                        if let error = error {
                                            if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                // Clean profile
                                                Profile.clearProfile()
//                                                self.defaultConfiguration()
                                            } else {
                                                debugPrint(LoginConstant.checkInternet)
//                                                self.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
                                                self.handleError(error, domain: ErrorDomain.logIn)
                                            }
                                        } else {
                                            //did Login action
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                                dialogsViewIsPresented.toggle()
                                            }
                                        }
                                    })
        }
    }
    
    private func beginConnect() {
        /* to stop text fields editing;
         to show loging animation may be on a button
        */
    }
    
    // MARK: - Handle errors
    private func handleError(_ error: Error?, domain: ErrorDomain) {
        guard let error = error else {
            return
        }
        var infoText = error.localizedDescription
        print(infoText)
        if error._code == NSURLErrorNotConnectedToInternet {
            infoText = LoginConstant.checkInternet
        }
         
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
