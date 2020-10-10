//
//  SecondViewController.swift
//  hige
//
//  Created by tissue on 2018/04/15.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewList: UITableView!
    private var userList: [String] = []
    
// TODO ↓tableViewCellに表示する人の名前のダミー値。後でDBの情報に変更する。
    // DBの情報をtableListに格納する
    //let tableList = ["", "い", "う"]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
//        let notificationName = Notification.Name("FinishedLoadData")
//        NotificationCenter.default.addObserver(self, selector: #selector(self.initCompleted(notification:)), name: notificationName, object: nil)
        getUsers()
// TODO -------マッチング処理ここから-------
//        var ref: DatabaseReference!
//        let myUserId = Auth.auth().currentUser?.uid
//        ref = Database.database().reference()
//
//        let otherUserId = "Rbf1RH1GOYRqf6KOR1c4wTRunab2"
//        // usersから相手の名前を取得する
//        var otherUserName:String?
//        ref.child("users").child(otherUserId).observeSingleEvent(of: .value, with: { (snapshot) in
//            let otherUserInfo = snapshot.value as! [String:String]
//            otherUserName = otherUserInfo["name"]
//        })
//
//        // userIdListから自分のIDのユーザーIDリストを取得する
//        var myUserIdList:[String:Bool] = [:]
//        ref.child("userIdList").child(myUserId!).observeSingleEvent(of: .value, with: { (snapshot) in
//            myUserIdList = snapshot.value as! [String : Bool]
//
//            // userIdListから相手のIDのユーザーIDリストを取得する
//            var otherUserIdList:[String:Bool] = [:]
//            ref.child("userIdList").child(otherUserId).observeSingleEvent(of: .value, with: { (snapshot) in
//                otherUserIdList = snapshot.value as! [String : Bool]
//
//                // 自分のユーザーIDリストに相手のユーザーIDがあれば実行する
//                for (key, _) in myUserIdList {
//                    print("key", key)
//                    if key == otherUserId {
//                        print("ほげ")
//                        // 相手のユーザーIDリストに自分のユーザーIDがあれば実行する
//                        for (key, _) in otherUserIdList {
//                            print(key)
//                            if key == myUserId {
//                                print("ひげ")
//                                // チャットリスト画面にマッチングした相手を表示する
//                                self.tableViewList.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text = otherUserName
//                            }
//                        }
//                    }
//                }
//            })
//        })
//        
//        ref.child("userIdList").child(otherUserId).setValue([myUserId!: true])
// TODO -------マッチング処理ここまで-------

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewList", for: indexPath)
        // セルに表示する値を表示する
        cell.textLabel?.text = self.userList[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択したセル情報を表示する
        //print("cellNo:\(indexPath.row), word:\(tableList[indexPath.row])")

        // セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)

        // "ChatViewController"に遷移する
        let next = storyboard!.instantiateViewController(withIdentifier: "ChatViewController")
        self.present(next, animated: true, completion: nil)
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func initCompleted(notification: Notification?) {
        
        // 読み終わったら、removeObserverをして,Obeserverを消す。
        NotificationCenter.default.removeObserver(self)
        tableViewList.reloadData()
    }
    
    func getUsers() {
        let ref = Database.database().reference()
        let user_id = Auth.auth().currentUser?.uid
        
        ref.child("TEST_users").child(user_id!).child("join_room").observeSingleEvent(of: .value, with: {(snapshot) in
            let join_room = snapshot.value as! [String: Bool]
            
            var count = 0
            for room_id in join_room.keys {
                ref.child("TEST_matches").child(room_id).observeSingleEvent(of: .value, with: {(snapshot) in
                    let member = snapshot.value as! [String: Bool]
                    for user in member.keys {
                        if user != user_id {
                            ref.child("TEST_users").child(user).child("name").observeSingleEvent(of: .value, with: {(snapshot) in
                                self.userList.append(snapshot.value as! String)
                                count += 1
                                if count == join_room.count {
                                    print("リロードしたよ")
                                    self.tableViewList.reloadData()
                                }
                            })
                        }
                    }
                })
            }
            
        })
    }
    
}

