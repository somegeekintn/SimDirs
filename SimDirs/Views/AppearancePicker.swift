//
//  AppearancePicker.swift
//  SimDirs
//
//  Created by Casey Fleser on 7/31/22.
//

import SwiftUI

struct AppearancePicker: View {
    @Environment(\.isEnabled) var isEnabled
    @Binding var scheme : ColorScheme?
    
    var body: some View {
        HStack(spacing: 16.0) {
            Button("Light") {
                scheme = .light
            }
            .buttonStyle(.appearance(selected: scheme == .light, scheme: .light))
            
            Button("Dark") {
                scheme = .dark
            }
            .buttonStyle(.appearance(selected: scheme == .dark, scheme: .dark))
        }
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

struct AppearancePicker_Previews: PreviewProvider {
    @State static var scheme    : ColorScheme? = .light
    
    static var previews: some View {
        AppearancePicker(scheme: $scheme)
            .disabled(false)
        AppearancePicker(scheme: $scheme)
            .disabled(true)
    }
}
