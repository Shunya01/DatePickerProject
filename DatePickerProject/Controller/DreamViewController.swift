//
//  TaskViewController.swift
//  DatePickerProject
//
//  Created by 渡邉舜也 on 16/07/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import UIKit
import RealmSwift //追加が必要

class DreamViewController: UIViewController  {
    
    //変数名は小文字にするのが基本
    @IBOutlet weak var tableView: UITableView!
    
    var dreams : [Dream] = []

    override func viewDidLoad() {
        super.viewDidLoad()
       //tableViewを使う際のおまじない
       tableView.delegate = self
       tableView.dataSource = self
    
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    // 画面に表示される直前に呼ばれる。
    override func viewWillAppear(_ animated: Bool) {
        //Realmに接続
        let realm = try! Realm()
        //realmからDreamを全件取得して返している
        dreams = realm.objects(Dream.self).reversed()
        //tableViewにreloadでデータを反映させる
        tableView.reloadData()
    }
    
    //追加ボタンが押された時には追加画面へ画面遷移
    @IBAction func didClickAddButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toAdd", sender: nil)
    }
    
    //カレンダーボタンが押された時にはカレンダー画面へ画面遷移
    @IBAction func didClickCalendarButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toCalendar", sender: dreams)
    }
    
}

extension DreamViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dreams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dream = dreams[indexPath.row]
        
        //dream.dateはDate型なのでString型へ変更する
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy年MM月dd日"
        let dreamDate = dateformatter.string(from: dream.date)
        
        //セルのテキストにはタイトルと日付をセット
        cell.textLabel?.text = "\(dream.title) : \(dreamDate)"
        
        //セルに矢印をつける（他にも種類あり）
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択されたものを取得
        let dream = dreams[indexPath.row]
        
        performSegue(withIdentifier: "toDetail", sender: dream)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            //次の画面のControllerを取得
            let nextVC = segue.destination as! DreamDetailViewController
            //次の画面のdreamという変数にsenderに入れたこの画面のdreamをセット
            nextVC.dream = sender as? Dream
        }else if segue.identifier == "toCalendar"{
            //次の画面のControllerを取得
            let nextVC = segue.destination as! DreamCalendarViewController
            //次の画面のdreamという変数にsenderに入れたこの画面のdreamをセット
            nextVC.dream = sender as? Dream
        }
    }
    
    //選択したdreamをスワイプで削除する処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //Realmから対象のdreamを削除
        let dream = dreams[indexPath.row]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(dream)
        }
        //配列dreamsから対象のdreamを削除
        dreams.remove(at: indexPath.row)
        
        //画面から対象のdreamを削除
        tableView.deleteRows(at: [indexPath], with: .fade)
        
    }
    
}
