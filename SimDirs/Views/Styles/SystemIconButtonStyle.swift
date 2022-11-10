//
//  SystemIconButtonStyle.swift
//  SimDirs
//
//  Created by Casey Fleser on 8/21/22.
//

import SwiftUI

extension ButtonStyle where Self == SystemIconButtonStyle {
    static func systemIcon(_ imageName: String, active: Bool = false) -> SystemIconButtonStyle {
        SystemIconButtonStyle(imageName, active: active)
    }
}

struct SystemIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @State var isFocused    = false
    let isActive            : Bool
    let imageName           : String
    
    init(_ imageName: String, active: Bool = false) {
        self.imageName = imageName
        self.isActive = active
    }
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            ZStack {
                backgroundColor(pressed: configuration.isPressed)
                    .frame(width: 36, height: 36)
                    .cornerRadius(5.0)

                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isActive ? .accentColor : foregroundColor(pressed: configuration.isPressed))
            }
            
            configuration.label
                .foregroundColor(foregroundColor(pressed: configuration.isPressed))
        }
        .padding(1.0)
        .onHover { isFocused = $0 && isEnabled }
    }
    
    func foregroundColor(pressed: Bool) -> Color {
        return .primary.opacity(pressed ? 1.0 : (isEnabled ? 0.7 : 0.4))
    }
    
    func backgroundColor(pressed: Bool) -> Color {
        return .primary.opacity((isEnabled ? 0.1 : 0.05) + (isFocused ? 0.1 : 0.0) + (pressed ? 0.1 : 0.0))
    }
}

struct SystemIconButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Button") { print("do stuff") }
            .preferredColorScheme(.light)
            .buttonStyle(.systemIcon("camera.on.rectangle"))
            .padding(20)
        Button("Button") { print("do stuff") }
            .preferredColorScheme(.dark)
            .buttonStyle(.systemIcon("camera.on.rectangle"))
            .padding(20)
    }
}
