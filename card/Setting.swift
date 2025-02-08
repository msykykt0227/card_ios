//
//  Setting.swift
//  card
//
//  Created by msykykt on 2024/10/19.
//

import Foundation

enum PosType: String {
    case standard = "set_standard"
    case valley = "set_valley"
    case mountain = "set_mountain"
    case diamond = "set_diamond"
    
    static func index(_ t:PosType) -> Int {
        switch t {
        case .standard: return 0
        case .valley: return 1
        case .mountain: return 2
        case .diamond: return 3
        }
    }
    static func type(_ i:Int) -> PosType {
        switch i {
        case 0: return .standard
        case 1: return .valley
        case 2: return .mountain
        case 3: return .diamond
        default: return .standard
        }
    }
}

class Setting {
    static let instance: Setting = Setting()
    
    var showAlert: Bool = true
    var secret: Bool = false
    var host: String = ""
//    var maxnum : Int = 13
//    var maxtype: Int = 4
//    var maxpos: Int = 7
//    var postype: PosType = .standard
    var username: String = ""
    
    init() {
        showAlert = !UserDefaults.standard.bool(forKey: "showAlert") // 無値はfalseなので、標準はありにする
        secret = UserDefaults.standard.bool(forKey: "secret")
        host = UserDefaults.standard.string(forKey: "host") ?? "http://koruri.anime.coocan.jp/yukaridb/public/api"
        //"http://i5-mac-mini.local:8800/api"
        //"http://koruri.anime.coocan.jp"
        username = UserDefaults.standard.string(forKey: "username") ?? ""
    }
    
    func save() {
        UserDefaults.standard.set(!showAlert, forKey: "showAlert")
        UserDefaults.standard.set(secret, forKey: "secret")
//        UserDefaults.standard.set(host, forKey: "host")
        UserDefaults.standard.set(username, forKey: "username")
    }
    
}
