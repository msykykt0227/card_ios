//
//  CardsView.swift
//  card
//
//  Created by msykykt on 2024/10/10.
//

import SwiftUI
struct InfoView: View {
    @State var winW: CGFloat
    @State var winH: CGFloat
    var body: some View {
        Spacer()
        HStack {
            Text(String(format:String(localized: "card_number"), CardType.numRep(CardDeck.share.max_num))).padding(.trailing, 30)
            Text(String(format: String(localized:"card_move"), CardDeck.share.moveCount))
        }
    }
}

struct CardBase:View {
    @State var type: CardType
    @State var w: CGFloat
    @State var h: CGFloat
    var body: some View {
        ZStack {
            Text(CardType.baseRep(type)).font(.system(size: h*0.5, weight: .black, design: .default))
        }
        .frame(width: w*0.9, height: h*0.9)
        .offset(x:w*0.05, y:h*0.05)
        .border(Color.black, width: 1.0)
        .cornerRadius(5.0)
    }
}
struct CardView:View {
    @State var dt: DRep
    @State var w: CGFloat
    @State var h: CGFloat
    var body: some View {
        let col = CardType.index(dt.type) & 1 == 1 ? Color.red : Color.black
        let sz = dt.num == 10 ? w*0.3 : w*0.4
        ZStack {
            if dt.stt == .down {
//                Image("ura").resizable().frame(width: w*0.8, height: h*0.8).position(x: w*0.45, y: h*0.45)
                Image("ura").resizable().frame(width: w, height: h).position(x: w*0.4, y: h*0.4)

            } else {
                Image("blank").resizable().frame(width: w*0.8, height: h*0.8).position(x: w*0.4, y: h*0.5)
            }
            let mode = Setting.instance.secret
            if dt.stt == .up || (dt.stt == .down && mode) {
                Text(dt.type.rawValue).offset(x: -w*0.2, y: -h*0.35)
                    .font(.system(size: w*0.3, weight: .black, design: .default))
                Text(CardType.numRep(dt.num)).offset(x: w*0.2, y: -h*0.35)
                    .font(.system(size: sz, weight: .black, design: .default))
                    .foregroundColor(col)
                Text(CardType.numRep(dt.num)).offset(x: -w*0.2, y: h*0.3)
                    .font(.system(size: sz, weight: .black, design: .default))
                    .foregroundColor(col)
                Text(dt.type.rawValue).offset(x: w*0.2, y: h*0.3)
                    .font(.system(size: w*0.3, weight: .black, design: .default))
            }
        }
        .frame(width: w*0.95, height: h*0.95)
        .offset(x:w*0.05, y:h*0.05)
        .background(Color.white)
        .border((dt.ischk ? Color.red: Color.black), width: (dt.ischk ? 4.0: 2.0))
        .cornerRadius(5.0)
    }
}

struct CardsView: View {
    @State var winW: CGFloat
    @State var winH: CGFloat
    
    @Binding var isMove: Bool // 移動アニメ実行開始フラグ
    @State var isEnd: Bool = false

    var body: some View {
        ZStack {
            // GeometryReader下は一度のみ呼ばれる
            let cdt = CardDeck.share
            let cdW = cdt.bW
            let cdH = cdt.bH
            let bx = CardDeck.wW*0.5
            let by = CardDeck.hH*0.5+cdH*0.5
            
            ForEach(cdt.deckBase.indices, id: \.self) { i in
                let tc = cdt.deckBase[i]
                CardBase(type: tc.type, w: cdW, h: cdH).frame(width: cdW, height: cdH).position(x:tc.x+bx, y:tc.y+by)
            }
            
            ForEach(cdt.deckPos.indices, id: \.self) { i in
                ForEach(cdt.deckPos[i].indices, id: \.self) { j in
                    let tc = cdt.deckPos[i][j]
                    CardView(dt: tc, w: cdW, h: cdH).frame(width: cdW, height: cdH).position(x:tc.x+bx, y:tc.y+by)
                }
            }
            ForEach(cdt.deckAns.indices, id: \.self) { i in
                let n = cdt.deckAns[i].count
                if n > 0 {
                    let tc = cdt.deckAns[i][n-1]
                    CardView(dt: tc, w: cdW, h: cdH).frame(width: cdW, height: cdH).position(x:tc.x+bx, y:tc.y+by)
                }
            }
            ForEach(cdt.deckOpn.indices, id: \.self) { i in
                let n = cdt.deckOpn.count
                if n > 0 {
                    let tc = cdt.deckOpn[i]
                    CardView(dt: tc, w: cdW, h: cdH).frame(width: cdW, height: cdH).position(x:tc.x+bx, y:tc.y+by)
                }
            }

            if cdt.deckStk.count > 0 {
                let tc = cdt.deckStk[cdt.deckStk.count-1]
                CardView(dt: tc, w: cdW, h: cdH).frame(width: cdW, height: cdH).position(x:tc.x+bx, y:tc.y+by)
            }
            
            if isMove { // 移動アニメ実行
                if let mc = cdt.deckMove {
                    CardView(dt: mc, w: cdW, h: cdH).frame(width: cdW, height: cdH)
                        .position(x: (!isEnd ? cdt.fromX : mc.x)+bx, y: (!isEnd ? cdt.fromY : mc.y)+by)
                        .animation(.default, value: isEnd).onAppear(perform: {
                        isEnd.toggle()
                    })
                }
            }
        }
        .frame(width: winW, height: winH)
        .position(x: CardDeck.share.bW*0.5, y: 0)
//        .background(Color.red)
    }
    
}

enum GameState: Int {
    case begin
    case play
    case finish
    case complete
    case registed
    case readin
}

struct PlayView: View {
//    @Environment(\.presentationMode) var presentationMode
    @State var winW:CGFloat
    @State var winH:CGFloat
    @Binding var selection: Int
    @Binding var isRegist: Bool

    @State var isupdate: Int = 0
    @State var isAlert: Bool = false
    @State var isComplete: Bool = false
    @State var isFinish: Bool = false
    @State var isConfirm: Bool = false
    
    @State var isMove: Bool = false

    @State var startcode: String? = nil

    @State var timer1sec: Timer? = nil

    @State private var showAlert = true
// https://stackoverflow.com/questions/74407838/why-am-i-getting-this-systemgesturegate-0x102210320-gesture-system-gesture
//    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack { // Vstackのoffsetsubviewに適用される
            InfoView(winW: winW, winH: 25.0).onTapGesture {
                isupdate += 1
            }
//            .background(Color.red)
            .frame(width: winW, height: 25.0).id(isupdate)
            // ※ZStackのoffsetは内部のビューに適用される
            ZStack {
                CardsView(winW: winW*0.98, winH: (winH-90.0)*0.98, isMove: $isMove)
                    .frame(width: winW*0.98, height: (winH-90)*0.98)
                // https://qiita.com/SNQ-2001/items/bb7c029c86750b16491d
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded{ event in
                        //カード部分のみ反応する。好都合だけどStackはViewじゃない？
                        let pos = event.location
//                        print("\(pos.x) \(pos.y)")
                        let rt = CardDeck.share.onTap(pos)
                        isupdate += 1
                        if rt {
                            // https://www.choge-blog.com/programming/swiftuialertautodismiss/
                            if showAlert {
                                isAlert = true
                                //3秒後に閉じる
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.isAlert = false;
                                }
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                isMove = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    CardDeck.share.doMove()
                                    isMove = false
                                    isupdate += 1
                                    let comp = CardDeck.share.checkComp()
                                    if comp == 1 && !isFinish {
                                        isFinish = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            self.isFinish = false;
                                            CardDeck.share.finish()
                                            timer1sec = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
                                                // ここから実行
                                                let ret = CardDeck.share.autoComp()
                                                if !ret {
                                                    self.timer1sec!.invalidate()
                                                    isComplete = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                        isComplete = false
                                                        isConfirm = true
                                                    }
                                                }
                                                CardDeck.share.doMove()
                                                isupdate += 1
                                                // ここまで実行
                                            })
                                        }
                                    } else if comp == 2 {
                                        isComplete = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            isComplete = false
                                            isConfirm = true
                                        }
                                    }
                                }
                            }
                        }
                    })
                if isComplete {
                    Text("クリア!").font(.system(size: 80, weight: .black, design: .default)).foregroundStyle(Color.red)
                }
            }
            .frame(width: winW, height: winH-90)
//            .background(Color.orange)
            .alert("card_select", isPresented: $isAlert, actions: {  }, message:{ Text("card_dup_message") }) //参https://thwork.net/2022/09/21/swiftui_ontapgesture_get_point/
            .alert("card_auto", isPresented: $isFinish, actions: {  }, message:{ Text("") })
            .alert(isPresented: $isConfirm) { Alert(title:Text("card_regist"), message: Text(""), primaryButton: .default(Text("card_yes")) { selection = 2; isRegist = true; isConfirm = false }, secondaryButton: .cancel(Text("card_no")) { isConfirm = false })
            }
            .id(isupdate) //これをここにつけないとupdしない
            HStack {
                Button("card_reset", action: {
                    CardDeck.share.reset()
                    isupdate = (isupdate == 0) ? 1 : 0
                    isRegist = false
                }).foregroundColor(Color.red)
                .frame(width: winW*0.33, height: 30)
                Button("card_rebuild", action: {
                    CardDeck.share.rebuildDeck()
                    isupdate = (isupdate == 0) ? 1 : 0
                    isRegist = false
                }).foregroundColor(Color.red)
                .frame(width: winW*0.33, height: 30)
                Button("undo", action: {
                    CardDeck.share.undo()
                    isupdate -= 1
                }).foregroundColor(Color.red)
                .frame(width: winW*0.33, height: 30)

            }
            .frame(width: winW, height: 55).offset(x: 0, y: 0).padding(.bottom, 20)
//            .background(Color.yellow)
        }.onAppear {
            isupdate += 1
        // 無指定だとiPhone16PMでは左右に
            showAlert = Setting.instance.showAlert
            if Setting.instance.secret {
                CardDeck.share.keepSecret = true
            }
        }
//        .frame(width: winW-28.0, height: winH-48.0) // SE3
//        .frame(width: winW+30.0, height: winH+170.0) // 16PM
        .frame(width: winW, height: winH)
        // https://zenn.dev/usk2000/articles/cc8184ed619da3b37b02
        .onOpenURL(perform: { url in
            print("Received open URL in SwiftUI view: \(url)")
            if url.scheme?.lowercased() == "ytsolipl" {
                startcode = url.host!
                CardDeck.share.readDeck(deck: startcode!)
                isupdate = (isupdate == 0) ? 1 : 0
                isRegist = false
            }
        })

//        .background(Color.cyan)
/*        .onChange(of: scenePhase) { phase in // https://swifty-ui.com/scenephase/
            if phase == .background {
                print("バックグラウンド（.background）")
            }
            if phase == .active {
                print("フォアグラウンド（.active）")
            }
            if phase == .inactive {
                print("バックグラウンドorフォアグラウンド直前（.inactive）")
            }
        }*/

    }
    
    init(winW w: CGFloat, winH h: CGFloat, selection: Binding<Int>, isRegist: Binding<Bool>) {
        // https://ja.stackoverflow.com/questions/63943/state付きの変数の値の初期化が無効になる
        _winW = State(initialValue: w)
        _winH = State(initialValue: h)
        _selection = selection
        _isRegist = isRegist
//        _isupdate = State(initialValue: isupdate)
        
        if CardDeck.share.isReset {
//            if let saveDt = UserDefaults.standard.string(forKey: "deck") {
//                cdt.decodeDeck(saveDt)
//                CardDeck.share.isReset = false
//                CardDeck.share.relayout()
            CardDeck.setup(w: w*0.98, h: (h-90)*0.98)
            let cdt = CardDeck.share
            if !cdt.loadDeck() {
                cdt.buildDeck()
            }
        }
    }
    
    func registRank() {
        
    }
}


//#Preview {
//    PlayView()
//}
/*struct PlayView_Previews: PreviewProvider {
    @State var cdt: CardDeck

    static var previews: some View {
        PlayView(cdt: $cdt, isupdate: 0)
    }
}*/
