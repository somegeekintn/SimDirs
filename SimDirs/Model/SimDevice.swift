//
//  SimDevice.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import Foundation

struct SimDevice: Decodable {
    let name                    : String
    let udid                    : String
    let state                   : String
    let dataPath                : String
    let dataPathSize            : Int
    let logPath                 : String
    let isAvailable             : Bool
    let deviceTypeIdentifier    : String
    let availabilityError       : String?

    func isDeviceOfType(_ deviceType: SimDeviceType) -> Bool {
        return deviceTypeIdentifier == deviceType.identifier
    }
}

extension SimDevice: PresentableItem {
    var title       : String { return name }
    var id          : String { return udid }

    var imageName   : String { return "shippingbox" }    // FIXME
}

