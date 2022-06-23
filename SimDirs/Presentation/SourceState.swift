//
//  SourceState.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import Foundation

class SourceState: ObservableObject {
    typealias ProductFamily = SourceItemVal<SimProductFamily, DeviceType_DS>
    typealias Platform      = SourceItemVal<SimPlatform, Runtime_RT>
    typealias DeviceType_DS = SourceItemVal<SimDeviceType, Runtime_DS>
    typealias DeviceType_RT = SourceItemVal<SimDeviceType, Device>
    typealias Runtime_DS    = SourceItemVal<SimRuntime, Device>
    typealias Runtime_RT    = SourceItemVal<SimRuntime, DeviceType_RT>
    typealias Device        = SourceItemVal<SimDevice, App>
    typealias App           = SourceItemVal<SimApp, Never>

    enum Root: Identifiable {
        case placeholder(id: UUID = UUID())
        case device(id: UUID = UUID(), SourceRoot<ProductFamily>)
        case runtime(id: UUID = UUID(), SourceRoot<Platform>)
        
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
    
    @Published var style        = Style.placeholder { didSet { baseRoot = rootFor(style: style) } }
    @Published var filter       = SourceFilter()
    @Published var selection    : UUID?

    var model           : SimModel
    var baseRoot        = Root.placeholder()

    var filteredRoot    : Root {
        switch baseRoot {
            case .placeholder:          return baseRoot
            case let .device(_, root):  return .device(id: baseRoot.id, filter.filtered(root: root))
            case let .runtime(_, root): return .runtime(id: baseRoot.id, filter.filtered(root: root))
        }
    }

    var filterApps      : Bool {
        get { filter.options.contains(.withApps) }
        set { filter.options.booleanSet(newValue, options: .withApps) }
    }

    var filterRuntimes  : Bool {
        get { filter.options.contains(.runtimeInstalled) }
        set { filter.options.booleanSet(newValue, options: .runtimeInstalled) }
    }


    func filtering<T: SourceItem>(_ items: [T]) -> [T] {
        return items
    }
    
    init(model: SimModel) {
        self.model = model
        style = Style.byDevice
    }
    
    func rootFor(style: Style) -> Root {
        switch style {
            case .placeholder:  return .placeholder()
            case .byDevice:     return .device(SourceRoot(items: deviceStyleItems()))
            case .byRuntime:    return .runtime(SourceRoot(items: runtimeStyleItems()))
        }
    }
    
    func deviceStyleItems() -> [ProductFamily] {
        SimProductFamily.presentation.map { family in
            ProductFamily(data: family, children: model.deviceTypes.supporting(productFamily: family).map { devType in
                DeviceType_DS(data: devType, children: model.runtimes.supporting(deviceType: devType).map { runtime in
                    Runtime_DS(data: runtime, children: runtime.devices.of(deviceType: devType).map { device in
                        let imageDesc = devType.imageDesc.withColor(device.isAvailable ? .green : .red)

                        return Device(data: device, children: device.apps.map { app in App(data: app) }, customImgDesc: imageDesc)
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
                        
                        return Device(data: device, children: device.apps.map { app in App(data: app) }, customImgDesc: imageDesc)
                    })
                })
            })
        }
    }
    
#if OLDWAY
    static func testItemsOf<T>(type: T.Type) -> [T] {
        return PresentationState(model: SimModel()).allUnderlyingOf(type: type)
    }

    func allItemsOf<T>(type: T.Type) -> [PresentationItem] {
        return presentationItems().flatItems.itemsOf(type: type)
    }
    
    func allUnderlyingOf<T>(type: T.Type) -> [T] {
        return presentationItems().flatItems.underlyingOf(type: type)
    }
#endif
}

