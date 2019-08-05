//
//  ViewController.swift
//  DatePickerProject
//
//  Created by 渡邉舜也 on 15/07/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import UIKit
import RealmSwift  //追加が必要

//クラス名は大文字始まり
class DreamAddController: UIViewController {

   //変数名は小文字始まり
    @IBOutlet weak var dreamTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dreamTextView: UITextView!
    @IBOutlet weak var dreamButton: UIButton!
    
    
    //前の画面から渡されてきたDreamを受け取る変数
    var dream: Dream? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Realmのブラウザを開く際のURLを表示させるためのもの
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        //日付の最大を今日にしている
        datePicker.maximumDate = NSDate() as Date
        
        //textViewに黒色の枠線をつける
        dreamTextView.layer.borderColor = UIColor.black.cgColor
        
        //textViewの枠の幅を設定
        dreamTextView.layer.borderWidth = 1.0
    }
    
    //この画面が開かれるたびに実行
    override func viewWillAppear(_ animated: Bool) {
        
        //編集ボタンが押されてきた時のみ
        if dream != nil{
            //テキストに編集前の値をセット
            dreamTextField.text = dream?.title
            dreamTextView.text = dream?.content
            //編集前の日付をセットする。
            datePicker.date = dream!.date
            //ボタンの名前を”夢編集”へと変える
            dreamButton.setTitle("夢編集", for: .normal)
        }
        
    }

    
    @IBAction func didClickButton(_ sender: UIButton) {
        
        //guard letを使うことにより奧深くに入って行かなくなる
        guard let text = dreamTextField.text else{
            //dreamtextField.textがnilの場合
            //ボタンがクリックされた時の処理を中断（return）
            return
        }
        
        //タイトルまたは詳細欄が空文字の場合
        if dreamTextField.text!.isEmpty || dreamTextView.text!.isEmpty{
            //alertで入力不足を通知
            let alert = UIAlertController(title: "入力不足", message: "タイトル欄または詳細欄が入力されていません。入力してください。", preferredStyle: .alert)
            //選択肢を作る
            let yesAction = UIAlertAction(title: "OK", style: .default) {
                (UIAlertAction) in
            }
            //選択肢の追加
            alert.addAction(yesAction)
            
            //アラートを表示する
            present(alert, animated: true, completion: nil)
            
            //登録する処理を中断する(return)
            return
        }
        
        //datePickerの値をdateの変数に入れる
        let date = datePicker.date
        
        //追加ボタンが押されている時
        if dream == nil{
            //Realmに登録する
            let realm = try! Realm()
            //データを登録する
            let dream = Dream()
            //最大のIDを取得
            let id = getMaxId()
            dream.id = id
            dream.title = text
            dream.content = dreamTextView.text
            dream.date = date
            
            //作成したDreamリストを登録する
            try! realm.write {
                realm.add(dream)
            }
            
            //入力完了のアラートを作成
            let completeAlert = UIAlertController(title: "記録完了", message: "おめでとうございます。記録が完了しました!!", preferredStyle: .alert)
            //OKの選択肢。ボタンを押した後に一覧画面へ画面遷移させる。
            let completeAction = UIAlertAction(title: "OK", style: .default) {
                (UIAlertAction) in
                //アラートが消えるのと画面遷移が重ならないように0.5秒後に画面遷移するようにしてる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // 0.5秒後に実行したい処理
                    //NavigationControllerの持っている履歴から１つ前の画面に戻る
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            //選択肢の追加
            completeAlert.addAction(completeAction)
            //アラートを表示する
            present(completeAlert, animated: true, completion: nil)
        }
        
        //編集ボタンが押されている時
        else if dream != nil {
            //更新
            let realm = try! Realm()
            try! realm.write {
                dream?.title = text
                dream?.content = dreamTextView.text
                dream?.date = date
            }
            
            //編集完了のアラート
            let completeAlert = UIAlertController(title: "編集完了", message: "記録の編集が完了しました!!", preferredStyle: .alert)
            //選択肢
            let completeAction = UIAlertAction(title: "OK", style: .default) {
                (UIAlertAction) in
                //アラートが消えるのと画面遷移が重ならないように0.5秒後に画面遷移するようにしてる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // 0.5秒後に実行したい処理
                    //NavigationControllerの持っている履歴から１つ前の画面に戻る
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
            //選択肢の追加
            completeAlert.addAction(completeAction)
            //アラートを表示する
            present(completeAlert, animated: true, completion: nil)
            
        }
    }
    
    func getMaxId() -> Int {
        //Realmに接続
        let realm = try! Realm()
        //Dreamシートから最大のIDを取得
        let id = realm.objects(Dream.self).max(ofProperty: "id") as Int?
        if id == nil{
            //最大IDが存在しない場合、１を返す
            return 1
        }else{
            //最大IDが存在する場合、最大ID ＋１を返す
            return id! + 1
        }
    }
    
    // viewを押下時にキーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
