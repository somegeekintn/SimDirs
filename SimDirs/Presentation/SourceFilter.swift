//
//  SourceFilter.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import Foundation

struct SourceFilter {
    struct Options: OptionSet, CaseIterable {
        let rawValue:   Int
        
        static let withApps         = Options(rawValue: 1 << 0)
        static let runtimeInstalled = Options(rawValue: 1 << 1)

        static var allCases         : [Options] = [.withApps, .runtimeInstalled]

        func search<T: SourceItem>(item: T, progress: Options) -> Self {
            var foundOptions    = progress.union(item.data.optionTrait)

            if !subtracting(foundOptions).isEmpty {
                for child in item.children {
                    foundOptions = search(item: child, progress: foundOptions)

                    if isSubset(of: foundOptions) {
                        break
                    }
                }
            }

            return foundOptions
        }
    }

    var searchTerm      = ""
    var options         = Options()
}
