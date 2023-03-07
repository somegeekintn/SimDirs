//
//  SimDeviceType.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import Foundation

struct SimDeviceType: Decodable {
//    enum CodingKeys: String, CodingKey {
//        case bundlePath
//        case identifier
//        case maxRuntimeVersion
//        case maxRuntimeVersionString
//        case minRuntimeVersion
//        case minRuntimeVersionString
//        case modelIdentifier
//        case name
//        case productFamily
//    }
//
    let name                    : String
    let identifier              : String
    let productFamily           : SimProductFamily
    let modelIdentifier         : String
    let bundlePath              : String
    let minRuntimeVersion       : Int
    let maxRuntimeVersion       : Int
    let minRuntimeVersionString : String
    let maxRuntimeVersionString : String
    
    func supports(productFamily: SimProductFamily) -> Bool {
        return productFamily == self.productFamily
    }
    
    func supports(runtime: SimRuntime) -> Bool {
        return runtime.supportedDeviceTypes.contains { $0.identifier == identifier }
    }
}

extension Array where Element == SimDeviceType {
    func supporting(productFamily: SimProductFamily) -> Self {
        filter { $0.supports(productFamily: productFamily) }
    }
    
    func supporting(runtime: SimRuntime) -> Self {
        filter { $0.supports(runtime: runtime) }
    }
}

