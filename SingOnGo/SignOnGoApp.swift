//
//  SingOnGoApp.swift
//  SingOnGo
//
//  Created by Vitaly on 24/12/21.
//

import SwiftUI

@main
struct SingOnGoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ViewModel())
        }
    }
}
