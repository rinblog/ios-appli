//
//  ProfileViewController.swift
//  Prost
//
//  Created by tissue on 2018/04/28.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let storageRef = Storage.storage().reference()
    
    // 写真を表示するビュー
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var prefecturesLabel: UILabel!
    @IBOutlet var numPeopleLabel: UILabel!
    @IBOutlet var payLabel: UILabel!
    @IBOutlet var drinkLabel: UILabel!
    @IBOutlet var momentLabel: UILabel!
    @IBOutlet var shopTypeLabel: UILabel!
    @IBOutlet var talkTypeLabel: UILabel!
    
    var otherUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otherUserId = appDelegate.userId!
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        // firstViewで選択した人の画像を表示する
        var otherUserIcon:String?
        ref.child("TEST_users").child(otherUserId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let otherUserInfo = snapshot.value as! [String:String]
            otherUserIcon = otherUserInfo["imageUrl"]
            
            var imageRef: StorageReference
            imageRef = self.storageRef.child(otherUserIcon!)
            
// TODO 写真の実装
            imageRef.downloadURL { url, error in
                if let _ = error {
                    // Handle any errors
                    print("エラーだよ")
                } else {
                    // Get the download URL for 'images/stars.jpg'
                    
                    let stringUrl = String(describing: url)
                    print("stringUrl:", stringUrl)

                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        print("ダウンロード開始だよ")

                        DispatchQueue.global().async{
                            DispatchQueue.main.async{
                                self.imageView.image = UIImage(data:data!)
                            }
                        }

                    }).resume()
                }
            }
// 写真の実装ここまで
            
//            let imagee:UIImage? = UIImage(named: imageRef)
//            if let validImage = imagee {
//                self.imageView = UIImageView(image: validImage)
//            } else {
//                // 画像がなかった場合の処理
//            }
            
//            imageRef.downloadURL { url, error in
//                if let error = error {
//                    print("error")
//                } else {
//                    imageView.image(with: url)
//                }
//            }
            
//            imageView.image(with: imageRef, placeholderImage: nil)
//            imageView.image = storageRef.child(imageRef)

//            imageView.image = UIImage(named: imageRef)
        })
        
        // firstViewで選択した人の都道府県を表示する
        var otherUserLocation:String?
        ref.child("TEST_users").child(otherUserId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let otherUserInfo = snapshot.value as! [String:String]
            // 都道府県
            otherUserLocation = otherUserInfo["location"]
            self.prefecturesLabel?.text = otherUserLocation
        })
        
        // firstViewで選択した人のプロフィール（都道府県以外）を表示する
        var otherUserNumPeople:String?
        var otherUserPay:String?
        var otherUserDrink:String?
        var otherUserMoment:String?
        var otherUserShopType:String?
        var otherUserTalkType:String?
        ref.child("TEST_preferences").child(otherUserId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let otherUserInfo = snapshot.value as! [String:String]
            // 嗜好
            otherUserNumPeople = otherUserInfo["numPeople"]
            self.numPeopleLabel?.text = otherUserNumPeople
            // 支払い
            otherUserPay = otherUserInfo["pay"]
            self.payLabel?.text = otherUserPay
            // 好きなお酒
            otherUserDrink = otherUserInfo["drink"]
            self.drinkLabel?.text = otherUserDrink
            // 飲む量
            otherUserMoment = otherUserInfo["moment"]
            self.momentLabel?.text = otherUserMoment
            // 場所
            otherUserShopType = otherUserInfo["shopType"]
            self.shopTypeLabel?.text = otherUserShopType
            // 雰囲気
            otherUserTalkType = otherUserInfo["talkType"]
            self.talkTypeLabel?.text = otherUserTalkType
        })
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favButton(_ sender: Any) {
        var ref: DatabaseReference!
        let userId: String = (Auth.auth().currentUser?.uid)!
        ref = Database.database().reference()
        
//        ref.child("userIdList").child("Rbf1RH1GOYRqf6KOR1c4wTRunab2").setValue([userId!: true])
        
// TO DO いいねボタン
        let key = ref.child("TEST_matches").childByAutoId().key
        ref.child("TEST_matches").child(key).setValue([userId: true, otherUserId!: false])
        ref.child("TEST_users").child(userId).child("waiting_room").setValue([key: true])
        
// いいねボタン実装ここまで
        
    }
}
