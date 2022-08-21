//
//  AppearanceButtonStyle.swift
//  SimDirs
//
//  Created by Casey Fleser on 8/21/22.
//

import SwiftUI

extension ButtonStyle where Self == AppearanceButtonStyle {
    static func appearance(selected: Bool, scheme: ColorScheme) -> AppearanceButtonStyle {
        AppearanceButtonStyle(selected: selected, scheme: scheme)
    }
}

struct AppearanceButtonStyle: ButtonStyle {
    let selected    : Bool
    let scheme      : ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            let bordered = selected != configuration.isPressed
            let color = scheme == .light ? Color.white : Color.black
            let content = color
                .frame(width: 48, height: 32)
                .cornerRadius(5.0)

            if bordered {
                content
                    .overlay(
                        RoundedRectangle(cornerRadius: 6.0)
                            .stroke(Color.accentColor, lineWidth: 2.0)
                    )
            }
            else {
                content
                    .shadow(color: .black.opacity(0.5), radius: 1.0, x: 0, y: 1.0)
            }
            
            configuration.label
        }
        .padding(1.0)
    }
}
