//
//  DreamCalendarViewController.swift
//  DatePickerProject
//
//  Created by 渡邉舜也 on 02/08/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift
import CalculateCalendarLogic//(年、月、日)を送ることで祝日ならTrue、通常の日ならfalseを返す関数

class DreamCalendarViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {

    @IBOutlet weak var calendar: FSCalendar!

    @IBOutlet weak var countLabel: UILabel!
    
    //前の画面から渡されてきたDreamを受け取る変数
    var dream: Dream? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // デリゲートの設定
        self.calendar.dataSource = self
        self.calendar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //getDreamCountメソッドを呼び出す
        getDreamCount()
        //calendarを作り直す
        calendar.reloadData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    //曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }
        
        return nil
    }
    
}

//  FSCalendarの日付に関する処理
extension DreamCalendarViewController {
    
    // 選択した日付の取得
     func calendar(_ calendar: FSCalendar, didSelect selectDate: Date, at monthPosition: FSCalendarMonthPosition) {
        let newDate = selectDate.addingTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT()))
        print(newDate)
//        //Realmに接続する
//        let realm = try! Realm()
//        //Dreamの全てを並び替えて取得する
//        let resultDream = realm.objects(Dream.self).filter("date == %@", newDate)
        
        var tmpList: Results<Dream>?
        let realm = try! Realm()
        let predicate = NSPredicate(format: "%@ =< date AND date < %@", getBeginingAndEndOfDay(newDate).begining as CVarArg, getBeginingAndEndOfDay(newDate).end as CVarArg)
        tmpList = realm.objects(Dream.self).filter(predicate)
        print(tmpList)
        //  日付選択時に詳細画面に遷移する
        performSegue(withIdentifier: "toDetail", sender: tmpList)
    }
    
    // カレンダーの日付を選択したときにHistoryViewControllerに選択した日付の情報を送る
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let nextVC = segue.destination as! DreamDetailViewController
            nextVC.dream = sender as? Dream
        }
    }
    
    // 日の始まりと終わりを取得
    private func getBeginingAndEndOfDay(_ date:Date) -> (begining: Date , end: Date) {
        let begining = Calendar(identifier: .gregorian).startOfDay(for: date)
        let end = begining + 24 * 60 * 60
        return (begining, end)
    }
    
    
    
}



//  Realmに関する処理
extension DreamCalendarViewController {
    
    //記録されたDreamの数を取得し表示させるメソッド
    func getDreamCount() {
        //Realmに接続する
        let realm = try! Realm()
        //Dreamの全てを並び替えて取得する
        let resultDream = realm.objects(Dream.self).sorted(byKeyPath: "date", ascending: true)
        //取得したPositivesの数をカウントして代入
        countLabel.text = String(resultDream.count)
        
        //日付の形を定義するための定数を定義する
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        //"yyyy/MM/dd"の形にするための宣言
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "ja_JP"))
        //  記録されているDreamsの日付を取得して変数に入れる
        var recordDays: [String] = []
        //同じ日付が変数に入っていなければ、入れない
        for dream in resultDream {
            if !recordDays.contains(formatter.string(from: dream.date))  {
                recordDays.append(formatter.string(from: dream.date))
            }
            
        }
    }
    
    
//  RealmDBから日付が最初(0時）と最後(24時)の間で設定されているデータを取得し、そのデータの数を返すようにすることで任意の日付に任意の数の点マークがつけられるようになる。
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int{
        var tmpList: Results<Dream>!
        // 対象の日付が設定されているデータを取得する
        do {
            let realm = try! Realm()
            let predicate = NSPredicate(format: "%@ =< date AND date < %@", getBeginingAndEndOfDay(date).begining as CVarArg, getBeginingAndEndOfDay(date).end as CVarArg)
            tmpList = realm.objects(Dream.self).filter(predicate)
        }
//        catch {
//        }
        return tmpList.count
    }

//    // 日の始まりと終わりを取得
//    private func getBeginingAndEndOfDay(_ date:Date) -> (begining: Date , end: Date) {
//        let begining = Calendar(identifier: .gregorian).startOfDay(for: date)
//        let end = begining + 24 * 60 * 60
//        return (begining, end)
//    }



}



