//
//  CustomTableViewCell_PickerDate.swift
//  Prost
//
//  Created by 友寄 理 on 2018/05/20.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit

class CustomTableViewCell_PickerDate: UITableViewCell {

    @IBOutlet weak var column: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var delegate: DateCellDelegate! = nil

    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private var registrationView: RegistrationViewController?

    private let data = DataClass()
    private var userData: Dictionary<String, String> = [:]

    //pickerView
    private let pickerViewHeight: CGFloat = 160

    //誕生日picker
    private var datePicker: UIDatePicker!
    private let dateformatter = DateFormatter()

    //pickerViewの上にのせるtoolbar
    private var pickerToolbar:UIToolbar!
    private let toolbarHeight:CGFloat = 40.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        registrationView = appDelegate.registrationView
        let width = registrationView?.view.frame.width
        let height = registrationView?.view.frame.height

        //datePickerView
        self.datePicker = UIDatePicker(frame:CGRect(x:0, y:height! + toolbarHeight, width:width!, height: pickerViewHeight))
        self.datePicker.datePickerMode = UIDatePickerMode.date
        self.datePicker.backgroundColor = UIColor.gray
        registrationView?.view.addSubview(self.datePicker)
        
        dateformatter.dateFormat = "yyyy年M月dd日"
        

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
            print(appDelegate.cellIndexPath)
            print("誕生日のセル選択されたよ")
            
            //見た目変更selector登録するよ
            self.datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
            UIView.animate(withDuration: 0.2) {
                self.pickerToolbar.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)! - self.pickerViewHeight - self.toolbarHeight, width:(self.registrationView?.view.frame.width)!,height:self.toolbarHeight)
                self.datePicker.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)! - self.pickerViewHeight, width:(self.registrationView?.view.frame.width)!,height:self.pickerViewHeight)
            }
            
            self.delegate.datePickerDidSelect(cell: self)
        }
    }

    //見た目の反映
    @objc func datePickerValueChanged() {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy年M月dd日"
        
        self.dateLabel.text = dateformatter.string(from: self.datePicker.date)
    }
    

    @objc func doneTapped() {
        UIView.animate(withDuration: 0.2){
            self.pickerToolbar.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)!,
                                           width:(self.registrationView?.view.frame.width)!,height:self.toolbarHeight)

            self.datePicker.frame = CGRect(x:0,y:(self.registrationView?.view.frame.height)! + self.toolbarHeight,
                                           width:(self.registrationView?.view.frame.width)!,height:self.pickerViewHeight)

            self.registrationView?.RegistrationTable.contentOffset.y = 0
        }

        self.userData["birthday"] = self.dateLabel.text
        
        let now = Date()
        let birthday = self.dateformatter.date(from: self.dateLabel.text!)
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday!, to: now)
        let age = ageComponents.year!
        
        self.userData["age"] = String(describing: age)

        self.delegate.datePickerDidFinished(cell: "hoge", dictionary: self.userData)

        print("pickerView userData:", self.userData)
    }

}

//デリゲート先に適用してもらうプロトコル
protocol DateCellDelegate {
    func datePickerDidFinished(cell: Any, dictionary: Dictionary<String, String>)
    func datePickerDidSelect(cell: CustomTableViewCell_PickerDate)
}

