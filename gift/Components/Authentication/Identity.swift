//
// Created by Matan Lachmish on 27/05/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import Locksmith
import XCGLogger

struct IdentityConsts {
    static let service = "gift"
    static let account = "me"
    static let userKey = "user"
    static let tokenKey = "token"
}


class Identity : NSObject {

    private let log = XCGLogger.defaultInstance()

    //Injected
    var launcher : Launcher //Property injected
    
    //Public properties
    var user : User?
    var token : Token?

    //-------------------------------------------------------------------------------------------
    // MARK: - Initialization & Destruction
    //-------------------------------------------------------------------------------------------
    internal dynamic init(launcher : Launcher) {
        self.launcher = launcher
        super.init()
        
        self.loadIdentityFromKeychain()
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Private
    //-------------------------------------------------------------------------------------------
    private func loadIdentityFromKeychain() {
        let keyChainDictionaryOpt = Locksmith.loadDataForUserAccount(IdentityConsts.account)
        if let keyChainDictionary = keyChainDictionaryOpt {
            self.user = keyChainDictionary[IdentityConsts.userKey] as? User
            self.token = keyChainDictionary[IdentityConsts.tokenKey] as? Token
            log.info("Successfully loaded account from keychain")
        } else {
            self.user = nil
            self.token = nil
            log.info("No accounts were found in keychain")
        }
    }
    
    private func storeIdentityInKeyChain() {
        guard let user = self.user
            else {
                log.severe("Missing user in identity")
                return //TODO:consider throw
            }
        
        guard let token = self.token
            else {
                log.severe("Missing token in identity")
                return
            }
        
        do {
            try Locksmith.updateData([IdentityConsts.userKey: user, IdentityConsts.tokenKey : token], forUserAccount: IdentityConsts.account)
            log.debug("Successfully stored account in keychain")

            //Broadcast event
            NSNotificationCenter.defaultCenter().postNotificationName(IdentityUpdatedEvent.name, object: nil)
        } catch {
            log.severe("Failed to store account in keychain")
        }
    }

    private func deleteIdentityFromKeyChain() {
        do {
            try Locksmith.deleteDataForUserAccount(IdentityConsts.account)
            log.debug("Successfully delete account from keychain")
        } catch {
            log.severe("Failed to delete account from keychain")
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Public
    //-------------------------------------------------------------------------------------------
    func setIdentity(user : User, token : Token) {
        self.user = user
        self.token = token

        self.storeIdentityInKeyChain()
    }
    
    func updateUser(user: User) {
        self.user = user
        
        self.storeIdentityInKeyChain()
    }
    
    func updateToken(token: Token) {
        self.token = token
        
        self.storeIdentityInKeyChain()
    }

    func logout() {
        log.info("Loging out...")
        self.deleteIdentityFromKeyChain()
        self.loadIdentityFromKeychain()
        self.launcher.launch(nil)
    }

    func isLoggedIn() -> Bool {
        return self.token != nil
    }

}
