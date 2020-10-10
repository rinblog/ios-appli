//
//  FirstViewController.swift
//  hige
//
//  Created by tissue on 2018/04/15.
//  Copyright © 2018年 rinInc. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let myAp = UIApplication.shared.delegate as! AppDelegate
//        myAp.myCount += 1
//        print("3画面目 count=\(myAp.myCount)")
    }
    
    // プロフィールボタン
    @IBAction func configButton(_ sender: Any) {
        let config = storyboard!.instantiateViewController(withIdentifier: "MyProfileViewController")
        self.present(config, animated: true, completion: nil)
    }
    
    
}


