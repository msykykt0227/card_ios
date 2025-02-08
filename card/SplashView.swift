//
//  SplashView.swift
//  card
//
//  Created by msykykt on 2024/10/23.
//

import SwiftUI

// https://qiita.com/uhooi/items/ce31c80b7f5035e20be7
struct SplashView: View {
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            ZStack {
//                Color("Primary")
//                    .ignoresSafeArea() // ステータスバーまで塗り潰すために必要
                Image("splush")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else {
            ContentView()
        }
    }
}


#Preview {
    SplashView()
}
