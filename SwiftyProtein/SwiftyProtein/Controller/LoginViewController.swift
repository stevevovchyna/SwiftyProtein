//
//  LoginViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    
    @IBOutlet weak var enterButton: UIButton!
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground(forViewController: self.view)
        let context = LAContext()
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        let currentImage = context.biometryType == LABiometryType.faceID ? UIImage(named: "faceID") : UIImage(named: "touchID")
        enterButton.setImage(currentImage, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        authenticationWithTouchID()
    }
}


// MARK:- auth methods
extension LoginViewController {
    
    private func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"

        var authError: NSError?
        let reasonString = "To access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showLigands", sender: self)
                    }
                } else {
                    guard let error = evaluateError else { return }
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    if error._code == LAError.userFallback.rawValue {
                        self.authenticationWithPasscode()
                    } else { self.authenticationWithTouchID() }
                }
            }
        } else {
            guard let error = authError else { return }
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            self.authenticationWithPasscode()
        }
    }
    
    private func authenticationWithPasscode() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        var authError: NSError?
        let reasonString = "To access the secure data"
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showLigands", sender: self)
                    }
                } else {
                    guard let error = evaluateError else { return }
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    self.authenticationWithPasscode()
                }
            }
        } else {
            guard let error = authError else { return }
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    private func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        var message = ""
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
             message = "Authentication was not successful, because user failed to provide valid credentials"
         case LAError.appCancel.rawValue:
             message = "Authentication was canceled by application"
         case LAError.invalidContext.rawValue:
             message = "LAContext passed to this call has been previously invalidated"
         case LAError.notInteractive.rawValue:
             message = "Authentication failed, because it would require showing UI which has been forbidden by using interactionNotAllowed property"
         case LAError.passcodeNotSet.rawValue:
             message = "Authentication could not start, because passcode is not set on the device"
         case LAError.systemCancel.rawValue:
             message = "Authentication was canceled by system"
         case LAError.userCancel.rawValue:
             message = "Authentication was canceled by user"
         case LAError.userFallback.rawValue:
             message = "Authentication was canceled, because the user tapped the fallback button"
         case LAError.biometryNotAvailable.rawValue:
             message = "Authentication could not start, because biometry is not available on the device"
         case LAError.biometryLockout.rawValue:
             message = "Authentication was not successful, because there were too many failed biometry attempts and biometry is now locked"
         case LAError.biometryNotEnrolled.rawValue:
             message = "Authentication could not start, because biometric authentication is not enrolled"
            default:
                message = "Did not find error code on LAError object"
        }
        return message
    }

}
