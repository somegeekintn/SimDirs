//
//  SourceFilter.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import Foundation

struct SourceFilter: Equatable {
    struct Options: OptionSet, CaseIterable {
        let rawValue:   Int
        
        static let withApps         = Options(rawValue: 1 << 0)
        static let runtimeInstalled = Options(rawValue: 1 << 1)

        static var allCases         : [Options] = [.withApps, .runtimeInstalled]
    }

    var searchTerm      = ""
    var options         = Options() { didSet { UserDefaults.standard.set(options.rawValue, forKey: "FilterOptions") } }

    var filterApps      : Bool {
        get { options.contains(.withApps) }
        set { options.booleanSet(newValue, options: .withApps) }
    }

    var filterRuntimes  : Bool {
        get { options.contains(.runtimeInstalled) }
        set { options.booleanSet(newValue, options: .runtimeInstalled) }
    }

    static func restore() -> SourceFilter {
        var filter = SourceFilter()
        
        filter.options = SourceFilter.Options(rawValue: UserDefaults.standard.integer(forKey: "FilterOptions"))
        
        return filter
    }
}
