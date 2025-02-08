//
//  cardApp.swift
//  card
//
//  Created by msykykt on 2024/08/13.
//

import SwiftUI

@main
struct cardApp: App {

    var body: some Scene {
        WindowGroup {
            SplashView()
            // https://zenn.dev/entaku/articles/fbe0683bcd36b6
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                print("Received background notification in SwiftUI view")
                CardDeck.share.saveDeck()
                Setting.instance.save()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                print("Received foreground notification in SwiftUI view")
                    // PlayViewが先につくられる。
                    // selectionを変えないと強制更新ができないのが、方法がなくここの変更が反映されない
/*                    if let saveDt = UserDefaults.standard.string(forKey: "deck") {
                        CardDeck.share.decodeDeck(saveDt)
                        CardDeck.share.isReset = false
                        CardDeck.share.relayout()
                        CardDeck.share.resetDeck()
                        doUpdate.toggle()
                        selection = 1
                   }*/
                 }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                print("Received active notification in SwiftUI view")
            }
            // bacgroundで動作していない場合、killしても呼ばれない
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                print("Received terminate notification in SwiftUI view")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                print("Received will resign active notification in SwiftUI view")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                print("Received significant time change notification in SwiftUI view")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                print("Received memory warning notification in SwiftUI view")
            }
            // https://qiita.com/SNQ-2001/items/81fc52328d9a4c4a0196
//            .onOpenURL(perform: { url in
//                print("Received open URL in SwiftUI view: \(url)")
//                if url.scheme?.lowercased() == "yukari" {
//                    startcode = url.host!
//                    CardDeck.share.schemeDeck = startcode
//                }
//            })
        }
    }
}
