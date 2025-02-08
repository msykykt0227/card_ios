//
//  RankData.swift
//  card
//
//  Created by msykykt on 2024/10/20.
//

import Foundation

struct Rank: Codable {
    let mcnt: Int
    let score: Int
    let user: String
    let did: Int
    let date: String
    let useSecret:Int
}
struct IRank: Identifiable {
    var id = UUID()
    var ir = 0
    let rank:Rank
}

struct CodeRank: Codable {
    let rank:[Rank]
    let user:[Rank]
}

struct RegistData: Codable {
    let user:String
    let mcnt:Int
    let code:String
    let useSecret:Bool
}

struct UserInfoView: Codable {
    let uid:String
    let user:String
}

class RankData: ObservableObject {
    
    @Published var userRank:[IRank] = []
    @Published var rank:[IRank] = []

    func downloadUser(did:Int, cb:@escaping (Bool) -> Void) {
        guard let url = URL(string: Setting.instance.host + "/card/rank") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            request.httpBody = Data("{\"did\":\(did)}".utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let dt = data else { return }
            do {
//                print(String(data:dt, encoding: .utf8))
                let decoder = JSONDecoder()
                let rkdt = try decoder.decode(CodeRank.self, from: dt)
                var dtr:[IRank] = []
                var ir = 1
                rkdt.rank.forEach {rk in
                    dtr.append(IRank(ir:ir, rank:rk))
                    ir += 1
                }

                var dtu:[IRank] = []
                ir = 1
                rkdt.user.forEach {rk in
                    dtu.append(IRank(ir:ir, rank:rk))
                    ir = ir + 1
                }

                DispatchQueue.main.async {
                    self.rank = dtr
                    self.userRank = dtu
                    cb(true)
                }
                return
            } catch {
                print(error)
            }
            cb(false)
        }
        task.resume()
    }
    
/*    func downloadRank(host:String, cb:@escaping (Bool) -> Void) {
        guard let url = URL(string: host + "/card/rank") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let dt = data else { return }
            do {
                let decoder = JSONDecoder()
                self.rank = try decoder.decode([Rank].self, from: dt)
                cb(true)
                return
            } catch {
                print(error)
            }
            cb(false)
        }.resume()
    }*/
    
    static func cript(_ mcnt:Int) -> Int {
        var nwcnt = mcnt + CardDeck.share.max_num
        switch CardDeck.share.pos_type {
        case .standard:
            nwcnt = nwcnt ^ 0x15555
        case .valley:
            nwcnt = nwcnt ^ 0x1cccc
        case .mountain:
            nwcnt = nwcnt ^ 0x19999
        case .diamond:
            nwcnt = nwcnt ^ 0x1aaaa
        }
        return nwcnt
    }
    static func registData(user:String, code:String, mcnt:Int, useSecret:Bool, cb:@escaping (String) -> Void){
        let dt:RegistData = RegistData(user: user, mcnt: cript(mcnt), code: code, useSecret: useSecret)
        guard let url = URL(string: Setting.instance.host + "/card/regist") else {
            cb("#1")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(dt)
        } catch {
            print("Failed to encode deck")
            cb("#2")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let dt = data else { cb("#4"); return }
            if let newcode = String(data:dt, encoding: .utf8) {
                cb(newcode)
                return
            }
            cb("#3")
        }
        task.resume()
    }
    
    static func getData(did:Int, cb:@escaping (String) -> Void){
        guard let url = URL(string: Setting.instance.host + "/card/getdata") else {
            cb("#1")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            request.httpBody = Data("{\"did\":\(did)}".utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let dt = data else { cb(""); return }
            if let code = String(data:dt, encoding: .utf8) {
                if CardDeck.checkDeck(code) {
                    cb(code)
                } else {
                    cb("#3")
                }
                return
            }
            cb("#2")
        }
        task.resume()
    }
}
