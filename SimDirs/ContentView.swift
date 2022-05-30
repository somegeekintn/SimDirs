//
//  ContentView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        SimItemList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PresentableModel())
    }
}
