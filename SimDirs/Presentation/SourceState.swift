//
//  SourceState.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import Foundation
import Combine

class SourceState: ObservableObject {
    enum Style: Int, CaseIterable, Identifiable {
        case placeholder
        case byDevice
        case byRuntime
        
        var id      : Int { rawValue }
        var title   : String {
            switch self {
                case .placeholder:  return "Placeholder"
                case .byDevice:     return "By Device"
                case .byRuntime:    return "By Runtime"
            }
        }
        var visible : Bool {
            switch self {
                case .placeholder:  return false
                default:            return true
            }
        }
    }
    
    @Published var style        = Style.placeholder // { didSet { rebuildBase() } }
    @Published var selection    : UUID?

    var model           : SimModel
    var deviceUpdates   : Cancellable?
    
    init(model: SimModel) {
        self.style = .byDevice
        self.model = model

        deviceUpdates = model.deviceUpdates.sink(receiveValue: applyDeviceUpdates)
    }

#warning("TODO: still need to apply updates")
    func applyDeviceUpdates(_ updates: SimDevicesUpdates) {
#if false
        switch base {
            case .placeholder:
                break

            case let .device(_, item):
                for prodFamily in item.children {
                    for devType in prodFamily.children {
                        for runtime in devType.children {
                            guard updates.runtime.identifier == runtime.data.identifier else { continue }
                            let devTypeDevices  = updates.additions.filter { $0.isDeviceOfType(devType.data) }
                            
                            runtime.children = runtime.children.filter { device in !updates.removals.contains { $0.udid == device.data.udid } }
                            runtime.children.append(contentsOf: devTypeDevices.map { device in
                                let imageDesc = devType.imageDesc.withColor(device.isAvailable ? .green : .red)

                                return Device(data: device, children: device.apps.map { app in App(data: app, children: []) }, customImgDesc: imageDesc)
                            })
                        }
                    }
                }

            case let .runtime(_, item):
                for platform in item.children {
                    for runtime in platform.children {
                        guard updates.runtime.identifier == runtime.data.identifier else { continue }
                        
                        for devType in runtime.children {
                            let devTypeDevices  = updates.additions.filter { $0.isDeviceOfType(devType.data) }
                            
                            devType.children = devType.children.filter { device in !updates.removals.contains { $0.udid == device.data.udid } }
                            devType.children.append(contentsOf: devTypeDevices.map { device in
                                let imageDesc = devType.imageDesc.withColor(device.isAvailable ? .green : .red)

                                return Device(data: device, children: device.apps.map { app in App(data: app, children: []) }, customImgDesc: imageDesc)
                            })
                        }
                    }
                }
        }
        
        applyFilter()
#endif
    }

    @NodeListBuilder
    var items: some NodeList {
        switch style {
            case .placeholder:  [] as [LeafNode]
            case .byDevice:     deviceStyleItems
            case .byRuntime:    runtimeStyleItems
        }
    }

    @NodeListBuilder
    var deviceStyleItems: some NodeList {
        SimProductFamily.presentation.linkEachTo { family in
            model.deviceTypes.supporting(productFamily: family).linkEachTo(emptyIsNil: true) { devType in
                model.runtimes.supporting(deviceType: devType).linkEachTo(emptyIsNil: true) { runtime in
                    runtime.devices.linkingDeviceType(devType)
                }
            }
        }
    }
    
    @NodeListBuilder
    var runtimeStyleItems: some NodeList {
        SimPlatform.presentation.linkEachTo(emptyIsNil: true) { platform in
            model.runtimes.supporting(platform: platform).linkEachTo(emptyIsNil: true) { runtime in
                model.deviceTypes.supporting(runtime: runtime).linkEachTo(emptyIsNil: true) { devType in
                    runtime.devices.linkingDeviceType(devType)
                }
            }
        }
    }
}

