//
//  CustomTableViewCell_PickerView.swift
//  Prost
//
//  Created by 友寄 理 on 2018/05/11.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit

class CustomTableViewCell_PickerView: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var column: UILabel!
    @IBOutlet weak var pickedData: UILabel!
    var delegate: PickerCellDelegate! = nil

    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private var registrationView: RegistrationViewController?

    private let data = DataClass()
    private var userData: Dictionary<String, String> = [:]

    //pickerView
    private var pickerView: UIPickerView!
    private let pickerViewHeight: CGFloat = 160
    
    //誕生日picker
    private var datePicker: UIDatePicker!

    //pickerViewの上にのせるtoolbar
    private var pickerToolbar:UIToolbar!
    private let toolbarHeight:CGFloat = 40.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        registrationView = appDelegate.registrationView
        let width = registrationView?.view.frame.width
        let height = registrationView?.view.frame.height

        //pickerView
        pickerView = UIPickerView(frame:CGRect(x:0,y:height! + toolbarHeight,
                                               width:width!,height:pickerViewHeight))

        pickerView.backgroundColor = UIColor.gray
        registrationView?.view.addSubview(pickerView)
        
        //datePickerView
        self.datePicker = UIDatePicker()
        self.datePicker.datePickerMode = UIDatePickerMode.date

        //pickerToolbar
        pickerToolbar = UIToolbar(frame:CGRect(x:0,y:height!,width:width!,height:toolbarHeight))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.doneTapped))
        pickerToolbar.items = [flexible,doneBtn]
        registrationView?.view.addSubview(pickerToolbar)
    }

    //cellが選択された状態の時の設定
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if selected {
            print("cell", appDelegate.cellIndexPath)


            pickerView.dataSource = self
            pickerView.delegate = self
                    
            pickerView.reloadAllComponents()
            //ピッカービューを表示
            UIView.animate(withDuration: 0.2) {
                self.pickerToolbar.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)! - self.pickerViewHeight - self.toolbarHeight, width:(self.registrationView?.view.frame.width)!,height:self.toolbarHeight)
                self.pickerView.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)! - self.pickerViewHeight, width:(self.registrationView?.view.frame.width)!,height:self.pickerViewHeight)
            }

            self.delegate.pickerDidSelect(cell: self)
            print("select終了")
        }
    }

    //選択肢の数 OK
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        print("選択肢の数だよ")
        if appDelegate.cellIndexPath?.row == 1 {
            return data.genderList.count
        } else {
            return data.locationList.count
        }
    }

    // OK
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("選べる行数")
        return 1
    }

    //表示する内容を指定する OK
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        print("pickerView表示する内容")
        if appDelegate.cellIndexPath?.row == 1 {
            return data.genderList[row]
        } else {
            return data.locationList[row]
        }
    }

    //選択された時 //見た目の反映OK
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        switch appDelegate.cellIndexPath?.row {
            case 1?:
                self.pickedData.text = data.genderList[row]
            case 3?:
                self.pickedData.text = data.locationList[row]
            default:
                break
        }
        
    }

    @objc func doneTapped(){
        UIView.animate(withDuration: 0.2){
            self.pickerToolbar.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)!,
                                              width:(self.registrationView?.view.frame.width)!,height:self.toolbarHeight)
            self.pickerView.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)! + self.toolbarHeight,
                                           width:(self.registrationView?.view.frame.width)!,height:self.pickerViewHeight)
            self.registrationView?.RegistrationTable.contentOffset.y = 0
        }

        if appDelegate.cellIndexPath?.row == 1 {
            self.userData["gender"] = self.pickedData.text
        } else {
            self.userData["location"] = self.pickedData.text
        }
        
        self.delegate.pickerDidFinished(cell: "hoge", dictionary: self.userData)
        
        print("pickerView userData:", self.userData)
    }
    
    @objc func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "yyyy/MM/dd";
        self.pickedData.text = dateFormatter.string(from: self.datePicker.date)
        self.userData["birthday"] = self.pickedData.text
    }

}

//デリゲート先に適用してもらうプロトコル
protocol PickerCellDelegate {
    func pickerDidFinished(cell: Any, dictionary: Dictionary<String, String>)
    func pickerDidSelect(cell: CustomTableViewCell_PickerView)
}

