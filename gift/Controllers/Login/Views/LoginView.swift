//
// Created by Matan Lachmish on 24/05/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

struct LoginViewConstants{
    static let PHONE_NUMBER_DIGITS = 10
}

protocol LoginViewDelegate{
    func didTapContinue()
}

class LoginView : UIView, UITextFieldDelegate {

    //Views
    private var giftTextualLogoImage: UIImageView!
    private var welcomeLabel: UILabel!
    private var boxesImage : UIImageView!
    private var phoneNumberTextField : UITextField!
    private var phoneNumberDisclaimerLabel: UILabel!
    private var continueButton: UIButton!

    //Private Properties
    var continueButtonBottomConstraint: Constraint? = nil

    //Public Properties
    var delegate: LoginViewDelegate!
    var phoneNumber : String {
        return self.phoneNumberTextField.text!.phoneNumberAsRawString()
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Initialization & Destruction
    //-------------------------------------------------------------------------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.observerNotifications()
        self.addCustomViews()
        self.setConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func observerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }

    private func addCustomViews() {
        self.backgroundColor = UIColor.gftBackgroundWhiteColor()

        giftTextualLogoImage = UIImageView(image: UIImage(named:"giftLogoTextual")!)
        self.addSubview(giftTextualLogoImage)

        welcomeLabel = UILabel()
        welcomeLabel.text = "LoginView.Welcome".localized
        welcomeLabel.textAlignment = NSTextAlignment.center
        welcomeLabel.font = UIFont.gftHeader1Font()
        welcomeLabel.textColor = UIColor.gftWaterBlueColor()
        self.addSubview(welcomeLabel)

        boxesImage = UIImageView(image: UIImage(named:"boxesIcon")!)
        self.addSubview(boxesImage)

        phoneNumberTextField = UITextField()
        phoneNumberTextField.backgroundColor = UIColor.gftWhiteColor()
        phoneNumberTextField.placeholder = "LoginView.Phone number place holder".localized
        phoneNumberTextField.textAlignment = NSTextAlignment.center
        phoneNumberTextField.font = UIFont.gftText1Font()
        phoneNumberTextField.keyboardType = UIKeyboardType.phonePad
        phoneNumberTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        phoneNumberTextField.delegate = self
        self.addSubview(phoneNumberTextField)

        phoneNumberDisclaimerLabel = UILabel()
        phoneNumberDisclaimerLabel.text = "LoginView.Phone number disclaimer".localized
        phoneNumberDisclaimerLabel.textAlignment = NSTextAlignment.center
        phoneNumberDisclaimerLabel.numberOfLines = 0
        phoneNumberDisclaimerLabel.font = UIFont.gftText1Font()
        phoneNumberDisclaimerLabel.textColor = UIColor.gftBlackColor()
        self.addSubview(phoneNumberDisclaimerLabel)

        continueButton = UIButton()
        continueButton.setTitle("LoginView.Continue Button".localized, for: UIControlState())
        continueButton.titleLabel!.font = UIFont.gftHeader1Font()
        continueButton.setTitleColor(UIColor.gftWhiteColor(), for: UIControlState())
        continueButton.backgroundColor = UIColor.gftAzureColor()
        continueButton.addTarget(self, action: #selector(LoginView.didTapContinue(sender:)), for: UIControlEvents.touchUpInside)
        enableContinueButton(enabled: false)
        self.addSubview(continueButton)
    }

    private func setConstraints() {
        giftTextualLogoImage.snp.makeConstraints { (make) in
            make.top.equalTo(giftTextualLogoImage.superview!).offset(35)
            make.centerX.equalTo(giftTextualLogoImage.superview!)
        }
        
        welcomeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(giftTextualLogoImage.snp.bottom).offset(10)
            make.centerX.equalTo(welcomeLabel.superview!)
        }
        
        boxesImage.snp.makeConstraints { (make) in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(25)
            make.centerX.equalTo(boxesImage.superview!)
        }
        
        phoneNumberTextField.snp.makeConstraints { (make) in
            make.top.equalTo(boxesImage.snp.bottom).offset(20)
            make.centerX.equalTo(phoneNumberTextField.superview!)
            make.height.equalTo(44)
            make.width.equalTo(phoneNumberTextField.superview!)
        }
        
        phoneNumberDisclaimerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(10)
            make.centerX.equalTo(phoneNumberDisclaimerLabel.superview!)
        }
        
        continueButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(continueButton.superview!)
            make.height.equalTo(53)
            make.width.equalTo(continueButton.superview!)
            continueButtonBottomConstraint = make.bottom.equalTo(continueButton.superview!).constraint
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - NSNotificationCenter
    //-------------------------------------------------------------------------------------------
    func keyboardWillShow(notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        continueButtonBottomConstraint?.update(offset: -1 * keyboardFrame.size.height)
        UIView.animate(withDuration: 1.0) {
            self.layoutIfNeeded()
        }
    }

    func keyboardWillHide(notification: Notification) {
        continueButtonBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 1.0) {
            self.layoutIfNeeded()
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Public
    //-------------------------------------------------------------------------------------------

    //-------------------------------------------------------------------------------------------
    // MARK: - Private
    //-------------------------------------------------------------------------------------------
    @objc private func didTapContinue(sender:UIButton!) {
        delegate!.didTapContinue()
    }

    private func enableContinueButton(enabled: Bool) {
        if (enabled) {
            continueButton.isEnabled = true
            continueButton.alpha = 1
        } else {
            continueButton.isEnabled = false
            continueButton.alpha = 0.5
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - UITextFieldDelegate
    //-------------------------------------------------------------------------------------------
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0

        //Prevent crashing undo bug
        if (range.length + range.location > currentCharacterCount){
            return false
        }

        let newLength = currentCharacterCount + string.characters.count - range.length

        //Format text as phone number
        if (newLength == 4 && string != "") {
            let formattedString = textField.text! + "-" + string
            textField.text = formattedString
            return false
        }

        if (newLength == 4 && string == "") {
            textField.text = String(textField.text!.characters.dropLast(2))
            return false
        }

        //Enable continue button
        enableContinueButton(enabled: newLength >= LoginViewConstants.PHONE_NUMBER_DIGITS + 1)

        return newLength <= LoginViewConstants.PHONE_NUMBER_DIGITS + 1
    }
}
