//
//  ChatViewController.swift
//  Prost
//
//  Created by tissue on 2018/04/19.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.white
        navigationBar.delegate = self as? UINavigationBarDelegate;
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
//        navigationItem.title = contacts[Any].firstName
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "戻る", style:   UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButton))
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)

// TODO "senderDisplayName"は自分、"senderId"は「チャットリスト画面」で選択した相手の名前を格納する
        senderDisplayName = "hige"
        senderId = "hoge"
        let ref = Database.database().reference()
        ref.observe(.value, with: { snapshot in
            guard let dic = snapshot.value as? Dictionary<String, AnyObject> else {
                return
            }
            guard let posts = dic["messages"] as? Dictionary<String, Dictionary<String, AnyObject>> else {
                return
            }
            // keyとdateが入ったタプルを作る
            var keyValueArray: [(String, Int)] = []
            for (key, value) in posts {
                keyValueArray.append((key: key, date: value["date"] as! Int))
            }
            keyValueArray.sort{$0.1 < $1.1} // タプルの中のdate でソートしてタプルの順番を揃える(配列で) これでkeyが順番通りになる
            // messagesを再構成
            var preMessages = [JSQMessage]()
            for sortedTuple in keyValueArray {
                for (key, value) in posts {
                    if key == sortedTuple.0 {   // 揃えた順番通りにメッセージを作成
                        let senderId = value["senderId"] as! String!
                        let text = value["text"] as! String!
                        let displayName = value["displayName"] as! String!
                        preMessages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))
                    }
                }
            }
            self.messages = preMessages
            self.collectionView.reloadData()
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }

    // コメントの背景色の指定
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
    }

    // コメントの文字色の指定
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if messages[indexPath.row].senderId == senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.darkGray
        }
        return cell
    }

    // メッセージの数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    // ユーザのアバターの設定
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(
            withUserInitials: messages[indexPath.row].senderDisplayName,
            backgroundColor: UIColor.lightGray,
            textColor: UIColor.white,
            font: UIFont.systemFont(ofSize: 10),
            diameter: 30)
    }

    // 送信ボタンを押した時の処理
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        inputToolbar.contentView.textView.text = ""
        let ref = Database.database().reference()
        // 時間を取得し、int型に変換する。DBに、"自分"、"相手"、"メッセージ"、"時間"を送信する。
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHms"
        formatter.locale = Locale(identifier: "ja_JP")
        let now = Date()
        ref.child("messages").childByAutoId().setValue(["senderId": senderId, "text": text, "displayName": senderDisplayName, "date": Int(formatter.string(from: now))!])
    }

    // 「戻る」ボタン
    @objc func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
