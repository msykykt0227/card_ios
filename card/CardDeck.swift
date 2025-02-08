//
//  CardDeck.swift
//  card
//
//  Created by msykykt on 2024/10/10.
//
import UIKit

enum CardType: String {
    case spade = "♠️"
    case heart = "♥️"
    case club = "♣️"
    case diamond = "♦️"
    case ext1 = "⚫️"
    case ext2 = "🔴"
    case ext3 = "⬛"
    case ext4 = "🟥"
    case blank = "→"
    
    static func index(_ t:CardType) -> Int {
        switch t {
        case .spade: return 0
        case .heart: return 1
        case .club: return 2
        case .diamond: return 3
        case .ext1: return 4
        case .ext2: return 5
        case .ext3: return 6
        case .ext4: return 7
        case .blank: return 8
        }
    }
    
    static func at(_ i:Int) -> CardType {
        switch i {
        case 0: return .spade
        case 1: return .heart
        case 2: return .club
        case 3: return .diamond
        case 4: return .ext1
        case 5: return .ext2
        case 6: return .ext3
        case 7: return .ext4
        case 8: return .blank
        default:
            return .blank
        }
    }
    
    static func baseRep(_ t:CardType) -> String {
        switch t {
        case .spade: return "A"
        case .heart: return "A"
        case .club: return "A"
        case .diamond: return "A"
        case .ext1: return "A"
        case .ext2: return "A"
        case .ext3: return "A"
        case .ext4: return "A"
        case .blank: return "→"
        }
    }

    static func numRep(_ i:Int) -> String {
        if i == 0 {
            return " "
        } else if i == 1 {
            return "A"
        } else if i == 11 {
            return "J"
        } else if i == 12 {
            return "Q"
        } else if i == 13 {
            return "K"
        } else {
            return String(i)
        }
    }
}

enum CardState: Int {
    case up = 1
    case down = 2
    case non = 0
}

class DRep {
    var x: CGFloat
    var y: CGFloat
    var type: CardType = .blank
    var num: Int = 0
    var stt: CardState = .non
    var ischk: Bool = false
    
    init(x: CGFloat, y: CGFloat, t:CardType = .blank, n:Int = 0, s:CardState = .down) {
        self.x = x
        self.y = y
        self.type = t
        self.num = n
        self.stt = s
    }
    
    func put(_ t:CardType, _ n:Int) {
        self.type = t
        self.num = n
    }
    
}

struct Pos {
    var x:Int
    var y:Int
}

enum MoveArea: Int {
    case non = -1
    case pos = 0
    case ans = 1
    case opn = 2
    case stk = 3
    case rev = 4
    case auto = 5
}

class DeckMove {
    var sArea:MoveArea = .non
    var sii:Int = 0
    var sjj:Int = 0
    var tArea:MoveArea = .non
    var tii:Int = 0
    var isRev:Bool = false

    let txtbl = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@%"

    init(_ sa:MoveArea, _ si:Int, _ sj:Int, _ ta:MoveArea, _ ti:Int) {
        sArea = sa
        sii = si
        sjj = sj
        tArea = ta
        tii = ti
    }
    
    func idM(_ m:Int) -> MoveArea {
        if m == 0 {
            return .stk
        } else if m == 1 {
            return .opn
        } else if m == 2 {
            return .rev
        } else if m == 3 {
            return .auto
        } else if m < 4+CardDeck.share.max_type {
            return .ans
        }
        return .pos
    }
    func idI(_ m:Int) -> Int {
        if m == 0 {
            return 0
        } else if m == 1 {
            return 0
        } else if m == 2 {
            return 0
        } else if m == 3 {
            return 0
        } else if m < 4+CardDeck.share.max_type {
            return m-4
        }
        return m-4-CardDeck.share.max_type
    }
    init(_ str:String) {
        let nai = 4+CardDeck.share.max_pos+CardDeck.share.max_type
        let nj = CardDeck.share.max_num+CardDeck.share.max_pos
        let c0 = Int(String(str.first!))!
        var si = str.index(str.startIndex, offsetBy: 1)
        let ch = str[si]
        si = str.index(si, offsetBy: 1)
        let cl = str[si]
        if let ih = txtbl.firstIndex(of: ch) {
            if let il = txtbl.firstIndex(of: cl) {
                var did = (c0<<12) | ((ih.utf16Offset(in: txtbl))<<6) | (il.utf16Offset(in: txtbl))
                isRev = (did & 1) == 0 ? false : true
                did = did/2
                let ta = did % nai
                did = did/nai
                self.sjj = did % nj
                let sa = did/nj
                self.sArea = idM(sa)
                self.sii = idI(sa)
                self.tArea = idM(ta)
                self.tii = idI(ta)
            }
        }
    }
    func mId(_ a:MoveArea, _ i:Int) -> Int {
        if a == .stk {
            return 0
        } else if a == .opn {
            return 1
        } else if a == .rev {
            return 2
        } else if a == .auto {
            return 3
        } else if a == .ans {
            return 4+i
        }
        return CardDeck.share.max_type + i + 4 // < 21
    }
    func toString() -> String {
        let nai = 4+CardDeck.share.max_pos+CardDeck.share.max_type
        let nj = CardDeck.share.max_num+CardDeck.share.max_pos
        let ia = ((mId(sArea,sii)*nj+sjj)*nai+mId(tArea, tii))*2+(isRev ? 1 : 0)
        let ih = (ia>>6)&0x3f
        let il = ia&0x3f
        let ch = txtbl.index(txtbl.startIndex, offsetBy: ih)
        let cl = txtbl.index(txtbl.startIndex, offsetBy: il)
        return String(ia>>12)+txtbl[ch...ch]+txtbl[cl...cl]
    }
}

class CardDeck {
    
    static let share: CardDeck = CardDeck()
    
    var did:Int = 0
    
    var isReset = true
    var max_pos:Int = 7 // iphoneは最大８？
    var max_num:Int = 13 // <=13
    var max_type:Int = 4 // = max_ans <=8
    var pos_type:PosType = .standard // 0:default 1:谷 2:山 3:ダイヤ 4:
    // pos_type ==1 : maxpos奇数=(Int((max_pos+1)/2))**2 , maxpos偶数=(max_pos/2)*(max_pos/2+1) < max_num*max_type
    var build_type:Int = 2
    
    var opn_type:Int = 0
    
    var deckPosDef: [Int] = []
    
    var deckPos:[[DRep]]
    var deckAns:[[DRep]]
    var deckStk:[DRep]
    var deckOpn:[DRep]
    
    static var wW:CGFloat = 0
    static var hH:CGFloat = 0
    var pW:CGFloat = 0
    var pH:CGFloat = 0
    var bX:CGFloat = 0
    var bY:CGFloat = 0
    var bW:CGFloat = 0
    var bH:CGFloat = 0
    var cY:CGFloat = 0
    var dY:CGFloat = 0
    var aY:CGFloat = 0
    var oW:CGFloat = 0
    var nVo:Int = 0

    var moveCount:Int = 0
    var keepSecret: Bool = false


    init() {
        deckPos = []
        deckAns = []
        deckStk = []
        deckOpn = []
        undoStack = []
        moveCount = 0
    }
    
    // undoバッファ
    
    var deckMove:DRep? = nil
    var fromA:MoveArea = .non
    var toA:MoveArea = .non
    var toI:Int = 0
    var fromX:CGFloat = 0
    var fromY:CGFloat = 0

    var undoStack:[DeckMove]

    func push(_ sa:MoveArea, _ si:Int, _ sj:Int, _ ta:MoveArea, _ ti:Int, isRev:Bool = false) {
        let stk = DeckMove(sa, si, sj, ta, ti)
        stk.isRev = isRev
        undoStack.append(stk)
    }
    
    func undo() {
        if undoStack.count == 0 { return }
        let stk = undoStack.removeLast()
        doPop(stck: stk, needPush: false)
        doMove()
        if stk.tArea != .stk && stk.sArea != .rev && stk.sArea != .auto {
            moveCount -= 1
        }
    }
    
    func setMove(_ from:MoveArea, _ x:CGFloat, _ y:CGFloat, _ to:MoveArea, _ toi:Int,  _ dt:DRep) {
        deckMove = dt
        toA = to
        toI = toi
        fromA = from
        fromX = x
        fromY = y
    }
    
    func encodeUndo(undo:[DeckMove]) -> String {
        var code:String = ""
        for i in 0..<undo.count {
            let dt = undo[i]
            code += dt.toString()
        }
        return code
    }
    func decodeUndo(_ code:String) -> [DeckMove] {
        var undo: [DeckMove] = []
        if code.count <= 3 { return undo }
        var si = code.startIndex
        for _ in stride(from: 0, to: code.count, by: 3) {
            let di = code.index(si, offsetBy: 3)
            let str = code[si..<di]
            undo.append(DeckMove(String(str)))
            si = di
        }
        
        return undo
    }
    
    func finish() {
        saveDeck()
        push(.auto, 0, 0, .auto, 0, isRev: false)
    }
    // カード移動処理
    
    func reculcPos(_ ix: Int) {
        let n = deckPos[ix].count
        for i in 0..<n {
            deckPos[ix][i].y = posY(ix,i, n) //CGFloat(i)*dh+cY+bY
        }
    }
    func reculcPos2(_ ix: Int, _ nx:Int) {
        let n = deckPos[ix].count
        for i in 0..<n {
            deckPos[ix][i].y = posY(ix,i, nx) //CGFloat(i)*dh+cY+bY
        }
    }
    func appendPos(_ ix:Int, _ dt:DRep) {
        deckPos[ix].append(dt)
        if deckPos[ix].count > max_th {
            reculcPos(ix)
        }
    }
    func removeLastPos(_ ix:Int) -> DRep {
        //        if deckPos[ix].count > 0 {
        let dt = deckPos[ix].removeLast()
        if deckPos[ix].count <= max_th {
            reculcPos(ix)
        }
        return dt
        //        }
    }
    
    func doMove() {
        guard let dt = deckMove else { return }
        switch toA {
        case .pos:
            deckPos[toI].append(dt)
        case .ans:
            deckAns[toI].append(dt)
        case .stk:
            deckStk.append(dt)
        case .opn:
            deckOpn.append(dt)
        case .non:
            break
        case .rev:
            break
        case .auto:
            break
        }
        if fromA == .opn {
            updateOpn()
        }
        deckMove = nil
    }
    
    func doPos(stck:DeckMove, needPush:Bool = true) -> Bool {
        let ix = stck.sii
        let iy = stck.sjj
        if ix<0 || ix>=deckPos.count { return false }
        if iy<0 || iy>=deckPos[ix].count { return false }
        if iy == deckPos[ix].count-1 {
            let stt = deckPos[ix].count > 1 && deckPos[ix][deckPos[ix].count-2].stt == .down
            if stck.tArea == .pos {
                let jx = stck.tii
                if jx<0 || jx>=deckPos.count { return false }
                //                let dt = deckPos[ix].removeLast()
                let dt = removeLastPos(ix)
                let n = deckPos[jx].count
                let x = dt.x
                let y = dt.y
                if n+1 >= max_th || pos_type == .diamond {
                    reculcPos2(jx,n+1)
                }
                dt.x = posX(jx, n, n+1) //CGFloat(jx)*bW+bX
                dt.y = posY(jx, n, n+1) //CGFloat(deckPos[jx].count)*dH(n)+cY+bY
                setMove(.pos, x, y, .pos, jx, dt)
                if needPush {
                    push(.pos, jx, n, .pos, ix, isRev: stt)
                }
            } else if stck.tArea == .ans {
                let jx = stck.tii
                if jx<0 || jx>=deckAns.count { return false }
                //                let dt = deckPos[ix].removeLast()
                let dt = removeLastPos(ix)
                let n = deckAns[jx].count
                let x = dt.x
                let y = dt.y
                dt.x = ansX(jx, n) // CGFloat(jx)*bW+bX
                dt.y = ansY(jx, n) // bY
                setMove(.pos, x, y, .ans, jx, dt)
                if needPush {
                    push(.ans, jx, n, .pos, ix, isRev: stt)
                }
            } else if stck.tArea == .opn { // undoのみ
                //                let dt = deckPos[ix].removeLast()
                let dt = removeLastPos(ix)
                deckOpn.append(dt)
                updateOpn()
                if needPush { // これは起きないはず
                    push(.opn, 0, deckOpn.count-1, .pos, ix, isRev: stt)
                }
            } else {
                return false // ないはず
            }
            if deckPos[ix].count > 0 {
                let nxt = deckPos[ix].last
                nxt?.stt = .up
            }
            return true
        }
        
        if stck.tArea != .pos { // 複数はpop to popしかあり得ない
            return false
        }
        let jx = stck.tii
        if jx<0 || jx>=deckPos.count { return false }
        let n = deckPos[ix].count
        let sy = deckPos[jx].count
        for jy in iy..<n {
            let dt = deckPos[ix][jy]
            let nn = deckPos[jx].count
            dt.x = posX(jx, nn, nn+1) //CGFloat(jx)*bW+bX
            dt.y = posY(jx, nn, nn+1) // CGFloat(nn)*dH(nn)+cY+bY
            deckPos[jx].append(dt)
        }
        for _ in iy..<n {
            deckPos[ix].removeLast()
            //            removeLastPos(ix)
        }
        if needPush {
            let stt = deckPos[ix].count > 0 && deckPos[ix][deckPos[ix].count-1].stt == .down
            push(.pos, jx, sy, .pos, ix, isRev: stt)
        }
        deckPos[ix].last?.stt = .up
        reculcPos(ix)
        reculcPos(jx)
        return true
    }
    func doAns(stck:DeckMove, needPush:Bool = true) -> Bool {
        let ix = stck.sii
        if ix<0 || ix>=deckAns.count { return false }
        if stck.tArea == .pos {
            let jx = stck.tii
            if jx<0 || jx>=deckPos.count { return false }
            let src = deckAns[ix].removeLast()
            let n = deckPos[jx].count
            let x = src.x
            let y = src.y
            if n+1 >= max_th || pos_type == .diamond {
                reculcPos2(jx, n+1)
            }
            src.x = posX(jx, n, n+1) //CGFloat(jx)*bW+bX
            src.y = posY(jx, n, n+1) //CGFloat(deckPos[jx].count)*dH(n)+cY+bY
            setMove(.ans, x, y, .pos, jx, src)
            if needPush {
//?                push(.pos, jx, deckPos[jx].count-1, .ans, ix)
                push(.pos, jx, deckPos[jx].count, .ans, ix)
            }
        } else if stck.tArea == .opn {
            //            let jx = stck.tii // 途中に追加（途中抜きのundo）
            //            if jx<0 || jx>=deckOpn.count { return false }
            //
            let src = deckAns[ix].removeLast()
            deckOpn.append(src)
            updateOpn()
            if needPush {
//?                push(.opn, deckOpn.count-1, 0, .ans, ix)
                push(.opn, 0, deckOpn.count, .ans, ix)
            }
        } else { // to ansはありえないことはない。空きがあってansにあるAをタップする
            return false
        }
        return true
    }
    func doOpn(stck:DeckMove, needPush:Bool = true) -> Bool {
        let ix = stck.sjj //autoのみ途中抜きを許す。
        //        let jy = stck.tjj
        if stck.tArea == .pos {
            let jx = stck.tii
            if jx<0 || jx>=deckPos.count { return false }
            let src = deckOpn.remove(at: ix)
            let x = src.x
            let y = src.y
            let n = deckPos[jx].count
            if n+1 >= max_th || pos_type == .diamond {
                reculcPos2(jx, n+1)
            }
            src.x = posX(jx, n, n+1) //CGFloat(jx)*bW+bX
            src.y = posY(jx, n, n+1) //CGFloat(deckPos[jx].count)*dH(n)+cY+bY
            setMove(.opn, x, y, .pos, jx, src)
            if needPush {
                push(.pos, jx, n, .opn, stck.sii)
            }
        } else if stck.tArea == .ans {
            let jx = stck.tii
            if jx<0 || jx>=deckAns.count { return false }
            let src = deckOpn.remove(at: ix)
            let x = src.x
            let y = src.y
            let n = deckAns[jx].count
            src.x = ansX(jx, n) //CGFloat(jx)*bW+bX
            src.y = ansY(jx, n) //bY
            setMove(.opn, x, y, .ans, jx, src)
            if needPush {
                push(.ans, jx, n, .opn, stck.sii)
            }
        } else if stck.tArea == .stk {
            let jx = stck.tii
            let src = deckOpn.remove(at: ix)
            let x = src.x
            let y = src.y
            src.x = stkX(jx) //bW*6+bX
            src.y = stkY(jx) //bY
            src.stt = .down
            setMove(.opn, x, y, .stk, jx, src)
            if needPush {
                push(.opn, 0, stck.tii, .stk, stck.sii)
            }
        } else { // opn to opnはあり得ない
            return false
        }
//        updateOpn()
        return true
    }
    func doPop(stck:DeckMove, needPush:Bool = true) -> Bool {
        var ret = false
        if stck.isRev {
            switch stck.tArea {
            case .pos:
                let dt = deckPos[stck.tii].last
                dt!.stt = .down
            case .stk: // .opnからしかありえない->autoCompのundoでansからがありえる
                let dt = deckOpn[stck.sii]
                dt.stt = .down
            default:
                break
            }
        }
        
        switch stck.sArea {
        case .pos:
            ret = doPos(stck: stck, needPush: needPush)
        case .ans:
            ret = doAns(stck: stck, needPush: needPush)
        case .opn:
            ret = doOpn(stck: stck, needPush: needPush)
        case .stk:
            if deckStk.count == 0 || stck.tArea != .opn {
                return false
            }
            let dt = deckStk.removeLast()
            let n = deckOpn.count
            dt.stt = .up
            deckOpn.append(dt)
            updateOpn()
            if needPush {
                push(.opn, 0, n, .stk, 0, isRev: false)
            }
            return true
        case .rev:
            backOpn()
            break
        case .auto:
            ret = loadDeck()
        default:
            break
        }
        return ret
    }
    
    // レイアウト
    
    var max_th:Int = 0
    
    func posDefMake() {
        if pos_type == .valley || pos_type == .mountain  || pos_type == .diamond {
            let m = Int(max_pos/2)
            deckPosDef = []
            for i in 1...m {
                deckPosDef.append((i-1)*2+1)
            }
            if max_pos&1 == 1 {
                deckPosDef.append(m*2+1)
            }
            for i in (1...m).reversed() {
                deckPosDef.append((i-1)*2+1)
            }
        } else { // CardDeck.share.pos_type == 0
            deckPosDef = Array(1...max_pos)
        }

    }

    static func setup(w:CGFloat, h:CGFloat) {
        wW = w
        hH = h
    }
    // 保持されたw,h,デッキ定義に従いビルドパラメータを準備
    var deckBase:[DRep] = []
    func buildBase() {
        deckBase = []
        for i in 0..<CardDeck.share.max_type {
            deckBase.append(DRep(x: ansX(i,0), y: ansY(i,0), t: CardType.at(i), n: 0, s: .up))
        }
        deckBase.append(DRep(x: stkX(0), y: stkY(0), t: .blank, n: 0, s: .up))
    }
    func relayout() {

        posDefMake()
        
        var mx = max_type
        if mx < max_pos {
            mx = max_pos
        }
        if mx < 6 {
            mx = 6
        }
        CardDeck.share.opn_type = 0
        if pos_type == .diamond {
            opn_type = 2
        } else if mx < max_type+3 { // 3=stk+opn*1.8+sp*0.2
            opn_type = 1 // ansとstkを別エリアに
        }
                
        bW = CardDeck.wW/CGFloat(mx)
        bH = bW*1.618
        bX = 0
        bY = 0
        
        pW = CardDeck.wW
        cY = bY + bH*1.05
        
        aY = bY
        pH = CardDeck.hH - cY
        oW = pW - bW*CGFloat(max_type) - bW - bW*0.2
        
        if opn_type == 1 {
            aY = CardDeck.hH - bH
            pH = aY - cY
            oW = pW - bW - bW*2
        } else if opn_type == 2 {
            aY = bY + bH*1.05
//            cY = aY+bH
            oW = pW - bW - bW*2
        }
        nVo = Int((oW-bW)/(bW*0.4)+0.1)
        
        if pos_type == .standard {
            dY = bH*0.25 //(pH*0.7-bH)/CGFloat(max_num-1)
        } else {
//            let m = Int((max_type+1)/2)
            dY = bH*0.25 //(pH*0.7-bH)/CGFloat(m-1)
        }
//        if dY > bW*0.8 {
//            dY = bW*0.8
//        }
        max_th = Int((pH-bH)/dY)+1
        nVo = Int(oW/bW)

        buildBase()
    }
    func dH(_ n:Int) -> CGFloat {
        if n <= max_th {
            return dY
        } else {
            return (pH - bH)/CGFloat(n-1)
        }
    }
    func posX(_ i:Int, _ j:Int, _ n:Int) -> CGFloat {
        return bW*CGFloat(i)+bX
    }
    func posY(_ i:Int, _ j:Int, _ n:Int) -> CGFloat {
        if pos_type == .mountain {
//            return (pH - bH - CGFloat(j)*dH(n))+cY
            return (pH - bH*2.2 - CGFloat(j)*dH(n))+cY
        } else if pos_type == .diamond {
//            return pH*0.5 - bH*1.2 - (bH+CGFloat(deckPosDef[i]-1)*dH(n))*0.5 + CGFloat(j)*dH(n)+cY
            if i<2 || i>=deckPosDef.count-2 {
                return pH*0.5+aY - bH*0.5 - dH(n+3)*CGFloat(n-1)*0.5 + CGFloat(j)*dH(n+3)
            } else {
                return pH*0.5+aY - bH*0.5 - dH(n)*CGFloat(n-1)*0.5 + CGFloat(j)*dH(n)
            }
        } else {
            return CGFloat(j)*dH(n)+cY
        }
    }
    func ansX(_ i:Int, _ j:Int) -> CGFloat {
        if opn_type == 2 {
            return ((i&1 == 0) ? 0 : pW - bW - bW) + ((i&4 == 0) ? 0 : bW)
        } else {
            return bW*CGFloat(i) + bX
        }
    }
    func ansY(_ i:Int, _ j:Int) -> CGFloat {
        if opn_type == 2 {
            return (i&2 == 0) ? aY : pH - bH + aY
        } else {
            return aY
        }
    }
    func stkX(_ i:Int) -> CGFloat { // iがマイナスの場合(stkが０)はbaseStkの座標を返すこと
        return bX + pW - bW
    }
    func stkY(_ i:Int) -> CGFloat {
        return bY
    }
    func opnX(_ i:Int) -> CGFloat {
        var n = (i - deckOpn.count + 1)
        if n < -nVo {
            n = -nVo-1
        }
        return pW - bW - bW + bW*CGFloat(n)*0.4
    }
    func opnY(_ i:Int) -> CGFloat {
        return bY
    }
    
    // デッキ構築
    
    // 皆藤領域準備
    // 設定パラメータ指定
    // 画面サイズ決定
    // レイアウト計算
    // カード配置
    func clearDeck() {
        deckPos = Array(repeating: [], count: deckPosDef.count)
        deckAns = Array(repeating: [], count: max_type)
        deckStk = []
        deckOpn = []
        undoStack = []
        moveCount = 0
    }
    
    func buildDeck1() {
        
        let td = Array(0..<(max_type*max_num)).shuffled()
        var ips = 0
        for i in 0..<deckPosDef.count {
            for j in 0..<deckPosDef[i] {
                if ips>=td.count { break }
                let tv = td[ips]
                ips += 1
                let type = tv/max_num
                let nm = tv % max_num + 1
                deckPos[i].append(DRep(x: posX(i, j, i+1), y: posY(i, j, i+1), t: CardType.at(type), n: nm))
            }
        }
        for i in 0..<deckPos.count {
            if deckPos[i].count > 0 {
                deckPos[i][deckPos[i].count-1].stt = .up
            }
        }
        for i in 0..<deckPos.count {
            reculcPos2(i, deckPos[i].count)
        }
        
        deckAns = Array(repeating: [], count: max_type)
        
        for ip in ips..<(max_type*max_num) {
            let i = ip-ips
            deckStk.append(DRep(x: stkX(i), y: stkY(i), t: CardType.at(td[ip]/max_num), n: td[ip]%max_num+1))
        }
        
    }
    func buildDeck2() {
        
        var nc: Int = max_type*max_num
        
        let td = Array(0..<nc)
        
        while nc > 0 {
            let mc = Int.random(in: 0..<nc)
            var ix = 0
            var ib = 0
            while ix < deckPosDef.count && mc >= ib + deckPosDef[ix] - deckPos[ix].count {
                ib = ib + deckPosDef[ix] - deckPos[ix].count
                ix = ix+1
            }
            if ix < deckPosDef.count {
                ib = ib + deckPosDef[ix] - deckPos[ix].count
            }
            let ip = nc - 1
            let num = (td[ip]%max_num)+1
            let t = (td[ip]/max_num)
            if ix >= deckPos.count && mc >= ib {
                let i = deckStk.count
                deckStk.append(DRep(x: stkX(i), y: stkY(i), t: CardType.at(t), n: num))
            } else {
//                let n = deckPos[ix].count
                deckPos[ix].append(DRep(x: 0, y: 0, t: CardType.at(t), n: num))
            }
            nc = nc - 1
        }
        
        deckStk.shuffle()
        
        for i in 0..<deckPos.count {
            if deckPos[i].count > 0 {
                let n = deckPos[i].count
                deckPos[i][n-1].stt = .up
                for j in 0..<n {
                    deckPos[i][j].x = posX(i,j,n)
                    deckPos[i][j].y = posY(i,j,n)
                }
            }
        }

    }
    func buildDeck4() {
        
        var nc: Int = max_type*max_num
        
        let td = Array(0..<nc)
        
        while nc > 0 {
            let mc = Int.random(in: 0..<nc)
            var ix = 0
            var ib = 0
            while ix < deckPosDef.count && deckPosDef[ix] - deckPos[ix].count == 0 {
                ix = ix + 1
            }
            while ix < deckPosDef.count-1 && mc > ib {
                ix = ix + 1
                ib += deckPosDef[ix] - deckPos[ix].count
            }
            let ip = nc - 1
            let t = (td[ip]%max_type)
            let num = (td[ip]/max_type)+1
            if ix >= deckPosDef.count || mc > ib {
                let i = deckStk.count
                deckStk.append(DRep(x: stkX(i), y: stkY(i), t: CardType.at(t), n: num))
            } else {
                deckPos[ix].append(DRep(x: 0, y: 0, t: CardType.at(t), n: num))
            }
            nc = nc - 1
        }
        
        for i in 0..<deckPos.count {
            if deckPos[i].count > 0 {
                deckPos[i][deckPos[i].count-1].stt = .up
                let n = deckPos[i].count
                for j in 0..<n {
                    deckPos[i][j].x = posX(i,j,n)
                    deckPos[i][j].y = posY(i,j,n)
                }
            }
        }
        
        deckStk.shuffle()
        
    }
    func buildDeck3() {
        
        let hn = max_num/2
        let mx = max_num
        var nc: Int = max_type*max_num
        
        var td: [Int] = []
        for i in 0..<max_type {
            td.append(contentsOf: Array((mx*i)..<(mx*i+hn)))
        }
        for i in 0..<max_type {
            td.append(contentsOf: Array((mx*i+hn)..<(mx*i+mx)))
        }

        while nc > 0 {
            let mc = Int.random(in: 0..<nc)
            var ix = 0
            var ib = 0
            while ix < deckPosDef.count && mc >= ib + deckPosDef[ix] - deckPos[ix].count {
                ib = ib + deckPosDef[ix] - deckPos[ix].count
                ix = ix+1
            }
            if ix < deckPosDef.count {
                ib = ib + deckPosDef[ix] - deckPos[ix].count
            }
            let ip = nc - 1
            let num = (td[ip]%max_num)+1
            let t = (td[ip]/max_num)
            if ix >= deckPos.count && mc >= ib {
                let i = deckStk.count
                deckStk.append(DRep(x: stkX(i), y: stkY(i), t: CardType.at(t), n: num))
            } else {
//                let n = deckPos[ix].count
                deckPos[ix].append(DRep(x: 0, y: 0, t: CardType.at(t), n: num))
            }
            nc = nc - 1
        }
        
        for i in 0..<deckPos.count {
            if deckPos[i].count > 0 {
                deckPos[i][deckPos[i].count-1].stt = .up
                let n = deckPos[i].count
                for j in 0..<n {
                    deckPos[i][j].x = posX(i,j,n)
                    deckPos[i][j].y = posY(i,j,n)
                }
            }
        }

        deckStk.shuffle()
        
    }
    func buildDeck() {
        if isReset {
            relayout()
            clearDeck()
            if build_type == 4 {
                buildDeck2()
            } else if build_type == 3 {
                buildDeck3()
            } else if build_type == 2 {
                buildDeck4()
            } else {
                buildDeck1()
            }
            startDeck = encodeDeck()
            isReset = false
            moveCount = 0
            keepSecret = false
            did = 0
        }
    }
    
    // デッキ保存
//    var schemeDeck:String? = nil
    var startDeck:String? = nil

    struct dkatom {
        let area:Int
        let type:CardType
        let num:Int
        let stt:CardState
        
        let txtbl = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$%#"
/*        init(did:Int) {
            var iw = did/CardDeck.share.max_num
            num = did%CardDeck.share.max_num+1
            type = CardType.at(iw%CardDeck.share.max_type)
            iw = iw/CardDeck.share.max_type
            stt = CardState.init(rawValue: (iw&1)+1)!
            area = iw>>1
        }*/
        init(area:Int, type:CardType, num:Int, stt:CardState) {
            self.area = area
            self.type = type
            self.num = num
            self.stt = stt
        }
        init?(_ hl:String) {
            if let ih = txtbl.firstIndex(of: hl.first!) {
                if let il = txtbl.firstIndex(of: hl.last!) {
                    var did = ((ih.utf16Offset(in: txtbl))<<6) | (il.utf16Offset(in: txtbl))
                    num = did%CardDeck.share.max_num+1
                    did = did/CardDeck.share.max_num
                    type = CardType.at(did%CardDeck.share.max_type)
                    did = did/CardDeck.share.max_type
                    stt = CardState.init(rawValue: (did&1)+1)!
                    area = did>>1
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
/*        func idt() -> Int {
            return ((area*2+(stt.rawValue-1))*CardDeck.share.max_type+CardType.index(type))*CardDeck.share.max_num+num-1
        }*/
        func txt() -> String {
            let hl = ((area*2+(stt.rawValue-1))*CardDeck.share.max_type+CardType.index(type))*CardDeck.share.max_num+num-1
            let ch = txtbl.index(txtbl.startIndex, offsetBy: hl>>6)
            let cl = txtbl.index(txtbl.startIndex, offsetBy: hl&0x3f)
            return String(txtbl[ch...ch])+String(txtbl[cl...cl])
        }
    }
    
    func encodeDeck() -> String {
        var dts = String(format: "%04x%1d%02d%1d%02d%1d", did,  PosType.index(pos_type), max_num, max_type, max_pos, build_type)
        var ia:Int = 0
        for i in 0..<deckStk.count {
            let dt = deckStk[i]
            dts.append(dkatom(area: ia, type: dt.type, num: dt.num, stt: dt.stt).txt())
        }
        ia = ia+1
        for i in 0..<deckOpn.count {
            let dt = deckOpn[i]
            dts.append(dkatom(area: ia, type: dt.type, num: dt.num, stt: dt.stt).txt())
        }
        ia = ia+1
        for i in 0..<deckAns.count {
            for j in 0..<deckAns[i].count {
                let dt = deckAns[i][j]
                dts.append(dkatom(area: ia, type: dt.type, num: dt.num, stt: dt.stt).txt())
            }
            ia = ia+1
        }
        for i in 0..<deckPos.count {
            for j in 0..<deckPos[i].count {
                let dt = deckPos[i][j]
                dts.append(dkatom(area: ia, type: dt.type, num: dt.num, stt: dt.stt).txt())
            }
            ia = ia+1
        }
        
        return dts
    }
    
    // 読み込み外部データチェック
    static func checkDeck(_ dts:String) -> Bool {
        let dmy = CardDeck()
        if !dmy.decodeParam(dts) { return false }
        if dmy.max_num < 2 || dmy.max_num > 13 { return false }
        if dmy.max_pos < 4 || dmy.max_pos > 8 { return false }
        if dmy.max_type < 2 || dmy.max_type > 8 { return false }
        if dmy.build_type < 0 || dmy.build_type > 5 { return false }
        if !dmy.decodeDeck(dts) { return false }
        return true
    }
    
    func decodeParam(_ dts:String) -> Bool {
        let l = dts.count
        if l < 11 { return false }
    
        var ei = dts.startIndex
        var si = dts.index(ei, offsetBy: 4)
        if let d = Int(dts[ei..<si], radix: 16) {
            did = d
        } else {
            return false
        }
        ei = dts.index(si, offsetBy: 1)
        if let t = Int(dts[si..<ei]) {
            pos_type = PosType.type(t)
        } else {
            return false
        }
        si = dts.index(ei, offsetBy: 2)
        if let n = Int(dts[ei..<si]) { // " 4"は落ちる"04"はOK
            max_num = n }
        else {
            return false }
        ei = dts.index(si, offsetBy: 1)
        if let t = Int(dts[si..<ei]) {
            max_type = t
        } else {
            return false }
        si = dts.index(ei, offsetBy: 2)
        if let p = Int(dts[ei..<si]) {
            max_pos = p
        } else {
            return false }
        ei = dts.index(si, offsetBy: 1)
        if let b = Int(dts[si..<ei]) {
            build_type = b
        } else {
            return false }
//        ei = dts.index(si, offsetBy: 3)
//        if let c = Int(dts[si..<ei]) { moveCount = c }
//        else { return false }
//        si = dts.index(ei, offsetBy: 0)
//        l = l - 9
        return true
    }
    func decodeDeck(_ dts:String) -> Bool {
        if !decodeParam(dts) {
            return false
        }
        
        relayout()

        clearDeck()

        var si = dts.index(dts.startIndex, offsetBy: 11)
        var l = dts.count - 11

        while(si < dts.endIndex && l >= 2) {
             l -= 2
            if let c = dkatom(String(dts[si..<dts.index(si, offsetBy: 2)])) {
                if c.area == 0 {
                    deckStk.append(DRep(x: stkX(0), y: stkY(0), t: c.type, n: c.num, s: c.stt))
                } else if c.area == 1 {
                    deckOpn.append(DRep(x: opnX(0), y: opnY(0), t: c.type, n: c.num, s: c.stt))
                } else if c.area < CardDeck.share.max_type+2 {
                    let i = c.area-2
                    deckAns[i].append(DRep(x: ansX(i, 0), y: ansY(i, 0), t: c.type, n: c.num, s: c.stt))
                } else  {
                    let i = c.area-CardDeck.share.max_type-2
                    let n = deckPos[i].count
                    deckPos[i].append(DRep(x: posX(i, n, n), y: posY(i, n, n), t: c.type, n: c.num, s: c.stt))
                }
                si = dts.index(si, offsetBy: 2)
            } else {
                clearDeck()
                return false
            }
        }
        for i in 0..<deckPos.count {
            reculcPos2(i, deckPos[i].count)
        }
        if l != 0 {
            clearDeck()
            return false
        }
        return true
    }
    
    // 設定はままで並べ替える
    func rebuildDeck() {
        isReset = true
        buildDeck()
        saveDeck()
    }
    // 初期に戻す。外部データ取得時はstartDeckに保存すること
    func reset() {
        guard let startDeck else { return }
        decodeDeck(startDeck)
        isReset = false
        keepSecret = false
        saveDeck()
    }
    // 外部データからデッキを構築
    func readDeck(deck:String) {
        startDeck = deck
        reset()
    }
    // 現在のデッキ保存（再開用）
    func saveDeck() {
        UserDefaults.standard.set(startDeck, forKey: "source")
        UserDefaults.standard.set(encodeDeck(), forKey: "deck")
        UserDefaults.standard.set(moveCount, forKey: "moveCount")
        UserDefaults.standard.set(encodeUndo(undo: undoStack), forKey: "undo")
        UserDefaults.standard.synchronize()
    }
    func loadDeck() ->Bool {
//        if schemeDeck != nil {
//            readDeck(deck:schemeDeck!)
//            schemeDeck = nil
//            return true
//        }
        
        if let sdk = UserDefaults.standard.string(forKey: "source") {
            startDeck = sdk
            if let deck = UserDefaults.standard.string(forKey: "deck") {
                if !decodeDeck(deck) {
                    return false
                }
                updateOpn()
                moveCount = UserDefaults.standard.integer(forKey: "moveCount")
                undoStack = decodeUndo(UserDefaults.standard.string(forKey: "undo") ?? "")
            } else {
                decodeDeck(startDeck!)
                moveCount = 0
            }
            isReset = false
            return true
        }
        return false
    }
    
    // タップ位置判定
    var savePos: [(a:Int, b:Int)] = []
    var lastA: Int = 0
    var lastX: Int = 0
    var lastY: Int = 0
    func srchDst(src:DRep, islast:Bool = true) -> [(a:Int, b:Int)] {
        var ans:[(a:Int, b:Int)] = []
        let ts = src.type
        let ns = src.num
        if ns == 1 {
            for i in 0..<deckAns.count { // ここを変えればタイプ固定にできるはず
                if deckAns[i].count == 0 {
                    return [(1, i)]
                }
            }
        } else if ns == CardDeck.share.max_num {
            for i in 0..<deckAns.count {
                if deckAns[i].count == CardDeck.share.max_num-1 && deckAns[i].last?.type == ts {
                    return [(1, i)]
                }
            }
            for i in 0..<deckPos.count {
                if deckPos[i].count == 0 {
                    return [(0, i)]
                }
            }
        }
        
        for i in 0..<deckPos.count {
            let j = deckPos[i].count
            if j > 0 {
                let dst = deckPos[i][j-1]
                if dst.num == ns+1 && ((CardType.index(ts)+1)&1) == CardType.index(dst.type)&1 {
                    ans.append((0,i))
                }
            }
        }
        
        if !islast {
            return ans
        }
        
        for i in 0..<deckAns.count {
            let j = deckAns[i].count
            if j > 0 {
                let dst = deckAns[i][j-1]
                if dst.num == ns-1 && ts == dst.type {
                    ans.append((1,i))
                }
            }
        }
        
        return ans
    }
    func chkSave(t:Int, i:Int) -> Bool {
        let pos = savePos.first(where: { p in
            if p.a == t && p.b == i {
                return true
            }
            return false
        })
        
        clearSave()
        
        if pos == nil {
            return false
        }
        
        forcePop(sA: lastA, sX: lastX, sY: lastY, tA: pos!.a, ti: pos!.b)
        moveCount += 1
        return true
    }
    func clearSave() {
        if savePos.count == 0 {
            return
        }
        for (a,b) in savePos {
            switch a {
            case 0:
                deckPos[b][deckPos[b].count-1].ischk = false
            case 1:
                deckAns[b][deckAns[b].count-1].ischk = false
            default:
                break
            }
        }
        savePos = []
    }
    
    // タップ時移動処理
    
    // 複数移動先の選択位置に移動
    func forcePop(sA:Int, sX:Int, sY:Int, tA:Int, ti:Int) {
        if sA == 0 {
            popPosSub(ix: sX, iy: sY, t: tA, i: ti)
        } else if sA == 1 {
            if tA == 0 {
                doAns(stck: DeckMove(.ans, sX, sY, .pos, ti))
            } else { // これ無いよね
                doAns(stck: DeckMove(.ans, sX, sY, .ans, ti))
            }
        } else {
            popOpnSub(t: tA, ix: ti)
        }
    }
    func popAns(_ ix:Int, _ iy:Int) -> Bool {
        if ix < 0 || ix >= deckAns.count || iy < 0 || iy >= deckAns[ix].count {
            return false
        }
        let src = deckAns[ix][iy]
        let dstp = srchDst(src: src)
        if dstp.count == 0 {
            return false
        }
        
        if dstp.count > 1 {
            lastA = 1
            lastX = ix
            lastY = iy
            savePos = dstp
            for (a,b) in dstp {
                switch a {
                case 0:
                    deckPos[b][deckPos[b].count-1].ischk = true
                case 1:
                    deckAns[b][deckAns[b].count-1].ischk = true
                default:
                    break
                }
            }
            return true
        }
        
        let t = dstp[0].a
        let i = dstp[0].b
        if t == 0 {
            doAns(stck: DeckMove(.ans, ix, iy, .pos, i))
            moveCount += 1
        } else { // これは無いはず -> ansの１をタップした時
//            doAns内でans->ansは無視されている
//            doAns(stck: DeckMove(.ans, ix, iy, .ans, i))
//            return true
        }
        return false
    }
    func popPosSub(ix:Int, iy:Int, t:Int, i:Int) {
        //        let src = deckPos[ix][iy]
        if iy == deckPos[ix].count-1 {
            if t == 0 {
                doPos(stck: DeckMove(.pos, ix, iy, .pos, i))
            } else {
                doPos(stck: DeckMove(.pos, ix, iy, .ans, i))
            }
            return
        }
        
        doPos(stck: DeckMove(.pos, ix, iy, .pos, i))
    }
    func popPos(_ ix:Int, _ iy:Int) -> Bool {
        if ix < 0 || ix >= deckPos.count || iy < 0 || iy >= deckPos[ix].count {
            return false
        }
        let src = deckPos[ix][iy]
        let dstp = srchDst(src: src, islast:iy == deckPos[ix].count-1)
        if dstp.count == 0 {
            return false
        }
        
        if dstp.count > 1 && dstp[dstp.count-1].a == 0 {
            lastA = 0
            lastX = ix
            lastY = iy
            savePos = dstp
            for (a,b) in dstp {
                switch a {
                case 0:
                    deckPos[b][deckPos[b].count-1].ischk = true
                case 1:
                    deckAns[b][deckAns[b].count-1].ischk = true
                default:
                    break
                }
            }
            return true
        }
        
        var idt = 0
        if dstp[dstp.count-1].a != 0 {
            idt = dstp.count-1
        }
        popPosSub(ix: ix, iy: iy, t: dstp[idt].a, i: dstp[idt].b)
        moveCount += 1
        return false
    }
    func popStk() -> Bool {
        if deckStk.count == 0 {
            return false
        }
        doPop(stck: DeckMove(.stk, 0, 0, .opn, 0))
        return false
    }
    func updateOpn() {
        let n = deckOpn.count
        for i in 0..<n {
            deckOpn[i].x = opnX(i)
            deckOpn[i].y = opnY(i)
        }
    }
    func popOpnSub(t:Int, ix:Int) {
        if t == 0 {
            doOpn(stck: DeckMove(.opn, 0, deckOpn.count-1, .pos, ix))
        } else {
            doOpn(stck: DeckMove(.opn, 0, deckOpn.count-1, .ans, ix))
        }
        
    }
    func popOpn(_ ix:Int, _ iy:Int) -> Bool {
        if deckOpn.count == 0 {
            return false
        }
        let src = deckOpn.last!
        let dstp = srchDst(src: src)
        if dstp.count == 0 {
            return false
        }
        
        if dstp.count > 1 && dstp[dstp.count-1].a == 0 {
            lastA = 2
            lastX = ix
            lastY = iy
            savePos = dstp
            for (a,b) in dstp {
                switch a {
                case 0:
                    deckPos[b][deckPos[b].count-1].ischk = true
                case 1:
                    deckAns[b][deckAns[b].count-1].ischk = true
                default:
                    break
                }
            }
            return true
        }
        
        var idt = 0
        if dstp[dstp.count-1].a != 0 {
            idt = dstp.count-1
        }
        popOpnSub(t: dstp[idt].a, ix: dstp[idt].b)
        moveCount += 1
        return false
    }
    
    func backStk() -> Bool {
        deckStk = []
        let n = deckOpn.count
        for i in 0..<n {
            let tc = deckOpn[n-i-1]
            tc.x = stkX(i) //bX+bW*6
            tc.y = stkY(i) //bY
            tc.stt = .down
            deckStk.append(tc)
        }
        deckOpn = []
        return false
    }
    
    func backOpn() {
        deckOpn = []
        let n = deckStk.count
        for i in 0..<n {
            let tc = deckStk[n-i-1]
            tc.stt = .up
            deckOpn.append(tc)
        }
        deckStk = []
        updateOpn()
        return
    }
    
    // 完了チェック
    
    func checkComp() -> Int {
        for i in 0..<deckPos.count {
            if deckPos[i].count > 0 && deckPos[i][0].stt != .up {
                return 0
            }
        }
//        for i in 0..<deckAns.count {
//            if deckAns[i].count == 0 {
//                return 0
//            }
//        }
        
        for i in 0..<deckAns.count {
            if deckAns[i].count < CardDeck.share.max_num {
                return 1
            }
        }
        
        return 2
    }
    
    // 自動完了
    // autoComp後のundoはstk->ansが未対応なので、未サポートとする
    // autoComp後のundoはalert後にリセットする
    func autoComp() -> Bool {
        for ii in 0..<deckAns.count {
            if deckAns[ii].count == 0 {
                for i in 0..<deckPos.count {
                    if deckPos[i].count > 0  && deckPos[i][deckPos[i].count-1].num == 1 {
                        doPop(stck: DeckMove(.pos, i, deckPos[i].count-1, .ans, ii), needPush: false)
                        doMove()
                        return true

                    }
                }
                for i in 0..<deckOpn.count {
                    if deckOpn[i].num == 1 {
                        doOpn(stck: DeckMove(.opn, 0, i, .ans, ii), needPush: false)
                        updateOpn()
                        doMove()
                        return true
                    }
                }
                for i in 0..<deckStk.count {
                    if deckStk[i].num == 1 {
                        let src = deckStk.remove(at: i)
                        let n = deckAns[ii].count
                        let x = src.x
                        let y = src.y
                        src.x = ansX(ii, n) //CGFloat(jx)*bW+bX
                        src.y = ansY(ii, n) //bY
                        setMove(.stk, x, y, .ans, ii, src)
//                        push(.ans, ii, n+1, .stk, deckStk.count)
                        doMove()
                        return true
                    }
                }
                return false // ありえない
            }
            else if deckAns[ii].count > 0 && deckAns[ii][deckAns[ii].count-1].num != CardDeck.share.max_num {
                let dt = deckAns[ii][deckAns[ii].count-1]
                let t = dt.type
                let n = dt.num+1
                for i in 0..<deckPos.count {
                    if deckPos[i].count > 0 {
                        let src = deckPos[i][deckPos[i].count-1]
                        if src.type == t && src.num == n {
                            doPop(stck: DeckMove(.pos, i, deckPos[i].count-1, .ans, ii), needPush: false)
                            doMove()
//                            moveCount += 1
                            return true
                        }
                    }
                }

                for i in deckOpn.indices {
                    if deckOpn[i].type == t && deckOpn[i].num == n {
                        doOpn(stck: DeckMove(.opn, 0, i, .ans, ii), needPush: false)
                        updateOpn()
                        doMove()
//                        moveCount += 1
                        return true
                    }
                }

                for i in deckStk.indices {
                    if deckStk[i].type == t && deckStk[i].num == n {
                        let src = deckStk.remove(at: i)
                        let n = deckAns[ii].count
                        let x = src.x
                        let y = src.y
                        src.x = ansX(ii, n) //CGFloat(jx)*bW+bX
                        src.y = ansY(ii, n) //bY
                        src.stt = .up
                        setMove(.stk, x, y, .ans, ii, src)
//                        push(.ans, ii, n+1, .stk, deckStk.count)
                        doMove()
//                        moveCount += 1
                        return true
                    }
                }
            }
        }
        
        return  false
    }
    
    func onTap(_ p:CGPoint) -> Bool { // todo
        var ret:Bool = false

        for i in (0..<CardDeck.share.max_type).reversed() {
            let j = deckAns[i].count-1
            let x = ansX(i,j)
            let y = ansY(i,j)
            if  j >= 0 && x <= p.x && p.x <= x+bW && y <= p.y && p.y <= y+bH {
                if chkSave(t: 1, i: i) {
                    return false
                }
                ret = popAns(i, j)
                return ret
            }
        }

        let js = deckStk.count-1
        let xs = stkX(js)
        let ys = stkY(js)
        if xs <= p.x && p.x <= xs+bW && ys <= p.y && p.y <= ys+bH {
            clearSave()
            if js >= 0 {
                ret = popStk()
            } else { // リストア
                ret = backStk()
                push(.rev, 0, 0, .opn, 0)
            }
            return ret
        }

        let no = deckOpn.count
        for i in 0..<3 {
            if no-i > 0 {
                let j = no-i-1
                let x = opnX(j)
                let y = opnY(j)
                if x <= p.x && p.x <= x+bW && y <= p.y && p.y <= y+bH {
                    ret = popOpn(j, 0)
                    return ret
                }
            }
        }
        
        for i in 0..<deckPos.count {
            let n = deckPos[i].count
            for j in (0..<n).reversed() {
                let dt = deckPos[i][j]
                let x = dt.x //posX(i,j,n)
                let y = dt.y //posY(i,j,n)
                if x <= p.x && p.x <= x+bW && y <= p.y && p.y <= y+bH && deckPos[i][j].stt == .up {
                    if chkSave(t: 0, i: i) {
                        return false
                    }
                    ret = popPos(i, j)
                    return ret
                }
            }
        }

        clearSave()

        return ret
    }
}
