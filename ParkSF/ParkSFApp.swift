//
//  ParkSFApp.swift
//  ParkSF
//
//  Created by Samuel Li on 1/16/24.
//

import SwiftUI

@main
struct ParkSFApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom){
                MapView()
                MenuView()
            }
        }
    }
}
