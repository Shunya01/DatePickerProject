//
//  StartViewController.swift
//  DatePickerProject
//
//  Created by 渡邉舜也 on 16/07/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    
   
    @IBOutlet weak var imageView: UIImageView!
    
    // 初期表示時に必要な処理を設定する。
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 画面に表示された直後に呼ばれる。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 50%まで縮小
        UIView.animate(
            withDuration: 0.5,
            delay: 0.5,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: { () in
                self.imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        },
            completion: { (Bool) in})
        
        // 8倍にする
        UIView.animate(
            withDuration: 0.6,
            delay: 1.0,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: { () in
                self.imageView.transform = CGAffineTransform(scaleX: 8.0, y: 8.0)
                self.imageView.alpha = 0
        },
            completion: { (Bool) in
                self.imageView.removeFromSuperview()
                self.performSegue(withIdentifier: "toNext", sender: nil)
        })
    }

}
