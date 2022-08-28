//
//  DescriptiveToggleStyle.swift
//  SimDirs
//
//  Created by Casey Fleser on 8/7/22.
//

import SwiftUI

struct DescriptiveToggleStyle<T: ToggleDescriptor>: ToggleStyle {
    @Environment(\.isEnabled) var isEnabled
    @State var isFocused    = false

    var descriptor  : T
    var subtitled   : Bool
    
    init(_ descriptor: T, subtitled: Bool = true) {
        self.descriptor = descriptor
        self.subtitled = subtitled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .foregroundColor(descriptor.circleColor.opacity(isFocused ? 1.0 : 0.9))
                    descriptor.image
                        .resizable()
                        .foregroundColor(descriptor.isOn ? .white : Color("CircleSymbolOff"))
                        .aspectRatio(contentMode: .fit)
                        .padding(9)
                }
                .frame(width: 36, height: 36)
                .padding(.bottom, 4)

                Group {
                    Text(descriptor.titleKey)
                        .fontWeight(.semibold)
                    
                    if subtitled {
                        Text(descriptor.text)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.system(size: 11))
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
            }
            .onHover { isFocused = $0 && isEnabled }
        }
        .buttonStyle(.plain)
    }
}
