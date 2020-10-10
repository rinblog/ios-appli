//
//  FirstViewController.swift
//  hige
//
//  Created by tissue on 2018/04/15.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//class FirstViewController: UIViewController {

    @IBOutlet weak var usersTable: UITableView!
    let ref: DatabaseReference = Database.database().reference()
    var addHandle: DatabaseHandle?
    var changeHandle: DatabaseHandle?
    
    private var userList: Dictionary<Int, Dictionary<String, Any>> = [:]
    private var waitingRoom: Dictionary<String, Bool> = [:]
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let data: DataClass = DataClass()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("---viewDidLoad---")
        getUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("-----viewWillAppear-----")
        
        //マッチングした時に呼び出される
        self.changeHandle = ref.child("TEST_matches").observe(.childChanged, with: {(snapshot) in
            
            var default_message = self.data.defaultMessage
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHms"
            formatter.locale = Locale(identifier: "ja_JP")
            let now = Date()
            
            default_message.updateValue(Int(formatter.string(from: now))!, forKey: "timestamp")
            
            if let _ = self.waitingRoom[snapshot.key] {
                print("--自分のmatchesが変更されたよ--")
               
                // roomsにルームを追加,初期メッセージ登録,メンバーを登録
               
                let chat_room = self.ref.child("TEST_rooms").child(snapshot.key)
                chat_room.childByAutoId().setValue(default_message)
//                chat_room.child("users").setValue(snapshot.value as! [String: Bool])
               
                // users/currentUser.uidにjoin_roomを追加
                self.ref.child("TEST_users").child((Auth.auth().currentUser?.uid)!).child("join_room").setValue([snapshot.key: true])
                
                // users/currentUser.uidのwaiting_roomからsnapshot.keyを消す
                self.ref.child("TEST_users/\((Auth.auth().currentUser?.uid)!)/waiting_room/\(snapshot.key)").removeValue()
                
                // waitingRoomからsnapshot.keyを消す
                self.waitingRoom.removeValue(forKey: snapshot.key)
            }
            
        })
        
    }
    
// TODO 後で必要になりそうなメソッド
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
// TODO 後で必要になりそうなメソッド
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("-------セルの行数---------")
        
        return self.userList.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        print("セルの内容")
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath)

        let name = self.userList[indexPath.row]?["name"] as? String
        let age = self.userList[indexPath.row]?["age"] as? String
        let location = self.userList[indexPath.row]?["location"] as? String

        if name != nil {
            // セルに表示する値を設定する
            cell.textLabel!.text = name
            cell.detailTextLabel?.text = age! + "歳, " + location!
        }
        
        print("表示")

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択したセル情報を表示する
        print("cellNo:\(indexPath.row), word:\(String(describing: userList[indexPath.row]))")
        
        // セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userInfo = self.userList[indexPath.row]
        appDelegate.userId = userInfo?["user_id"] as! String
        
        // "ProfileViewController"に遷移する
        let next = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController")
        self.present(next, animated: true, completion: nil)
        self.navigationController?.pushViewController(next, animated: true)
    }

    func getUsers() {

        let start = Date()
        ref.child("TEST_users").observeSingleEvent(of: .value, with: {(snapshot) in
            let users = snapshot.children
            var count = 0

            for user_snap in users {
                let snap = user_snap as! DataSnapshot
                print(snap.key)
                self.userList[count] = snap.value as? [String: Any]
                self.userList.updateValue(["user_id": snap.key], forKey: count)
                count += 1
            }
            
            let s = Date()
            print("userlistに代入完了")
            let time = Date().timeIntervalSince(s)
            print("完了表示", time)
            self.usersTable.reloadData()

        }) { (error) in
            print("error")
        }
        
        ref.child("TEST_users").child((Auth.auth().currentUser?.uid)!).child("waiting_room").observe(.childAdded, with: {(snapshot) in
            
            self.waitingRoom.updateValue((snapshot.value != nil), forKey: snapshot.key)
        })
        
        let elapsed = Date().timeIntervalSince(start)
        print("処理にかかった時間", elapsed)

        print("-----getUserFinished-----")
        print(self.userList)
        self.usersTable.reloadData()
    }

    // 設定ボタン
    @IBAction func configButton(_ sender: Any) {
// TODO tableCellの押下遷移処理実装後、コメントアウト外して、91行目は削除する。
        let config = storyboard!.instantiateViewController(withIdentifier: "ChangeSearchViewController")
        self.present(config, animated: true, completion: nil)
        
//        ref.child("TEST_matches").child("hij").updateChildValues(["Rbf1RH1GOYRqf6KOR1c4wTRunab2": true])
        
    }


}

