//
//  LoginViewController.swift
//  Prost
//
//  Created by 友寄 理 on 2018/04/28.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        //オブジェクトの初期化とかに良いかも
        print("----viewDidLoad----")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("----viewWillAppear----")
        //アプリのログイン状態確認
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                print("アプリログイン済み")
                print("userDefaultsの値", self.userDefault.bool(forKey: "registration"))
                if self.userDefault.bool(forKey: "registration") {
                    self.transition(view: "tabBarView")
                } else {
                    self.transition(view: "RegistrationView")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func clickLoginButton(_sender: Any) {
        self.loginFB()
    }
    
    func loginFB() {
        let loginManager = FBSDKLoginManager()

        loginManager.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            if (result?.isCancelled)! {
                print("キャンセルされました")
                return;
            }
            
            if error != nil {
                print("エラーが発生しました")
                print("アラート")
                return;
            }
            
            //firebase認証に戻る
            self.certification(token: (result?.token.tokenString)!)
        }
    }
    
    func certification(token: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let _ = error {
                // Login Error
                print("認証エラーだよアラート")
                return;
            }
        }
    }
    
    func transition(view: String) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: view)
        //nextViewに遷移
        self.present(nextView, animated: true, completion: nil)
    }
 
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout via LoginButton")
    }
    
}

