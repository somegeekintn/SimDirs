//
//  SourceState.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import Foundation
import Combine

class SourceState: ObservableObject {
    typealias ProductFamily = SourceItemVal<SimProductFamily, DeviceType_DS>
    typealias Platform      = SourceItemVal<SimPlatform, Runtime_RT>
    typealias DeviceType_DS = SourceItemVal<SimDeviceType, Runtime_DS>
    typealias DeviceType_RT = SourceItemVal<SimDeviceType, Device>
    typealias Runtime_DS    = SourceItemVal<SimRuntime, Device>
    typealias Runtime_RT    = SourceItemVal<SimRuntime, DeviceType_RT>
    typealias Device        = SourceItemVal<SimDevice, App>
    typealias App           = SourceItemVal<SimApp, SourceItemNone>

    enum Base: Identifiable {
        case placeholder(id: UUID = UUID())
        case device(id: UUID = UUID(), SourceItemVal<SourceItemDataNone, ProductFamily>)
        case runtime(id: UUID = UUID(), SourceItemVal<SourceItemDataNone, Platform>)

        var id      :  UUID {
            switch self {
                case let .placeholder(id):  return id
                case let .device(id, _):    return id
                case let .runtime(id, _):   return id
            }
        }
    }

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
    
    @Published var style        = Style.placeholder { didSet { rebuildBase() } }
    @Published var filter       = SourceFilter() { didSet { applyFilter() } }
    @Published var selection    : UUID?

    var model           : SimModel
    var base            = Base.placeholder()
    var deviceUpdates   : Cancellable?
    
    var filterApps      : Bool {
        get { filter.options.contains(.withApps) }
        set { filter.options.booleanSet(newValue, options: .withApps) }
    }

    var filterRuntimes  : Bool {
        get { filter.options.contains(.runtimeInstalled) }
        set { filter.options.booleanSet(newValue, options: .runtimeInstalled) }
    }

    init(model: SimModel) {
        self.style = .byDevice
        self.model = model
        
        self.rebuildBase()

        deviceUpdates = model.deviceUpdates.sink(receiveValue: applyDeviceUpdates)
    }
    
    func applyDeviceUpdates(_ updates: SimDevicesUpdates) {
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
    }
    
    func applyFilter() {
        switch base {
            case .placeholder:          break
            case let .device(_, item):  item.applyFilter(filter)
            case let .runtime(_, item): item.applyFilter(filter)
        }
    }
    
    func rebuildBase() {
        var baseID  : UUID
        
        // Preserve identifier if style is not changing
        switch (style, base) {
            case (.placeholder, let .placeholder(id)):  baseID = id;
            case (.byDevice, let .device(id, _)):       baseID = id;
            case (.byRuntime, let .runtime(id, _)):     baseID = id;
            default:                                    baseID = UUID()
        }
        
        switch style {
            case .placeholder:  base = .placeholder(id: baseID)
            case .byDevice:     base = .device(id: baseID, SourceItemVal(data: .none, children: deviceStyleItems()))
            case .byRuntime:    base = .runtime(id: baseID, SourceItemVal(data: .none, children: runtimeStyleItems()))
        }
        
        applyFilter()
    }
    
    func baseFor(style: Style) -> Base {
        switch style {
            case .placeholder:  return .placeholder()
            case .byDevice:     return .device(SourceItemVal(data: .none, children: deviceStyleItems()))
            case .byRuntime:    return .runtime(SourceItemVal(data: .none, children: runtimeStyleItems()))
        }
    }
    
    func deviceStyleItems() -> [ProductFamily] {
        SimProductFamily.presentation.map { family in
            ProductFamily(data: family, children: model.deviceTypes.supporting(productFamily: family).map { devType in
                DeviceType_DS(data: devType, children: model.runtimes.supporting(deviceType: devType).map { runtime in
                    Runtime_DS(data: runtime, children: runtime.devices.of(deviceType: devType).map { device in
                        let imageDesc = devType.imageDesc.withColor(device.isAvailable ? .green : .red)

                        return Device(data: device, children: device.apps.map { app in App(data: app, children: []) }, customImgDesc: imageDesc)
                    })
                })
            })
        }
    }
    
    func runtimeStyleItems() -> [Platform] {
        SimPlatform.presentation.map { platform in
            Platform(data: platform, children: model.runtimes.supporting(platform: platform).map { runtime in
                Runtime_RT(data: runtime, children: model.deviceTypes.supporting(runtime: runtime).map { devType in
                    DeviceType_RT(data: devType, children: runtime.devices.of(deviceType: devType).map { device in
                        let imageDesc = devType.imageDesc.withColor(device.isAvailable ? .green : .red)
                        
                        return Device(data: device, children: device.apps.map { app in App(data: app, children: []) }, customImgDesc: imageDesc)
                    })
                })
            })
        }
    }
}

