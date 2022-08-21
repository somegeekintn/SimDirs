//
//  DescriptiveToggleStyle.swift
//  SimDirs
//
//  Created by Casey Fleser on 8/7/22.
//

import SwiftUI

struct DescriptiveToggleStyle<T: ToggleDescriptor>: ToggleStyle {
    var descriptor  : T
    
    init(_ descriptor: T) {
        self.descriptor = descriptor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .foregroundColor(descriptor.circleColor)
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
                    Text(descriptor.text)
                        .foregroundColor(.secondary)
                }
                .font(.system(size: 11))
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
    }
}
