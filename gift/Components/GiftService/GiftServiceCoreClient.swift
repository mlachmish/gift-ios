//
// Created by Matan Lachmish on 24/05/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

struct GiftServiceCoreClientConstants{
    static let BASE_URL_PATH = "http://localhost:8080/api"
    static let AUTHORIZATION_KEY = "api_key"
}

public class GiftServiceCoreClient : NSObject {

    //Injected
    var identity : Identity
    
    var manager : SessionManager!

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
        NotificationCenter.default.addObserver(self, selector: #selector(GiftServiceCoreClient.onIdentityUpdatedEvent(notification:)), name: NSNotification.Name(rawValue: IdentityUpdatedEvent.name), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Private
    //-------------------------------------------------------------------------------------------
    @objc private func onIdentityUpdatedEvent(notification: Notification) {
        self.updateAuthenticationHeaderFromIdentity()
    }
    
    private func updateAuthenticationHeaderFromIdentity() {
        guard let accessToken = self.identity.token?.accessToken
            else {
            Logger.severe("Expected access token")
                return
            }
        
        self.manager = SessionManager.getManagerWithAuthenticationHeader(header: GiftServiceCoreClientConstants.AUTHORIZATION_KEY, token: accessToken)
        
        self.manager.allowUnsecureConnection()
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Unauthorized
    //-------------------------------------------------------------------------------------------
    func verifyPhoneNumber(phoneNumber : String,
                           success: @escaping () -> Void,
                           failure: @escaping (_ error: Error) -> Void)  {
        
        let urlString = GiftServiceCoreClientConstants.BASE_URL_PATH+"/authorize/phoneNumberChallenge"
        let parameters: Parameters = ["phoneNumber": phoneNumber]
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData{ response in
            switch response.result {
            case .success:
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    func getToken(phoneNumber : String,
                  verificationCode : Int,
                  success: @escaping (_ token : Token) -> Void,
                  failure: @escaping (_ error: Error) -> Void)  {
        
        let urlString = GiftServiceCoreClientConstants.BASE_URL_PATH+"/authorize/token"
        let parameters: Parameters = ["phoneNumber": phoneNumber, "verificationCode" : verificationCode]
        
        Alamofire.request(urlString, method: .get, parameters: parameters).validate().responseObject { (response: DataResponse<Token>) in
            switch response.result {
            case .success:
                let token = response.result.value
                success(token!)
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Get
    //-------------------------------------------------------------------------------------------
    func ping() {
        manager.request(GiftServiceCoreClientConstants.BASE_URL_PATH+"/ping", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success:
                debugPrint(response)
            case .failure(let error):
                print(error)
            }
        }
    }

    func getMe(success: @escaping (_ user : User) -> Void,
               failure: @escaping (_ error: Error) -> Void) {
        manager.request(GiftServiceCoreClientConstants.BASE_URL_PATH+"/user/", method: .get).validate().responseObject { (response: DataResponse<User>) in
            switch response.result {
            case .success:
                let user = response.result.value
                success(user!)
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Post
    //-------------------------------------------------------------------------------------------
    func setFacebookAccount(facebookAccessToken :String,
                            success: @escaping (_ user : User) -> Void,
                            failure: @escaping (_ error: Error) -> Void) {
        
        let urlString = GiftServiceCoreClientConstants.BASE_URL_PATH+"/user/facebook"
        let parameters: Parameters = ["facebookAccessToken": facebookAccessToken]
        
        manager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseObject { (response: DataResponse<User>) in
            switch response.result {
            case .success:
                let user = response.result.value
                success(user!)
            case .failure(let error):
                failure(error)
            }
        }
    }
}
