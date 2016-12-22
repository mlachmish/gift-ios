//
// Created by Matan Lachmish on 28/05/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import UIKit

class EditProfileViewController: UIViewController, EditProfileViewDelegate {

    // Injections
    private var appRoute: AppRoute
    private var identity: Identity
    private var facebookClient: FacebookClient
    private var userService: UserService

    //Views
    private var editProfileView: EditProfileView!

    //Controllers
    private var avatarViewController: AvatarViewController!

    //Public Properties
    var cancelEnabled: Bool = false

    var avatarURL: String?
    var firstName: String?
    var lastName:String?
    var email: String?

    //-------------------------------------------------------------------------------------------
    // MARK: - Initialization & Destruction
    //-------------------------------------------------------------------------------------------
    internal dynamic init(appRoute: AppRoute,
                          identity: Identity,
                          facebookClient: FacebookClient,
                          userService: UserService) {
        self.appRoute = appRoute
        self.identity = identity
        self.facebookClient = facebookClient
        self.userService = userService
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Lifecycle
    //-------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addCustomViews()
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBar()
        updateCustomViews()
    }

    private func setupNavigationBar() {
        self.title = "EditProfileViewController.Title".localized

        self.navigationController!.navigationBar.barStyle = .black
        self.navigationController!.navigationBar.barTintColor = UIColor.gftWaterBlueColor()
        self.navigationController!.navigationBar.tintColor = UIColor.gftWhiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.gftNavigationTitleFont()!, NSForegroundColorAttributeName: UIColor.gftWhiteColor()]

        let cancelBarButtonItem = UIBarButtonItem(title: "NavigationViewController.Cancel".localized, style: .plain, target: self, action: #selector(didTapCancel))
        cancelBarButtonItem.tintColor = UIColor.gftWhiteColor()
        cancelBarButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont.gftNavigationItemFont()!, NSForegroundColorAttributeName: UIColor.gftWhiteColor()], for: .normal)
        if cancelEnabled {
            self.navigationItem.rightBarButtonItem = cancelBarButtonItem
        }
    }

    private func addCustomViews() {
        if avatarViewController == nil {
            avatarViewController = AvatarViewController()
            avatarViewController.isEditable = true
            avatarViewController.emptyState = .image(image: UIImage(named: "emptyAvatarPlaceHolder"))
            self.addChildViewController(avatarViewController)
            avatarViewController.didMove(toParentViewController: self)
        }

        if editProfileView == nil {
            editProfileView = EditProfileView(avatarView: avatarViewController.view)
            editProfileView.delegate = self
            self.view = editProfileView
        }
    }
    
    private func updateCustomViews() {
        avatarViewController.imageURL = avatarURL

        editProfileView.firstName = firstName
        editProfileView.lastName = lastName
        editProfileView.email = email
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Private
    //-------------------------------------------------------------------------------------------
    private func updateUserProfile(avatarUrl: String? = nil, success: @escaping () -> Void, failure: @escaping () -> Void) {
        userService.updateUserProfile(firstName: editProfileView.firstName, lastName: editProfileView.lastName, email: editProfileView.email, avatarUrl: avatarUrl, success: { (user) in
            Logger.debug("Successfully updated user profile")
            self.identity.updateUser(user: user)
            success()
        }) { (error) in
            Logger.error("error while updating user profile: \(error)")
            self.showErrorUpdatingProfile()
            failure()
        }
    }

    private func uploadAvatarIfNeeded(success: @escaping (_ imageUrl : String?) -> Void, failure: @escaping () -> Void) {
        if avatarViewController.image == nil {
            success(nil)
            return
        }
        
        if avatarViewController.imageURL != nil {
            success(avatarViewController.imageURL)
            return
        }
        
        userService.uploadImage(image: avatarViewController.image!, success: { (avatarUrl) in
            Logger.debug("Successfully uploaded avatar")
            success(avatarUrl)
        }) { (error) in
            Logger.error("error while uploading avatar: \(error)")
            failure()
        }
    }

    private func showErrorUpdatingProfile() {
        let tryAgainAction = AlertViewAction(title: "Global.Try again".localized, style: .cancel, action: nil)
        let alertViewController = AlertViewControllerFactory.createAlertViewController(title: "EditProfileViewController.Alert failed updating user profile.Title".localized, description: "EditProfileViewController.Alert failed updating user profile.Description".localized, image: nil, actions: [tryAgainAction])
        self.present(alertViewController, animated: true, completion: nil)
    }

    func didTapCancel() {
        self.appRoute.dismiss(controller: self, animated: true)
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - EditProfileViewDelegate
    //-------------------------------------------------------------------------------------------
    func didUpdateForm() {
        let shouldEnableDoneButton =
            !(editProfileView.firstName ?? "").isEmpty &&
            !(editProfileView.lastName ?? "").isEmpty &&
            (editProfileView.email ?? "").isValidEmail

        editProfileView.enableDoneButton(enabled: shouldEnableDoneButton)
    }

    func didTapLoginWithFaceBook() {
        editProfileView.activityAnimation(shouldAnimate: true)
        self.facebookClient.login(viewController: self) { (error, facebookToken) in
            if (error) {
                Logger.error("error while login with facebook")
                self.editProfileView.activityAnimation(shouldAnimate: false)
            } else {
                self.userService.setFacebookAccount(facebookAccessToken: facebookToken!, success: { (user) in
                    Logger.debug("Successfully got user from facebook")
                    self.editProfileView.activityAnimation(shouldAnimate: false)
                    self.identity.updateUser(user: user)
                    self.appRoute.dismiss(controller: self, animated: true, completion: nil)
                }, failure: { (error) in
                    Logger.error("error while updating user account with facebook account: \(error)")
                    self.editProfileView.activityAnimation(shouldAnimate: false)
                })
            }
        }
    }

    func didTapDone() {
        editProfileView.activityAnimation(shouldAnimate: true)
        
        uploadAvatarIfNeeded(success: { (avatarUrl) in
            self.updateUserProfile(avatarUrl: avatarUrl, success: {
                self.editProfileView.activityAnimation(shouldAnimate: false)
                self.appRoute.dismiss(controller: self, animated: true)
            }, failure: { 
                self.editProfileView.activityAnimation(shouldAnimate: false)
                self.showErrorUpdatingProfile()
            })
        }, failure: {
            self.editProfileView.activityAnimation(shouldAnimate: false)
            self.showErrorUpdatingProfile()
        })
    }
}
