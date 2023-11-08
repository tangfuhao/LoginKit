//
//  SignupViewController.swift
//  LoginKit
//
//  Created by Daniel Lozano Valdés on 12/8/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import UIKit
import Validator

public protocol SignupViewControllerDelegate: class {

    func didSelectSignup(_ viewController: UIViewController, userName: String, name: String, password: String)
    func signupDidSelectBack(_ viewController: UIViewController)

}

open class SignupViewController: UIViewController, KeyboardMovable, BackgroundMovable {

    // MARK: - Properties

    public weak var delegate: SignupViewControllerDelegate?

	lazy var configuration: ConfigurationSource = {
		return DefaultConfiguration()
	}()

    var signupAttempted = false

    var signupInProgress = false {
        didSet {
            signupButton.isEnabled = !signupInProgress
        }
    }

    // MARK: Keyboard Movable

    var selectedField: UITextField?

    var offset: CGFloat = 0.0

    // MARK: Background Movable

    var movableBackground: UIView {
        get {
            return backgroundImageView
        }
    }

    // MARK: Outlet's

    @IBOutlet var fields: [SkyFloatingLabelTextField]!
    @IBOutlet weak var userNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var repeatPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var backgroundImageView: GradientImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signupButton: Buttn!

    // MARK: - UIViewController

	override open func viewDidLoad() {
        super.viewDidLoad()
		_ = loadFonts
        setupValidation()
        initKeyboardMover()
        initBackgroundMover()
        customizeAppearance()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

	override open func loadView() {
        self.view = viewFromNib(optionalName: "SignupViewController")
    }

	override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        destroyKeyboardMover()
    }

	override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Setup

    func customizeAppearance() {
        applyConfiguration()
        setupFonts()
    }
    
    func applyConfiguration() {
        view.backgroundColor = configuration.tintColor
        signupButton.setTitle(configuration.signupButtonText, for: .normal)

        backgroundImageView.image = configuration.backgroundImage
		backgroundImageView.gradientType = configuration.backgroundImageGradient ? .normalGradient : .none
        backgroundImageView.gradientColor = configuration.tintColor
        backgroundImageView.fadeColor = configuration.tintColor
        logoImageView.image = configuration.secondaryLogoImage

        userNameTextField.placeholder = configuration.userNamePlaceholder
        userNameTextField.errorColor = configuration.errorTintColor
        nameTextField.placeholder = configuration.namePlaceholder
        nameTextField.errorColor = configuration.errorTintColor
        passwordTextField.placeholder = configuration.passwordPlaceholder
        passwordTextField.errorColor = configuration.errorTintColor
        repeatPasswordTextField.placeholder = configuration.repeatPasswordPlaceholder
        repeatPasswordTextField.errorColor = configuration.errorTintColor
    }

    func setupFonts() {
        nameTextField.font = Font.montserratRegular.get(size: 13)
        userNameTextField.font = Font.montserratRegular.get(size: 13)
        passwordTextField.font = Font.montserratRegular.get(size: 13)
        repeatPasswordTextField.font = Font.montserratRegular.get(size: 13)
        signupButton.titleLabel?.font = Font.montserratRegular.get(size: 15)
    }

    // MARK: - Action's

    @IBAction func didSelectBack(_ sender: AnyObject) {
        delegate?.signupDidSelectBack(self)
    }

    @IBAction func didSelectSignup(_ sender: AnyObject) {
        guard let userName = userNameTextField.text, let name = nameTextField.text, let password = passwordTextField.text else {
            return
        }

        signupAttempted = true
        validateFields {
            delegate?.didSelectSignup(self, userName: userName, name: name, password: password)
        }
    }

}

// MARK: - Validation

extension SignupViewController {

    var equalPasswordRule: ValidationRuleEquality<String> {
        return ValidationRuleEquality<String>(dynamicTarget: { self.passwordTextField.text ?? "" },
                                              error: LoginValidationError.passwordNotEqual)
    }

    func setupValidation() {
        setupValidationOn(field: nameTextField, rules: ValidationService.nameRules)
        setupValidationOn(field: userNameTextField, rules: ValidationService.userNameRules)

        var passwordRules = ValidationService.passwordRules
        setupValidationOn(field: passwordTextField, rules: passwordRules)
        passwordRules.add(rule: equalPasswordRule)
        setupValidationOn(field: repeatPasswordTextField, rules: passwordRules)
    }

    func setupValidationOn(field: SkyFloatingLabelTextField, rules: ValidationRuleSet<String>) {
        var myField = field
        myField.validationRules = rules
        myField.validateOnInputChange(enabled: true)
        myField.validationHandler = validationHandlerFor(field: field)
    }

    func validationHandlerFor(field: SkyFloatingLabelTextField) -> ((ValidationResult) -> Void) {
        return { result in
            switch result {
            case .valid:
                guard self.signupAttempted == true else {
                    break
                }
                field.errorMessage = nil
            case .invalid(let errors):
                guard self.signupAttempted == true else {
                    break
                }
                if let errors = errors as? [ValidationError] {
                    field.errorMessage = errors.first?.message
                }
            }
        }
    }

    func validateFields(success: () -> Void) {
        var errorFound = false
        for field in fields {
            let result = field.validate()
            switch result {
            case .valid:
                field.errorMessage = nil
            case .invalid(let errors):
                errorFound = true
                if let errors = errors as? [ValidationError] {
                    field.errorMessage = errors.first?.message
                }
            }
        }
        if !errorFound {
            success()
        }
    }

}

// MARK: - UITextField Delegate

extension SignupViewController : UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedField = textField
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        selectedField = nil
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()

        let nextTag = textField.tag + 1
        let nextResponder = view.viewWithTag(nextTag) as UIResponder!

        if nextResponder != nil {
            nextResponder?.becomeFirstResponder()
        } else {
            didSelectSignup(self)
        }
        
        return false
    }
    
}
