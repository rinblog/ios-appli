//
//  MyProfileViewController.swift
//  
//
//  Created by tissue on 2018/05/03.
//

import UIKit
import Photos
import Firebase
import FirebaseDatabase

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableViewList: UITableView!
    
    // 選択した写真を取得する
    var imageUrl: String!
    
    let textList = ["都道府県", "嗜好", "支払い", "好きなお酒", "飲む量", "場所", "雰囲気"]
    let detailTextList = ["-", "-", "-", "-", "-", "-", "-"]
    
//    var pickerView: UIPickerView = UIPickerView()
    let prefecturesList = ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県",
                           "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県",
                           "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県",
                           "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県",
                           "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
                           "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県",
                           "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
                           "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
    let numPeopleList = ["-", "サシ飲み", "２対２", "複数飲み", "どちらでも"]
    let payList = ["-", "割り勘", "おごります", "おごってください", "どちらでも"]
    let drinkList = ["-", "ビール", "日本酒", "ワイン", "ウィスキー", "カクテル", "ハイボール", "なんでも"]
    let momentList = ["-", "一杯だけ", "少量", "たくさん", "どちらでも"]
    let shopTypeList = ["-", "大衆居酒屋", "専門店", "どちらでも"]
    let talkTypeList = ["-", "静かに", "わいわい", "どちらでも"]
    
    var preferencesItems: Dictionary<String, String> = ["location": "-", "numPeople": "-", "payment": "-", "drink": "-", "moment": "-", "shopType": "-", "talkType": "-"]
    let preferencesInfoList = ["location", "numPeople", "payment", "drink", "moment", "shopType", "talkType"]
    
    var usersItems: Dictionary<String, String> = [:]
    let usersInfoList = ["location", "imageUrl"]
    
    //ピッカービュー
    private var pickerView:UIPickerView!
    private let pickerViewHeight:CGFloat = 160
    
    //pickerViewの上にのせるtoolbar
    private var pickerToolbar:UIToolbar!
    private let toolbarHeight:CGFloat = 40.0
    
    private var pickerIndexPath: IndexPath?
    
    // 写真を表示するビュー
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        // デフォルトの画像を表示する
        imageView.image = UIImage(named: "default.png")
        
        //pickerView
        pickerView = UIPickerView(frame:CGRect(x:0,y:height + toolbarHeight, width:width,height:pickerViewHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.gray
        self.view.addSubview(pickerView)
        
        //pickerToolbar
        pickerToolbar = UIToolbar(frame:CGRect(x:0,y:height,width:width,height:toolbarHeight))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.doneTapped))
        pickerToolbar.items = [flexible,doneBtn]
        self.view.addSubview(pickerToolbar)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewList", for: indexPath)
        
        // セルに表示する値を表示する
        cell.textLabel?.text = textList[indexPath.row]
// TODO 必要なければ消す
//        cell.detailTextLabel?.text = detailTextList[indexPath.row]
        
        var ref: DatabaseReference!
        let myUserId = Auth.auth().currentUser?.uid
        ref = Database.database().reference()
        
        if indexPath.row == 0 {
//            cell.detailTextLabel?.text = usersItems[usersInfoList[0]]
            var myUserLocation:String?
            ref.child("users").child(myUserId!).observeSingleEvent(of: .value, with: { (snapshot) in
                let myUserInfo = snapshot.value as! [String:String]
                myUserLocation = myUserInfo["location"]
                cell.detailTextLabel?.text = myUserLocation
                self.tableViewList.reloadData()
            })
        } else {
            cell.detailTextLabel?.text = preferencesItems[preferencesInfoList[indexPath.row]]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択したセル情報を表示する
        //        print("cellNo:\(indexPath.row), word:\(tableList[indexPath.row])")
        
        // セルの選択解除
//        tableView.deselectRow(at: indexPath, animated: true)
        
        pickerIndexPath = indexPath
        
        //ピッカービューをリロード
        pickerView.reloadAllComponents()
        //ピッカービューを表示
        UIView.animate(withDuration: 0.2) {
            self.pickerToolbar.frame = CGRect(x:0,y:self.view.frame.height - self.pickerViewHeight - self.toolbarHeight, width:self.view.frame.width,height:self.toolbarHeight)
            self.pickerView.frame = CGRect(x:0,y:self.view.frame.height - self.pickerViewHeight, width:self.view.frame.width,height:self.pickerViewHeight)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // tableViewの選択セルに対応するpickerViewを返す
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerIndexPath?.row {
        case 0?:
            return prefecturesList.count
        case 1?:
            return numPeopleList.count
        case 2?:
            return payList.count
        case 3?:
            return drinkList.count
        case 4?:
            return momentList.count
        case 5?:
            return shopTypeList.count
        case 6?:
            return talkTypeList.count
            
        default:
            break
        }
        return 0
    }
    
    // tableViewの選択セルのrowを返す
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleList: Array<String>?
        switch pickerIndexPath?.row {
        case 0?:
            titleList = prefecturesList
        case 1?:
            titleList = numPeopleList
        case 2?:
            titleList = payList
        case 3?:
            titleList = drinkList
        case 4?:
            titleList = momentList
        case 5?:
            titleList = shopTypeList
        case 6?:
            titleList = talkTypeList
            
        default:
            break
        }
        
        return titleList?[row]
    }
    
    // pickerViewの選択rowを返す
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerIndexPath?.row {
        case 0?:
            self.tableViewList.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = prefecturesList[row]
        case 1?:
            self.tableViewList.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text = numPeopleList[row]
        case 2?:
            self.tableViewList.cellForRow(at: IndexPath(row: 2, section: 0))?.detailTextLabel?.text = payList[row]
        case 3?:
            self.tableViewList.cellForRow(at: IndexPath(row: 3, section: 0))?.detailTextLabel?.text = drinkList[row]
        case 4?:
            self.tableViewList.cellForRow(at: IndexPath(row: 4, section: 0))?.detailTextLabel?.text = momentList[row]
        case 5?:
            self.tableViewList.cellForRow(at: IndexPath(row: 5, section: 0))?.detailTextLabel?.text = shopTypeList[row]
        case 6?:
            self.tableViewList.cellForRow(at: IndexPath(row: 6, section: 0))?.detailTextLabel?.text = talkTypeList[row]
            
        default:
            break
        }
        
    }
    
    func cancel() {
        self.tableViewList.endEditing(true)
    }
    
    func done() {
        self.tableViewList.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func doneTapped(){
        UIView.animate(withDuration: 0.2){
            self.pickerToolbar.frame.origin.y = self.view.frame.height
            self.pickerView.frame.origin.y = self.view.frame.height + self.toolbarHeight
            self.tableViewList.contentOffset.y = 0
        }
        self.tableViewList.deselectRow(at: pickerIndexPath!, animated: true)
        
//        var usersItems: Dictionary<String, String> = [:]
        if pickerIndexPath?.row == 0 {
//          let usersInfoList = ["location", "imageUrl"]
            let cell = tableViewList.cellForRow(at: IndexPath(row: 0, section: 0))
            usersItems[usersInfoList[0]] = (cell?.detailTextLabel?.text)!
        } else {
            let cell = tableViewList.cellForRow(at: IndexPath(row: (pickerIndexPath?.row)!, section: 0))
            preferencesItems[preferencesInfoList[(pickerIndexPath?.row)!]] = (cell?.detailTextLabel?.text)!
        }
    }
    
    // カメラロールから写真を選択する処理
    @IBAction func choosePicture() {
        // カメラロールが利用可能か？
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 選択した写真を取得する
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        if info[UIImagePickerControllerOriginalImage] != nil {
            imageUrl = (info[UIImagePickerControllerImageURL] as! NSURL).absoluteString!
        }
        
        // ビューに表示する
        self.imageView.image = image
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
    
    // 写真をリセットする処理
    @IBAction func resetPicture() {
        // アラートで確認
        let alert = UIAlertController(title: "確認", message: "画像を初期化してもよいですか？", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction) -> Void in
            // デフォルトの画像を表示する
            self.imageView.image = UIImage(named: "default.png")
        })
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        // アラートにボタン追加
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        // アラート表示
        present(alert, animated: true, completion: nil)
    }
    
    // 設定を保存する
    @IBAction func saveSettingButton() {
        
        var usersItems: Dictionary<String, String> = [:]
//        var preferencesItems: Dictionary<String, String> = [:]
        var ref: DatabaseReference!
//        let userId = Auth.auth().currentUser?.uid
        ref = Database.database().reference()
        //storageを使えるようにする設定
        let storageRef = Storage.storage().reference()
        
        // firebaseのusersの設定
        let usersInfoList = ["location", "imageUrl"]
//        let cell = tableViewList.cellForRow(at: IndexPath(row: 0, section: 0))
//        usersItems[usersInfoList[0]] = (cell?.detailTextLabel?.text)!
        //ローカルファイルのパス
        var localFile: URL?
        if imageUrl != nil {
            localFile = URL(string: imageUrl)! //ここにローカルファイルのパスが入る
        }
        //storageからの参照を作成（uploadはまだしていない）
        var imageRef: StorageReference
        if imageUrl == nil {
            imageRef = storageRef.child("images/default.png")
            imageUrl = imageRef.fullPath
        } else {
            imageRef = storageRef.child("images/userIcon.png")
            imageUrl = imageRef.fullPath
            
            let _ = imageRef.putFile(from: localFile!, metadata: nil) { metadata, error in
                if error != nil {
                    // Uh-oh, an error occurred!
                    self.imageUrl = "default.png"
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    self.imageUrl = imageRef.name
                }
            }
        }
        usersItems[usersInfoList[1]] = imageUrl
        // firebaseのusersをアップデートする
        let userId = Auth.auth().currentUser?.uid
        ref.child("users").child(userId!).updateChildValues(usersItems)
        
        // firebaseのpreferencesの設定
//        for i in 1...5 {
//            let cell = tableViewList.cellForRow(at: IndexPath(row: i, section: 0))
//            preferencesItems[preferencesInfoList[i]] = (cell?.detailTextLabel?.text)!
//        }
        // firebaseのpreferencesをアップデートする
        ref.child("preferences").child(userId!).updateChildValues(preferencesItems)
    }
    
}
