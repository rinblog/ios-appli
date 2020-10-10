//
//  RegistrationViewController.swift
//  Prost
//
//  Created by 友寄 理 on 2018/05/03.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseDatabase

class RegistrationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TextFieldCellDelegate, PickerCellDelegate, DateCellDelegate {
    
    private var pickerViewCell: CustomTableViewCell_PickerView?
    private var datePickerCell: CustomTableViewCell_PickerDate?
    
    var handle: AuthStateDidChangeListenerHandle?
    private var userDefault = UserDefaults.standard
    private var user: User!
    private var auth: Auth!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let data: DataClass = DataClass()
    
    //Date PickerView
    private var datePickerView: UIDatePicker!
    private let datePickerViewHeight: CGFloat = 160

    //IndexPath
    private var CellIndexPath: IndexPath!
    
    private var name: UITextField?
    
    private var userData: Dictionary<String, String> = ["name": "unknown",
                                                        "gender": "男性",
                                                        "birthday": "1980年1月1日",
                                                        "location": "東京",
                                                        "age": "20",
                                                        "imageUrl": "images/default.png"]
    
    @IBOutlet weak var RegistrationTable: UITableView!
    
    override func viewDidLoad() {
        //オブジェクトの初期化とかに良いかも
        print("----viewDidLoad----")
        
        appDelegate.registrationView = self
        self.RegistrationTable.delegate = self
        
        //セルクラスの登録
        let textFieldXib = UINib(nibName:"CustomTableViewCell_TextField", bundle:nil)
        self.RegistrationTable.register(textFieldXib, forCellReuseIdentifier: "TextFieldCell")
        
        let pickerViewXib = UINib(nibName:"CustomTableViewCell_PickerView", bundle:nil)
        self.RegistrationTable.register(pickerViewXib, forCellReuseIdentifier: "PickerViewCell")
        
        let datePickerXib = UINib(nibName:"CustomTableViewCell_PickerDate", bundle:nil)
        self.RegistrationTable.register(datePickerXib, forCellReuseIdentifier: "DatePickerCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("----viewWillAppear----")
        //アプリのログイン状態確認
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                print("アプリログインエラー")
                return;
            }
            
            self.user = user
//            print("--------providerData--------")
//            let userInfo = self.user.providerData[0]
//
////            cell?.textLabel?.text = userInfo?.providerID
////            // Provider-specific UID
////            cell?.detailTextLabel?.text = userInfo?.uid
//            print(userInfo.displayName)
//            print(userInfo.email)
//            print(userInfo.photoURL)
//            print(userInfo.uid)
//            print(userInfo.providerID)
//
//            print("----------------")

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    //キーボード以外の場所をタップでキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("キーボード以外の場所タップしたよ")
        if let _ = self.name {
            self.name?.resignFirstResponder()
        }
    }
    
    // tableView setting
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("-----セルの個数-----")
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("-----セルの内容-----")
        
        // セルを取得する
        switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! CustomTableViewCell_TextField
                cell.name.text = ""
                cell.delegate = self
                self.name = cell.name
                
                return cell
            
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as! CustomTableViewCell_PickerView
                cell.column.text = "性別"
                cell.pickedData.text = userData["gender"]
                cell.delegate = self
            
                return cell
            
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! CustomTableViewCell_PickerDate
                cell.column.text = "生年月日"
                cell.dateLabel.text = userData["birthday"]
                cell.delegate = self
            
                return cell
            
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as! CustomTableViewCell_PickerView
                cell.column.text = "都道府県"
                cell.pickedData.text = userData["location"]
                cell.delegate = self
                
                return cell
            
            default:
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "RegistrationCell", for: indexPath)
                cell.textLabel?.text = "defaultCell"
                cell.detailTextLabel?.text = ""
                return cell
            
        }
    }
    
    // セルが選択された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("----IndexPath-----")
        appDelegate.cellIndexPath = indexPath
        print("registration", appDelegate.cellIndexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    //TextFieldが変更された時に呼ばれるメソッド
    func textFieldDidEndEditing(cell: CustomTableViewCell_TextField, value: String) {
        
        //値の変更を反映させる
        self.userData["name"] = value
    }

    //PickerViewが変更された時に呼ばれるメソッド
    func pickerDidFinished(cell: Any, dictionary: Dictionary<String, String>) {
        
        for (key, value) in dictionary {
            self.userData[key] = value
        }
    }
    
    //PickerViewCellが選択された時に呼ばれるメソッド
    func pickerDidSelect(cell: CustomTableViewCell_PickerView) {
        if self.pickerViewCell != nil {
            self.pickerViewCell?.doneTapped()
        }
        
        self.pickerViewCell = cell
        
        if self.datePickerCell != nil {
            self.datePickerCell?.doneTapped()
        }
    }
    
    //DatePickerが変更された時に呼ばれるメソッド
    func datePickerDidFinished(cell: Any, dictionary: Dictionary<String, String>) {
        for (key, value) in dictionary {
            self.userData[key] = value
        }
    }
    
    //DatePickerCellが選択された時に呼ばれるメソッド
    func datePickerDidSelect(cell: CustomTableViewCell_PickerDate) {
        self.datePickerCell = cell
        
        if self.pickerViewCell != nil {
            self.pickerViewCell?.doneTapped()
        }
    }
    
    
    @IBAction func clickStartButton(_sender: Any) {
        var preferences: Dictionary<String, String> = [:]
        var ref: DatabaseReference!
        let userId = Auth.auth().currentUser?.uid
        
        ref = Database.database().reference()
        
        //preferencesの項目を設定
        data.preferencesList.forEach { preference in
            preferences[preference] = ""
        }
        
        //キーボード閉じる処理(終わってない場合用)
        self.name?.resignFirstResponder()
        
        // ユーザ情報を保存する
//        sref.child("users").child(userId!).setValue(items)
        ref.child("TEST_preferences").child(userId!).setValue(preferences)
        ref.child("TEST_users").child(userId!).setValue(self.userData)
        
        //ref.child("userIdList").child(userId!).setValue(["user0": "-"])
        ref.child("TEST_matches").child(userId!).setValue(["user0": "-"])
        
        ref.child("TEST_users").child(userId!).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let setValue = snapshot.value as? NSDictionary
            if (setValue == NSDictionary(dictionary: self.userData)) {
                self.userDefault.set(true, forKey: "registration")
                self.transition()
            } else {
                print("DB保存に失敗")
            }
            
        }) { (error) in
            print("DB保存に失敗")
        }
        
    }
    
    func transition() {
        let storyboard: UIStoryboard = self.storyboard!
        let tabBarView = storyboard.instantiateViewController(withIdentifier: "tabBarView")
        //tabBarViewに遷移
        self.present(tabBarView, animated: true, completion: nil)
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout via LoginButton")
    }
    
}
