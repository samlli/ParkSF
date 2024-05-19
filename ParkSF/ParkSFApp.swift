//
//  ParkSFApp.swift
//  ParkSF
//
//  Created by Samuel Li on 1/16/24.
//

import SwiftUI

@main
struct ParkSFApp: App {
//    @State private var parkedLocation = ParkedLocation.sampleData
    @State var parkedLocation = ParkedLocation.sampleData
    
    var body: some Scene {
        WindowGroup {
//            ZStack(alignment: .bottom){
//                MapView()
//                MenuView(parkedLocation: $parkedLocation)
//            }
            VStack(alignment: .center){
                MapView()
                    .frame(maxHeight: UIScreen.main.bounds.size.height * 0.33)
                MenuView(parkedLocation: $parkedLocation)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}
