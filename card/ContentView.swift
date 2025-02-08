//
//  ContentView.swift
//  card
//
//  Created by msykykt on 2024/08/13.
//

import SwiftUI
import WebKit
import Network

// https://qiita.com/Yporon/items/571fe022891db3e72c00
class NetworkObserver {
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue.global(qos: .background) // 使用用途に合わせたqosを指定してください
  
  /// ネットワーク接続状態を監視
    func startMonitoring(cb:@escaping (Bool) -> Void) {
    monitor.start(queue: queue)
    
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        print("online")
      } else {
        print("offline")
          cb(false)
      }
      
      // ここから接続状態を判定
      if path.usesInterfaceType(.wifi) {
        print("Wi-Fi networks")
      } else if path.usesInterfaceType(.cellular) {
        print("cellular networks")
          cb(false)
      } else if path.usesInterfaceType(.wiredEthernet) {
        print("wired Ethernet networks")
      } else if path.usesInterfaceType(.loopback) {
        print("local loopback networks")
      } else if path.usesInterfaceType(.other) {
        print("virtual networks or networks of unknown types")
          cb(false)
      }
        cb(true)
    }
  }

  /// ネットワーク接続状態の監視を終了
  func stopMonitoring() {
    monitor.cancel()
  }
}
struct ContentView: View {
    @State var selection : Int = 1
    @State var isRegist: Bool = false
//    @State var cdt: CardDeck
    @State var showHelp: Bool = false
    @State var keepSeacret:Bool = false
    
    init() {
        let appearance: UITabBarAppearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
//        appearance.backgroundColor = .yellow
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
        print("init ContentView")
    }

    var body: some View {
        
        GeometryReader { geometry in
            let sal = geometry.safeAreaInsets.leading
            let sat = geometry.safeAreaInsets.top
            let sab = geometry.safeAreaInsets.bottom
            let sar = geometry.safeAreaInsets.trailing
            // 幅・高さはsafearea
            let w = geometry.size.width
            let h = geometry.size.height-sat-sab-30.0 // SE3 30以上にすると設定無視される。16PMでも可
            //            let h = geometry.size.height-sat-sab+46.0 // 16PM 46以上にすると設定無視される
            // https://blog.code-candy.com/tabview_basic/
            // 原因不明だが初期表示後、何かをタップするとTabViewの更新が一度だけ再度はしる。
            //（initは呼ばれないのでContentViewの作成では無い
            //　調べたところGeometryReaderが呼ばれる模様
            ZStack {
            TabView(selection: $selection) {
                
                PlayView(winW: (w-sal-sar-4.0)*0.98, winH: h*0.98, selection: $selection, isRegist: $isRegist)   // Viewファイル①
                    .frame(width: w-sal-sar-4.0, height: h)
                    .tabItem {
                        Label("content_game", systemImage: "house.fill")
                    }
                    .background(Color(red: 0.5, green: 1.0, blue: 0.5, opacity: 1.0))
                    .tag(1)
                
                RankView(w:w, h:h, isRegist: $isRegist, selection: $selection)   // Viewファイル②
                    .tabItem {
                        Label("content_rank", systemImage: "folder.badge.person.crop")
                    }
                    .tag(2)
                
                SettingView(selection: $selection)  // Viewファイル③
                    .tabItem {
                        Label("content_setting", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            } // TabView ここまで
            .background(Color.blue)
//            .statusBarHidden(true)
            if selection == 1 {
                Button(action: {
                    showHelp.toggle()
                }) {
                    Image(systemName: "info.circle.fill").font(.system(size: 20))
                }.position(x: w-20.0, y: 20)
                if showHelp {
                    HelpView(w:w, h:h, showHelp: $showHelp)
                }
            }
        }.background(Color.gray)
    }

} // body
//シングルトンで対応
/*    init() {
    self.cdt = CardDeck()
}*/
}

struct HelpView: View {
    @State var w: CGFloat
    @State var h: CGFloat
    @Binding var showHelp: Bool
    
    var body: some View {
        VStack {
            Text("Show Help")
                .font(.headline)
                .padding()
            WebView(loardUrl: URL(string:"http://koruri.anime.coocan.jp/yukaridb/public/card/help")).frame(width: w, height: h-100)
//            WebView(loardUrl: URL(string:"https://www.tamurayukari.com")).frame(width: w, height: h-100)
            Button("content_close") {
                showHelp.toggle()
            }.padding()
        }.background(Color.white)
    }
    
    // https://swifty-ui.com/wkwebview/
    struct WebView: UIViewRepresentable {
        
        let loardUrl: URL?
        
        func makeUIView(context: Context) -> WKWebView {
            return WKWebView()
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {
            let ob = NetworkObserver()
            ob.startMonitoring(cb: { flg in
                var islocal = flg
                ob.stopMonitoring()
                DispatchQueue.main.sync {
                    if islocal {
                        if loardUrl != nil {
                            let request = URLRequest(url: loardUrl!)
                            uiView.load(request)
                            return
                        }
                    } else {
                        var hnm = "help_en"
                        if Locale(identifier: Locale.preferredLanguages.first!) == .init(identifier: "ja-JP") {
                            hnm = "help"
                        }
                        guard let url = Bundle.main.url(forResource: "help", withExtension: "html") else { return }
                        uiView.loadFileURL(url, allowingReadAccessTo: url)
                       }
                }
            })
            
        }
    }
}
#Preview {
//    var selection: Binding<Int> = .constant(0)
ContentView()
}
