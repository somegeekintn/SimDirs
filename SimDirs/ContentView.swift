//
//  ContentView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    enum Style: Int, CaseIterable, Identifiable {
        case placeholder
        case byDevice
        case byRuntime
        
        var id      : Int { rawValue }
        var visible : Bool { self != .placeholder }

        var title   : String {
            switch self {
                case .placeholder:  return "Placeholder"
                case .byDevice:     return "By Device"
                case .byRuntime:    return "By Runtime"
            }
        }
    }

    @State var filter       = SourceFilter.restore()
    @State var viewID       = UUID().uuidString
    @State var style        = Style.byDevice
    let model   : SimModel
    
    init(model: SimModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            NavigationView {
                FilteredNodeView(filter: $filter) { items }
                    .id(viewID)
                    .toolbar { ToolbarItem { ToolbarMenu(style: $style, filter: $filter) } }
                    .frame(minWidth: 200)
                
                Image("Icon-256")   // Initial View
            }
        }
        .onChange(of: style) { _ in resetView() }
        .environment(\.deviceUpdates, model.deviceUpdates)
    }
    
    @NodeListBuilder
    var items: [some Node] {
        switch style {
            case .placeholder:  [] as [LeafNode]
            case .byDevice:     SimProductFamily.presentation.map { $0.linked(from: model) }
            case .byRuntime:    SimPlatform.presentation.map { $0.linked(from: model) }
        }
    }

    func resetView() {
        viewID = UUID().uuidString
    }
}

struct ContentView_Previews: PreviewProvider {
    static var model = SimModel()

    static var previews: some View {
        ContentView(model: model)
            .preferredColorScheme(.dark)
        ContentView(model: model)
            .preferredColorScheme(.light)
    }
}

private struct DeviceUpdatesKey: EnvironmentKey {
    static let defaultValue = PassthroughSubject<SimModel.Update, Never>()
}

extension EnvironmentValues {
    var deviceUpdates: PassthroughSubject<SimModel.Update, Never> {
        get { self[DeviceUpdatesKey.self] }
        set { self[DeviceUpdatesKey.self] = newValue }
    }
}
