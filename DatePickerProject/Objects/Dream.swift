//
//  Dream.swift
//  DatePickerProject
//
//  Created by 渡邉舜也 on 01/08/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import RealmSwift

class Dream: Object {
    //ID
    @objc dynamic var id: Int = 0
    //タイトル
    @objc dynamic var title: String = ""
    //内容
    @objc dynamic var content:String = ""
    //日付
    @objc dynamic var date = NSDate()
}
