//
//  SettingView.swift
//  card
//
//  Created by msykykt on 2024/10/10.
//

import SwiftUI

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}

struct HostView: View {
    @Binding var isHost: Bool
    @Binding var host: String

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isHost = false
                }) { Image(systemName: "xmark.square").frame(width: 20, height: 20) }.padding(.trailing, 10)
            }.padding(.top, 10)
            HStack {
                Text("set_host")
                TextField("set_nofound", text: $host).border(Color.black, width: 1).padding(.trailing, 10)
            }
            Button("set_regist", action: {
                UserDefaults.standard.set(host, forKey: "host")
                isHost = false
            }).padding(.bottom, 10)
        }.border(Color.black, width: 1)
    }
}

struct SettingView: View {
    @Binding var selection: Int
    @State var showAlert: Bool = true
    @State var isSecret: Bool = false
    
    @State var type: PosType = .standard
    @State var num: String = "0"
    @State var npos: String = "0"
    @State var ctype: String = "0"
    @State var level: Int = 2
    @State var username: String = ""
    @State var host: String = ""
    @State var isHost: Bool = false
    
    @State var numVal:Double = 0
    @State var nposVal:Double = 0
    @State var ctypeVal:Double = 0
    @State var levVal:Double = 0
    
    let typemenu: [PosType] = [ .standard, .valley, .mountain, .diamond]

    var body: some View {
        VStack {
            Text("set_setting")
            HStack {
                Text("set_select_alert")
                Toggle("", isOn: $showAlert)
                    .frame(width: 50)
            }
            HStack {
                Text("set_hint_secret")
                Toggle("", isOn: $isSecret)
                    .frame(width: 50)
            }
            HStack {
                Text("set_tableau_type")
                Picker("", selection: $type, content: {
                    ForEach(typemenu, id: \.self) { type in
                        // https://dev.classmethod.jp/articles/variable-values-are-not-localized/
                        let str = LocalizedStringKey(type.rawValue)
                        Text(str)
                    }
                })
                .pickerStyle(.menu)
            }
            HStack {
                // https://qiita.com/celcior0913/items/9554140f4bbe20622d59
                Text("set_number").frame(width: 80)
/*                TextField("13", text: Binding(
                    get: {num},
                    set: {num = $0.filter{"0123456789".contains($0)}}))
                .keyboardType(.numberPad)
                    .frame(width: 80).border(Color.black, width: 1)
                    .onChange(of: num) { inputText in
                        if let n = Int(inputText) {
                            if n>13 || n<1 {
                                num = "13"
                            }
                        } else if inputText.isNumber == false {
                            num = "13"
                        }
                    }
                Text("<14")*/
                Text(num).frame(width: 20)
                Slider(value: $numVal, in: 6...13, step: 1, label: { EmptyView() }, minimumValueLabel: { Text("6") }, maximumValueLabel: { Text("13") }) { val in
                    num = String(Int(numVal))
                }.frame(width: 200)
            }
            HStack {
                Text("set_card_type").frame(width: 80)
/*                TextField("4", text: $ctype)
                    .frame(width: 80).border(Color.black, width: 1)
                    .onChange(of: ctype) { inputText in
                        if let n = Int(inputText) {
                            if n>8 || n<1 {
                                ctype = "8"
                            }
                        } else if inputText.isEmpty == false {
                            ctype = "4"
                        }
                    }
                Text("<8")*/
                Text(ctype).frame(width: 20)
                Slider(value: $ctypeVal, in: 2...8, step: 1, label: { EmptyView() }, minimumValueLabel: { Text("2") }, maximumValueLabel: { Text("8") }) { val in
                    ctype = String(Int(ctypeVal))
                }.frame(width: 200)
            }
            HStack {
                Text("set_column")
/*                TextField("8", text: $npos)
                   .frame(width: 80).border(Color.black, width: 1)
                   .onChange(of: npos) { inputText in
                       if let n = Int(inputText) {
                           if n>13 || n<1 {
                               npos = "8"
                           }
                       } else if inputText.isEmpty == false {
                           npos = "8"
                       }
                   }
                Text("<14")*/
                Text(npos).frame(width: 20)
                Slider(value: $nposVal, in: 5...8, step: 1, label: { EmptyView() }, minimumValueLabel: { Text("5") }, maximumValueLabel: { Text("8") }) { val in
                    npos = String(Int(nposVal))
                }.frame(width: 200)
            }.padding(.bottom, 10)
            HStack {
                // http://swift.hiros-dot.net/?p=1424
                Text("set_difficulty")
                Slider(value: $levVal, in: 1...4, step: 1, label: { EmptyView() }, minimumValueLabel: { Text("set_high") }, maximumValueLabel: { Text("set_easy") }) { val in
                    level = Int(levVal)
                }.frame(width: 200)
            }.padding(.bottom, 10)
            HStack {
                Text("rank_nickname").padding()
                TextField(String(localized:"set_nofound"), text: $username).frame(width: 150).border(Color.black, width: 1)
                Spacer()
            }.padding(.bottom, 10)
            HStack{
                Text("set_server").padding(.trailing, 20)
                Button("set_edit", action: {
                    isHost = true
                })
            }.padding(.bottom, 5)
            Text(host)
            if isHost {
                HostView(isHost: $isHost, host: $host).padding()
            }
            Button("set_apply", action: {
                if Int(ctype) != CardDeck.share.max_type || Int(num) != CardDeck.share.max_num || Int(npos) != CardDeck.share.max_pos || type != CardDeck.share.pos_type || level != CardDeck.share.build_type {
                    CardDeck.share.max_type = Int(ctype)!
                    CardDeck.share.max_num = Int(num)!
                    CardDeck.share.pos_type = type
                    CardDeck.share.max_pos = Int(npos)!
                    CardDeck.share.build_type = level
//                    CardDeck.share.relayout()
                    CardDeck.share.rebuildDeck()
                }
                Setting.instance.showAlert = showAlert
                Setting.instance.secret = isSecret
                Setting.instance.host = host
                Setting.instance.save()
                selection = 1
            }).padding(.top, 20)
            Spacer()
        }
//        .sheet(isPresented: $isHost, onDismiss: {
//            print("registed")
//        }, content: {
//            HostView(isHost: $isHost)
//        })
        .onAppear() {
            print("onAppear")
            type = CardDeck.share.pos_type
            num = String(CardDeck.share.max_num)
            ctype = String(CardDeck.share.max_type)
            npos = String(CardDeck.share.max_pos)
            level = CardDeck.share.build_type
            isSecret = Setting.instance.secret
            showAlert = Setting.instance.showAlert
            username = Setting.instance.username
            host = Setting.instance.host

            levVal = Double(level)
            numVal = Double(CardDeck.share.max_num)
            ctypeVal = Double(CardDeck.share.max_type)
            nposVal = Double(CardDeck.share.max_pos)
        }
        .onDisappear() {
        }
    }
}

#Preview {
    var selection: Binding<Int> = .constant(3)
    SettingView(selection: selection)
}

