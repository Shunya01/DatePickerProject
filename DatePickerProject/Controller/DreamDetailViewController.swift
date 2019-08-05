//
//  DreamDetailViewController.swift
//  DatePickerProject
//
//  Created by 渡邉舜也 on 02/08/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import UIKit

class DreamDetailViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    //前の画面から渡されてきたDreamを受け取る変数
    var dream: Dream? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy年MM月dd日"
        let Dreamdate = dateformatter.string(from: dream!.date)
        
        dateLabel.text = Dreamdate
        titleLabel.text = dream?.title
        detailLabel.text = dream?.content
    }
    
    //関数名は小文字始まり
    @IBAction func didClickButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toAdd", sender: dream)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAdd"{
            //次の画面のControllerを取得
            let nextVC = segue.destination as! DreamAddController
            
            nextVC.dream = sender as? Dream
        }
    }

}
