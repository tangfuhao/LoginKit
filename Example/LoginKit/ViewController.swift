//
//  ViewController.swift
//  LoginKit
//
//  Created by Daniel Lozano on 12/12/2016.
//  Copyright (c) 2016 Daniel Lozano. All rights reserved.
//

import UIKit
import ILLoginKit

class ViewController: UIViewController {

	var hasShownLogin = false

    lazy var loginCoordinator: LoginCoordinator = {
        return LoginCoordinator(rootViewController: self)
    }()

	lazy var loginViewController: OverridenLoginViewController = {
		let controller = OverridenLoginViewController()
		controller.delegate = self
		return controller
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
		guard !hasShownLogin else {
			return
		}

		hasShownLogin = true
		loginCoordinator.start()
		// present(loginViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - LoginViewController Delegate

extension ViewController: LoginViewControllerDelegate {

	func didSelectLogin(_ viewController: UIViewController, userName: String, password: String) {
		print("DID SELECT LOGIN; EMAIL = \(userName); PASSWORD = \(password)")
	}

	func didSelectForgotPassword(_ viewController: UIViewController) {
		print("LOGIN DID SELECT FORGOT PASSWORD")
	}

	func loginDidSelectBack(_ viewController: UIViewController) {
		print("LOGIN DID SELECT BACK")
	}

}
