//
//  RankView.swift
//  card
//
//  Created by msykykt on 2024/10/10.
//

import SwiftUI

// Xcode 13以上でInfo.plistを安全かつ簡単に作成する
// https://zenn.dev/ruwatana/articles/2045140478b1de

struct RegView: View {
    
    @Binding var doRegist: Bool
    @State var name: String = ""
    @State var did: String = String(localized: "set_nofound")
    @State var code: String = ""
    
    @State var errmsg:String = ""

    var body: some View {
        VStack {
//            HStack {
//                Spacer()
//                Button("×", action: {
//                    doRegist = false
//                }).padding()
//            }
            HStack {
                Text("rank_nickname").padding()
                TextField(String(localized:"set_nofound"), text: $name).frame(width: 150).border(Color.black, width: 1)
                Spacer()
            }
            HStack {
                Text("rank_regist")
                Spacer()
                Text("ID:")
                Text(did).padding()
            }
            TextEditor(text: $code).frame(height:100).border(Color.gray, width: 1).disabled(true)
            if errmsg.count > 0 {
                  Text(errmsg).foregroundColor(.red)
            }
            HStack {
                Button("rank_regist", action: {
                    UserDefaults.standard.set(name, forKey: "username")
                    RankData.registData(user: name, code: code, mcnt: CardDeck.share.moveCount, useSecret: CardDeck.share.keepSecret, cb: { newcode in
                        if CardDeck.checkDeck(newcode) {
                            CardDeck.share.readDeck(deck: newcode)
//                            UserDefaults.standard.set(did, forKey: "did")
                            doRegist = false
                        } else {
                            if newcode.prefix(1) == "#" {
                                errmsg = newcode

                            } else {
                                errmsg = String(localized: "rank_fail")
                            }
                        }
                    })
                }).padding(.trailing, 20)
                Button("rank_cancel", action: {
                    doRegist = false
                })
            }.padding(.top, 5)
        }.padding()
        .onAppear() {
            name = UserDefaults.standard.string(forKey: "username") ?? ""
            code = CardDeck.share.startDeck  ?? "no Data"
            did = CardDeck.share.did == 0 ? String(localized: "set_nofound") : String(CardDeck.share.did)
        }
    }
}

struct ReadDeck: View {
    @Binding var isRead: Bool
    @Binding var cardCode: String
    @Binding var selection: Int
    @State private var code:String = ""
    @State var rt:Bool = false

    var body: some View {
        
        VStack {
            // https://blog.code-candy.com/swiftui_textfield/
            TextEditor(text: $code)
            .frame(height: 100)
            .border(Color.gray, width: 1).padding()
            .onSubmit {
                close()
            }
            HStack {
                Spacer()
                Button("rank_update", action: {
                    close()
                })
                Spacer()
                Button("rank_cancel", action: {
                    isRead = false
                })
                Spacer()
            }
        }
        .alert("rank_error", isPresented: $rt, actions: { }, message:{ Text("rank_error_msg") })
    }
    
    func close() {
        let ret = !CardDeck.checkDeck(code)
        if ret {
            rt = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                self.rt = false
//            }
        } else {
            CardDeck.share.readDeck(deck: code)
            cardCode = code
            isRead = false
            selection = 1
        }
    }
}

struct RankView: View {
    @State var w: CGFloat = 640
    @State var h: CGFloat = 400
    @Binding var isRegist: Bool
    @Binding var selection: Int

    // https://ja.stackoverflow.com/questions/82490/swiftuiで-publishedの配列が即時に反映されない
    @StateObject var rank: RankData = RankData()
    @State var updId: Int = 0
    
    @State private var cardCode:String = ""
    @State var ShowSharePopover: Bool = false
    @State var isEntry: Bool = false
    @State var doRegist: Bool = false
    @State var isRead: Bool = false
    @State var readConfirm: Bool = false
    @State var errmsg: String = ""
    @State var iswifierr: Bool = false
    @State var isError: Bool = false
    
    @State private var charengeID:Int = 0
    
    @State private var forceUpd:Bool = false

    init(w: CGFloat, h: CGFloat, isRegist: Binding<Bool>, selection: Binding<Int>) {
        _isRegist = isRegist
        _selection = selection
        _w = State(initialValue: w)
        _h = State(initialValue: h)
    }
    
    var body: some View {
        
        VStack {
            // https://blog.code-candy.com/swiftui_textfield/
            TextEditor(text: $cardCode)
                .disabled(true)
                .frame(width: w*0.9, height:100)
                .border(Color.gray, width: 1)
                .padding()
            HStack {
                Button("rank_do_regist", action: {
                    let ob = NetworkObserver()
                    ob.startMonitoring(cb: { flg in
                        ob.stopMonitoring()
                        DispatchQueue.main.async {
                            if flg {
                                doRegist = true
                                isRegist = false
                            } else {
                                
                            }
                        }
                    })
                })
                .frame(width: w*0.33, height: 40)
                .disabled(isRegist ? false : true)
                Button("rank_share", action: {
//                    Share()
                    ShowSharePopover.toggle()
                    isRegist = false
                })
                .frame(width: w*0.33, height: 40)
                .disabled(isRegist ? false : true)
                Button("rank_read", action: {
                    isRead = true
                })
                .frame(width: w*0.33, height: 40)
                .disabled(!isRegist ? false : true)
            }.frame(width: w, height: 40)
            .alert("rank_wifi_error", isPresented: $iswifierr, actions: { Text("rank_wifi_msg")})
            if isRead {
                ReadDeck(isRead: $isRead, cardCode: $cardCode, selection: $selection).onDisappear {
                    updateRank()
                }
            }
            VStack{
                Text("rank_title_same").padding(.top, 10)
                if rank.userRank.count > 0 {
                    List {
                        // https://yakkylab.com/playgrounds-foreach/
                        Section (header: HStack{Text("rank_name"); Spacer(); Text("rank_score")}) {
                            // https://zenn.dev/kabeya/scraps/efd6be76abf082
                            ForEach(rank.userRank) { rnk in
                                //                            ForEach(rank.userRank.indices, id: \.self) { i in
                                //                                let rnk = rank.userRank[i]
                                HStack {
                                    let rn = String(format: "%4d", rnk.ir)+"  "+rnk.rank.user
                                    Text(rn)
                                    Spacer()
                                    Text(String(format:"%6.1f",Float(rnk.rank.score)/10.0)).frame(width: 60)
                                }
                                .contentShape(Rectangle()) // https://capibara1969.com/3510/
                                .onTapGesture {
                                    //                                    print("\(rnk.ir)")
                                }
                            }
                        }
                        // https://matsudamper.hatenablog.com/entry/2021/12/08/174132
                    }.environment(\.defaultMinListRowHeight, 30)
                        .frame(height:150).padding(.top, 0)//.id(rank.updcnt)
                } else {
                    Text("rank_nodata").frame(height: 150)
                }
                Text("rank_title").padding(.top, 10)
                if rank.rank.count > 0 {
                    List {
                        Section (header: HStack{Text("rank_name"); Spacer(); Text("rank_score")}) {
                            ForEach(rank.rank) { rnk in
//                            ForEach(rank.rank.indices, id: \.self) { i in
//                                let rnk = rank.rank[i]
                                HStack {
                                    let rn = String(format: "%4d", rnk.ir)+"  "+rnk.rank.user
                                    Text(rn)
                                    Spacer()
                                    Text(String(format:"%6.1f",Float(rnk.rank.score)/10.0)).frame(width: 60)
                                    Text((rnk.rank.useSecret == 0) ? " ":"*")
                                }
                                .contentShape(Rectangle()) // https://capibara1969.com/3510/
                                .onTapGesture {
                                    readConfirm.toggle()
                                    charengeID = rnk.rank.did
                                    print("\(rnk.ir)")
                                }
                            }
                        }.id(updId)
                    }.environment(\.defaultMinListRowHeight, 30)
                        .background(Color.gray.opacity(0.1))
                        .alert("rank_charenge", isPresented: $readConfirm) {
                            Button("OK") {
                                RankData.getData(did: charengeID) { code in
                                    if code.prefix(1) == "#" {
                                        errmsg = String(format: String(localized:"rank_charenge_error"),code)
                                        isError.toggle()
                                    } else {
                                        CardDeck.share.readDeck(deck: code)
                                        cardCode = code
                                        selection = 1
                                    }
                                }
                            }
                            Button("Cancel") {
                                
                            }
                        }
                        .alert("rank_get_error", isPresented: $isError, actions: {  }, message:{ Text(errmsg) })
                } else {
                    Text("rank_nodata")
                }
                Spacer()
            }.background(Color.gray.opacity(0.1))
        }.onAppear() {
            // https://stackoverflow.com/questions/68093282/remove-top-padding-from-list
            UITableView.appearance().contentInset.top = -20
            UICollectionView.appearance().contentInset.top = -20
            
            guard let _ = CardDeck.share.startDeck else { return }
            cardCode = CardDeck.share.startDeck!
            updateRank()
        }
//        .popover(isPresented: $ShowSharePopover) {
//            ShareView()
//        }
        .sheet(isPresented: $ShowSharePopover, onDismiss:   {
            print("shared")
            updateRank()
        }, content: {
            ShareView()
        })
        .sheet(isPresented: $doRegist, onDismiss: {
            print("registed")
            updateRank()
        }, content: {
            RegView(doRegist: $doRegist)
        })
        
    }
    
    private func updateRank() {
        print("updateRank")
        
        rank.downloadUser(did: CardDeck.share.did) { result in
            updId += 1
        }
    }
    // https://qiita.com/SNQ-2001/items/86646b661ccc4a7a9034
    // iPhone: ハーフモーダル
    // iPad: ポップアップ
/*    func Share() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ShowSharePopover = true
        } else {
            let link = URL(string: "http://koruri.anime.coocan.jp")!
            let keycode = CardDeck.share.startDeck!
            let activityViewController = UIActivityViewController(activityItems: [link,keycode], applicationActivities: nil)
            let excludedActivityTypes: Array<UIActivity.ActivityType> = [
                // UIActivityType.addToReadingList,
                // UIActivityType.airDrop,
                // UIActivityType.assignToContact,
                // UIActivityType.copyToPasteboard,
                // UIActivityType.mail,
                // UIActivityType.message,
                // UIActivityType.openInIBooks,
                // UIActivityType.postToFacebook,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToTencentWeibo
                // UIActivityType.postToTwitter,
                // UIActivityType.postToVimeo,
                // UIActivityType.postToWeibo,
                // UIActivityType.print,
                // UIActivityType.saveToCameraRoll,
                // UIActivityType.markupAsPDF
            ]
            activityViewController.excludedActivityTypes = excludedActivityTypes
            let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            let viewController = scene?.keyWindow?.rootViewController
            viewController?.present(activityViewController, animated: true, completion: nil)
        }
    }*/
}

struct ShareView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let link = URL(string: "http://koruri.anime.coocan.jp/yukaridb/public/card/store")!
        let code = "\(CardDeck.share.startDeck!)\nを\(CardDeck.share.moveCount)回でクリア\n"
        let activityItems: [Any] = [link,code]
        let activityViewController = UIActivityViewController( activityItems: activityItems, applicationActivities: nil)
        return activityViewController
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {
    }
}

 
//#Preview {
//    var comp:Binding<Bool> = .constant(true)
//    RankView(isComp: comp)
//}
