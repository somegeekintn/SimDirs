//
//  DescriptiveToggle.swift
//  SimDirs
//
//  Created by Casey Fleser on 8/7/22.
//

import SwiftUI

protocol ToggleDescriptor {
    var isOn        : Bool { get }
    var titleKey    : LocalizedStringKey { get }
    var text        : String { get }
    var image       : Image { get }
}

extension ToggleDescriptor {
    var circleColor : Color { isOn ? .accentColor : Color("CircleSymbolBkgOff") }
}

struct DescriptiveToggle<T: ToggleDescriptor>: View {
    @Binding var isOn   : Bool
    var descriptor      : T
    var subtitled       : Bool
    
    init(_ descriptor: T, isOn: Binding<Bool>, subtitled: Bool = true) {
        self._isOn = isOn
        self.descriptor = descriptor
        self.subtitled = subtitled
    }
    
    var body: some View {
        Toggle(descriptor.titleKey, isOn: _isOn)
            .toggleStyle(DescriptiveToggleStyle(descriptor, subtitled: subtitled))
    }
}

struct DescriptiveToggle_Previews: PreviewProvider {
    struct DarkMode: ToggleDescriptor {
        var isOn        : Bool = true
        var titleKey    : LocalizedStringKey { "Dark Mode" }
        var text        : String { isOn ? "On" : "Off" }
        var image       : Image { Image(systemName: "circle.circle") }
    }

    @State static var toggle  = DarkMode()
    
    static var previews: some View {
        DescriptiveToggle(DarkMode(), isOn: $toggle.isOn)
            .disabled(true)
    }
}
