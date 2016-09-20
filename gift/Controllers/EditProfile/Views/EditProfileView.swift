//
// Created by Matan Lachmish on 12/09/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol EditProfileViewDelegate {
    func didUpdateForm()
    func didTapLoginWithFaceBook()
    func didTapDone()
}

class EditProfileView: UIView, UITextFieldDelegate {

    //Views
    private var descriptionLabel: UILabel!
    private var firstNameTextField: PaddedTextField!
    private var lastNameTextField: PaddedTextField!
    private var emailTextField: PaddedTextField!
    private var loginWithFacebookDescriptionLabel: UILabel!
    private var loginWithFaceBookButton: UIButton!
    private var doneButton: BigButton!

    //Public Properties
    var delegate: EditProfileViewDelegate!

    var firstName: String? {
        return firstNameTextField.text
    }

    var lastName: String? {
        return lastNameTextField.text
    }

    var email: String? {
        return emailTextField.text
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Initialization & Destruction
    //-------------------------------------------------------------------------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomViews()
        self.setConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addCustomViews() {
        self.backgroundColor = UIColor.gftBackgroundWhiteColor()

        if descriptionLabel == nil {
            descriptionLabel = UILabel()
            descriptionLabel.text = "EditProfileViewController.Description text".localized
            descriptionLabel.numberOfLines = 0
            descriptionLabel.textAlignment = NSTextAlignment.center
            descriptionLabel.font = UIFont.gftText1Font()
            descriptionLabel.textColor = UIColor.gftBlackColor()
            self.addSubview(descriptionLabel)
        }

        if firstNameTextField == nil {
            firstNameTextField = PaddedTextField()
            firstNameTextField.backgroundColor = UIColor.gftWhiteColor()
            firstNameTextField.placeholder = "EditProfileView.First Name".localized
            firstNameTextField.textAlignment = .right
            firstNameTextField.font = UIFont.gftText1Font()
            firstNameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
            firstNameTextField.delegate = self
            self.addSubview(firstNameTextField)
        }

        if lastNameTextField == nil {
            lastNameTextField = PaddedTextField()
            lastNameTextField.backgroundColor = UIColor.gftWhiteColor()
            lastNameTextField.placeholder = "EditProfileView.Last Name".localized
            lastNameTextField.textAlignment = .right
            lastNameTextField.font = UIFont.gftText1Font()
            lastNameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
            lastNameTextField.delegate = self
            self.addSubview(lastNameTextField)
        }

        if emailTextField == nil {
            emailTextField = PaddedTextField()
            emailTextField.backgroundColor = UIColor.gftWhiteColor()
            emailTextField.placeholder = "EditProfileView.Email address".localized
            emailTextField.textAlignment = .center
            emailTextField.font = UIFont.gftText1Font()
            emailTextField.clearButtonMode = UITextFieldViewMode.whileEditing
            emailTextField.keyboardType = .emailAddress
            emailTextField.delegate = self
            self.addSubview(emailTextField)
        }

        if loginWithFacebookDescriptionLabel == nil {
            loginWithFacebookDescriptionLabel = UILabel()
            loginWithFacebookDescriptionLabel.text = "EditProfileViewController.Login with facebook description text".localized
            loginWithFacebookDescriptionLabel.numberOfLines = 1
            loginWithFacebookDescriptionLabel.textAlignment = NSTextAlignment.center
            loginWithFacebookDescriptionLabel.font = UIFont.gftText1Font()
            loginWithFacebookDescriptionLabel.textColor = UIColor.gftBlackColor()
            self.addSubview(loginWithFacebookDescriptionLabel)
        }

        if loginWithFaceBookButton == nil {
            loginWithFaceBookButton = UIButton()

            loginWithFaceBookButton.setTitle("EditProfileViewController.Login with Facebook".localized, for: UIControlState())
            loginWithFaceBookButton.titleLabel!.font = UIFont.gftHeader1Font()
            loginWithFaceBookButton.setTitleColor(UIColor.gftWhiteColor(), for: UIControlState())

            loginWithFaceBookButton.setImage(UIImage(named:"facebookLogo"), for: UIControlState())
            loginWithFaceBookButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

            loginWithFaceBookButton.backgroundColor = UIColor.gftFacebookBlueColor()
            loginWithFaceBookButton.addTarget(self, action: #selector(didTapLoginWithFaceBook(sender:)), for: UIControlEvents.touchUpInside)

            self.addSubview(self.loginWithFaceBookButton)
        }

        if doneButton == nil {
            doneButton = BigButton()
            doneButton.setTitle("EditProfileViewController.Done Button".localized, for: UIControlState())
            doneButton.addTarget(self, action: #selector(didTapDone(sender:)), for: UIControlEvents.touchUpInside)
            doneButton.enable(enabled: false)
            self.addSubview(doneButton)
        }
    }

    private func setConstraints() {
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.superview!).offset(40)
            make.centerX.equalTo(descriptionLabel.superview!)
        }
        
        firstNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(50)
            make.centerX.equalTo(firstNameTextField.superview!)
            make.height.equalTo(44)
            make.width.equalTo(firstNameTextField.superview!)
        }
        
        lastNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameTextField.snp.bottom)
            make.centerX.equalTo(lastNameTextField.superview!)
            make.height.equalTo(44)
            make.width.equalTo(lastNameTextField.superview!)
        }
        
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(lastNameTextField.snp.bottom).offset(55)
            make.centerX.equalTo(emailTextField.superview!)
            make.height.equalTo(44)
            make.width.equalTo(emailTextField.superview!)
        }
        
        loginWithFacebookDescriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom).offset(55)
            make.centerX.equalTo(loginWithFacebookDescriptionLabel.superview!)
        }
        
        loginWithFaceBookButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginWithFacebookDescriptionLabel.snp.bottom).offset(12)
            make.centerX.equalTo(loginWithFaceBookButton.superview!)
            make.height.equalTo(44)
            make.width.equalTo(loginWithFaceBookButton.superview!)
        }
        
        doneButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(doneButton.superview!)
            make.height.equalTo(53)
            make.bottom.equalTo(doneButton.superview!)
            make.width.equalTo(doneButton.superview!)
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Public
    //-------------------------------------------------------------------------------------------
    func enableDoneButton(enabled: Bool) {
        doneButton.enable(enabled: enabled)
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Private
    //-------------------------------------------------------------------------------------------
    func didTapLoginWithFaceBook(sender: UIButton!) {
        guard let delegate = self.delegate
            else {
                Logger.error("Delegate not set")
                return
            }

        delegate.didTapLoginWithFaceBook()
    }

    func didTapDone(sender: UIButton!) {
        guard let delegate = self.delegate
            else {
                Logger.error("Delegate not set")
                return
            }

        delegate.didTapDone()
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - UITextFieldDelegate
    //-------------------------------------------------------------------------------------------
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Update delegate
        delegate.didUpdateForm()

        return true
    }
}