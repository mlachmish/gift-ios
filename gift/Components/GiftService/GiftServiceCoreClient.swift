//
// Created by Matan Lachmish on 24/05/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import XCGLogger

struct GiftServiceCoreClientConstants{
    static let BASE_URL_PATH = "http://localhost:8080/api"
    static let AUTHORIZATION_KEY = "api_key"
}

public class GiftServiceCoreClient : NSObject {

    private let log = XCGLogger.defaultInstance()

    //Injected
    var identity : Identity
    
    var manager : Manager!

    //-------------------------------------------------------------------------------------------
    // MARK: - Initialization & Destruction
    //-------------------------------------------------------------------------------------------
    internal dynamic init(identity : Identity) {
        self.identity = identity
        super.init()

        self.observeNotification()
        
        if (self.identity.isLoggedIn()) {
            self.updateAuthenticationHeaderFromIdentity()
        }
    }

    func observeNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GiftServiceCoreClient.onIdentityUpdatedEvent(_:)), name: IdentityUpdatedEvent.name, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Private
    //-------------------------------------------------------------------------------------------
    @objc private func onIdentityUpdatedEvent(notification: NSNotification) {
        self.updateAuthenticationHeaderFromIdentity()
    }
    
    private func updateAuthenticationHeaderFromIdentity() {
        guard let accessToken = self.identity.token?.accessToken
            else {
            log.severe("Expected access token")
                return
            }
        
        self.manager = Manager.getManagerWithAuthenticationHeader(GiftServiceCoreClientConstants.AUTHORIZATION_KEY, token: accessToken)
        
        self.manager.allowUnsecureConnection()
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Unauthorized
    //-------------------------------------------------------------------------------------------
    func verifyPhoneNumber(phoneNumber : String,
                           success: () -> Void,
                           failure: (error: ErrorType) -> Void)  {
        Alamofire.request(.POST, GiftServiceCoreClientConstants.BASE_URL_PATH+"/authorize/phoneNumberChallenge", parameters: ["phoneNumber": phoneNumber], encoding: .JSON).validate().responseData{ response in
            switch response.result {
            case .Success:
                success()
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
    
    func getToken(phoneNumber : String,
                  verificationCode : Int,
                  success: (token : Token) -> Void,
                  failure: (error: ErrorType) -> Void)  {
        
        Alamofire.request(.GET, GiftServiceCoreClientConstants.BASE_URL_PATH+"/authorize/token",
            parameters: ["phoneNumber": phoneNumber, "verificationCode" : verificationCode]).validate().responseObject { (response: Response<Token, NSError>) in
            switch response.result {
            case .Success:
                let token = response.result.value
                success(token: token!)
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Get
    //-------------------------------------------------------------------------------------------
    func ping() {
        manager.request(.GET, GiftServiceCoreClientConstants.BASE_URL_PATH+"/ping").validate().responseJSON { response in
            switch response.result {
            case .Success:
                debugPrint(response)
            case .Failure(let error):
                print(error)
            }
        }
    }

    func getMe(success: (user : User) -> Void,
               failure: (error: ErrorType) -> Void) {
        manager.request(.GET, GiftServiceCoreClientConstants.BASE_URL_PATH+"/user/").validate().responseObject { (response: Response<User, NSError>) in
            switch response.result {
            case .Success:
                let user = response.result.value
                success(user: user!)
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Post
    //-------------------------------------------------------------------------------------------
    func setFacebookAccount(facebookAccessToken :String,
                            success: (user : User) -> Void,
                            failure: (error: ErrorType) -> Void) {
        manager.request(.POST, GiftServiceCoreClientConstants.BASE_URL_PATH+"/user/facebook", parameters: ["facebookAccessToken": facebookAccessToken], encoding: .JSON).validate().responseObject { (response: Response<User, NSError>) in
            switch response.result {
            case .Success:
                let user = response.result.value
                success(user: user!)
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
}