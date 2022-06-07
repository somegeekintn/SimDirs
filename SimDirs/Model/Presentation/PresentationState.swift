//
//  PresentationState.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/7/22.
//

import Foundation

struct PresentationState {
    enum Organization: String, CaseIterable, Identifiable {
        case byDevice  = "By Device"
        case byRuntime = "By Runtime"

        var id: Organization { self }
    }

    struct Filter: OptionSet, CaseIterable {
        let rawValue:   Int
        
        static let withApps         = Filter(rawValue: 1 << 0)
        static let runtimeInstalled = Filter(rawValue: 1 << 1)

        static var allCases         : [Filter] = [.withApps, .runtimeInstalled]
    }
    
    var organization    = Organization.byRuntime
    var filter          = Filter()
    var searchTerm      = ""
    
    static func testItemsOf<T>(type: T.Type) -> [T] {
        let flatItems = PresentationState().presentationItems(from: SimModel()).flatItems
        
        return flatItems.itemsOf(type: type)
    }

    func presentationItems(from model: SimModel) -> [PresentationItem] {
        switch organization {
            case .byDevice:     return itemsForDeviceStyle(from: model)
            case .byRuntime:    return itemsForRuntimeStyle(from: model)
        }
    }

    func itemsForDeviceStyle(from model: SimModel) -> [PresentationItem] {
        return SimProductFamily.presentation.map{ family in
            var familyItem  = PresentationItem(family)
            
            familyItem.children = model.deviceTypes.filter({ $0.supports(productFamily: family) }).map { deviceType in
                var deviceTypeItem      = PresentationItem(deviceType, identifier: deviceType.id)
                let deviceTypeChildren  : [PresentationItem] = model.runtimes.filter({ $0.supports(deviceType: deviceType) }).map { runtime in
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
    
    func itemsForRuntimeStyle(from model: SimModel) -> [PresentationItem] {
        return SimPlatform.presentation.map{ platform in
            var platformItem  = PresentationItem(platform)
            
            platformItem.children = model.runtimes.filter({ $0.supports(platform: platform) }).map { runtime in
                var runtimeItem         = PresentationItem(runtime)
                let runtimeItemChildren : [PresentationItem] = model.deviceTypes.filter({ $0.supports(runtime: runtime) }).map { deviceType in
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
}

