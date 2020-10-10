//
//  CustomTableViewCell_TextField.swift
//  Prost
//
//  Created by 友寄 理 on 2018/05/10.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit

class CustomTableViewCell_TextField: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var name: UITextField!
    
    var delegate:TextFieldCellDelegate! = nil
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private var registrationView: RegistrationViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.registrationView = appDelegate.registrationView
        
        //TextFieldのデリゲート先をselfにする
        name.delegate = self
        
        //キーボードのツールバー作成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.commitButtonTapped))
        
        kbToolBar.items = [spacer, commitButton]
        self.name.inputAccessoryView = kbToolBar
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //完了ボタンが押された時に呼ばれるメソッド
    @objc func commitButtonTapped (){
        self.name.endEditing(true)
    }
    
    //UITextFieldのデリゲートメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる。
        textField.resignFirstResponder()
        return true
    }
    
    //UITextFieldのデリゲートメソッド
    func textFieldDidEndEditing(_ textField: UITextField) {
        //テキストフィールドから受けた通知をデリゲート先に流す。
        print("デリゲート先に値を流すよ")
        self.delegate.textFieldDidEndEditing(cell: self, value:textField.text!)
    }
    
}

//デリゲート先に適用してもらうプロトコル
protocol TextFieldCellDelegate {
    func textFieldDidEndEditing(cell:CustomTableViewCell_TextField, value:String)
}
