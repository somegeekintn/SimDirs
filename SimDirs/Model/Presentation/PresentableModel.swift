//
//  PresentableModel.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/25/22.
//

import Foundation

struct PresentationFilter: OptionSet, CaseIterable {
    let rawValue:   Int
    
    static let withApps         = PresentationFilter(rawValue: 1 << 0)
    static let runtimeInstalled = PresentationFilter(rawValue: 1 << 1)

    static var allCases         : [PresentationFilter] = [.withApps, .runtimeInstalled]
}
    
class PresentableModel: ObservableObject {
    enum Style {
        case byDevice
        case byRuntime
    }
    
    var baseModel   = SimModel()
    var style       = Style.byRuntime
    var items       = [PresentationItem]()
    var flatItems   : [PresentationItem] { items.flatMap { $0.flattened } }
    
    init() {
        rebuildPresentation()
        validateItems()
//        dumpPresentationItems(items)
    }
    
    func filteredItems(filter: PresentationFilter) -> [PresentationItem] {
        return items.map { $0.filtered(filter) }
    }
    
    func rebuildPresentation() {
        switch style {
            case .byDevice:     items = itemsForDevicePresentation()
            case .byRuntime:    items = itemsForRuntimePresentation()
        }
    }
    
    func itemsForDevicePresentation() -> [PresentationItem] {
        return SimProductFamily.presentation.map{ family in
            var familyItem  = PresentationItem(family)
            
            familyItem.children = baseModel.deviceTypes.filter({ $0.supports(productFamily: family) }).map { deviceType in
                var deviceTypeItem      = PresentationItem(deviceType, identifier: deviceType.id)
                let deviceTypeChildren  : [PresentationItem] = baseModel.runtimes.filter({ $0.supports(deviceType: deviceType) }).map { runtime in
                    var runtimeItem         = PresentationItem(runtime, identifier: "\(deviceType.id) - \(runtime.id)")
                    let runtimeItemChildren = runtime.devices.filter({ $0.isDeviceOfType(deviceType) }).map { device -> PresentationItem in
                        var deviceItem          = PresentationItem(device, image: family.imageName)
                        let deviceItemChildren  = device.apps.map { PresentationItem($0) }
                        
                        if !deviceItemChildren.isEmpty {
                            deviceItem.children = deviceItemChildren
                        }
                        
                        return deviceItem
                    }

                    if !runtimeItemChildren.isEmpty {
                        runtimeItem.children = runtimeItemChildren
                    }

                    return runtimeItem
                }
                
                if !deviceTypeChildren.isEmpty {
                    deviceTypeItem.children = deviceTypeChildren
                }
                
                return deviceTypeItem
            }

            return familyItem
        }
    }
    
    func itemsForRuntimePresentation() -> [PresentationItem] {
        return SimPlatform.presentation.map{ platform in
            var platformItem  = PresentationItem(platform)
            
            platformItem.children = baseModel.runtimes.filter({ $0.supports(platform: platform) }).map { runtime in
                var runtimeItem         = PresentationItem(runtime)
                let runtimeItemChildren : [PresentationItem] = baseModel.deviceTypes.filter({ $0.supports(runtime: runtime) }).map { deviceType in
                    var deviceTypeItem      = PresentationItem(deviceType, identifier: "\(runtime.id) - \(deviceType.id)")
                    let deviceTypeChildren  = runtime.devices.filter({ $0.isDeviceOfType(deviceType) }).map { device -> PresentationItem in
                        var deviceItem          = PresentationItem(device, image: deviceType.imageName)
                        let deviceItemChildren  = device.apps.map { PresentationItem($0) }
                        
                        if !deviceItemChildren.isEmpty {
                            deviceItem.children = deviceItemChildren
                        }
                        
                        return deviceItem
                    }

                    if !deviceTypeChildren.isEmpty {
                        deviceTypeItem.children = deviceTypeChildren
                    }

                    return deviceTypeItem
                }
                
                if !runtimeItemChildren.isEmpty {
                    runtimeItem.children = runtimeItemChildren
                }

                return runtimeItem
            }

            return platformItem
        }
    }
    
    func itemsOf<T> (type: T.Type) -> [T] {
        return flatItems.compactMap { $0.underlying as? T }
    }

    func validateItems() {
        let allIDs = flatItems.map { $0.id }
        var idSet   = Set<String>()
        
        print("Validating \(allIDs.count) items")
        for id in allIDs {
            if !idSet.insert(id).inserted {
                print("Duplicate PresentationItem.id: \(id)")
            }
        }
    }
    
    func dumpPresentationItems(_ items: [PresentationItem], level: Int = 0) {
        let ident = Array(repeating: "\t", count: level).joined()
        
        for item in items {
            print("\(ident)\(item.title) [\(item.id)]")
            
            if let children = item.children {
                dumpPresentationItems(children, level: level + 1)
            }
        }
    }
}

