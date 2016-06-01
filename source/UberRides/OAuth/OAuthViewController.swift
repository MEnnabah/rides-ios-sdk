//
//  OAuthViewController.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

// MARK: View Controller Lifecycle

// View controller to users to enter credentials for OAuth.
@objc(UBSDKOAuthViewController)
class OAuthViewController: UIViewController {
    
    var scopes: [RidesScope]? {
        didSet {
            loginView.scopes = scopes
        }
    }
    
    var hasLoaded = false
    var loginView: LoginView
    
    /**
     Initializes the web view controller with the necessary information.
     
     - parameter scopes:            An array of scopes to request the user to authorize. (see RidesScope)
     
     - returns: An initialized OAuthWebViewController
    */
    @objc init(scopes: [RidesScope]) {
        loginView = LoginView(scopes: scopes)
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
     Initializer for storyboard. If using this, you must set your scopes before attempting
     to present this view controller
     
     - parameter aDecoder: the coder to use
     
     - returns: An initialized OAuthWebViewController, or nil if something went wrong
     */
    @objc required init?(coder aDecoder: NSCoder) {
        guard let loginView = LoginView(coder: aDecoder) else {
            self.loginView = LoginView(scopes: [])
            super.init(nibName: nil, bundle: nil)
            return nil
        }
        
        self.loginView = loginView
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        self.view.addSubview(loginView)
        self.setupLoginView()
        // Set up navigation item
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = LocalizationUtil.localizedString(forKey: "Sign in with Uber", comment: "Title of navigation bar during OAuth")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasLoaded {
            self.loginView.load()
        }
    }
    
    func cancel() {
        self.loginView.delegate?.loginView(self.loginView, didFailWithError: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UserCancelled))
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: View Setup
    
    func setupLoginView() {
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["loginView": self.loginView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[loginView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[loginView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
    }
}
