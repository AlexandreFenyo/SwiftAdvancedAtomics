//
//  atomicsApp.swift
//  atomics
//
//  Created by Alexandre Fenyo on 21/02/2024.
//

import SwiftUI

@main
struct AtomicsApp: App {
    init() {
        testAtomics()
        testExceptions()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
