//
//  MenuView.swift
//  ParkSF
//
//  Created by Samuel Li on 1/17/24.
//

import SwiftUI

struct MenuView: View {
    @State private var showingCredits = true
    @State private var sheetContentHeight = CGFloat(0)

    var body: some View {
        Button("Show Menu") {
            showingCredits.toggle()
        }
        .sheet(isPresented: $showingCredits) {
            VStack {
                Text("line 1")
                Text("line 2")
                Text("line 3")
            }
            .padding()
            .background {
                //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                GeometryReader { proxy in
                    Color.clear
                        .task {
                            print("size = \(proxy.size.height)")
                            sheetContentHeight = proxy.size.height
                        }
                }
            }
            .presentationDetents([.medium, .large, .height(sheetContentHeight)])
            .presentationBackgroundInteraction(.enabled)
        }
    }
}

#Preview {
    MenuView()
}
