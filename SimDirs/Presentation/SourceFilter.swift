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

            if let items = item.children, !subtracting(foundOptions).isEmpty {
                for child in items {
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

    func filtered<T>(root: SourceRoot<T>) -> SourceRoot<T> {
        if !searchTerm.isEmpty || !options.isEmpty {
            var fRoot = root

            fRoot.items = root.items.compactMap { item in
                let result = filtered(item: item)

                return result.match ? result.fItem : nil
            }

            return fRoot
        }
        else {
            return root
        }
    }

    func filtered<T: SourceItem>(item: T, inheritedOptions: Options = []) -> (fItem: T, match: Bool) {
        var fItem           = item
        var match           = true
        var childMatch      = false
        let optProgress     = inheritedOptions.union(fItem.data.optionTrait)  // options inherited by children

        // If there are options to match then do that first passing inherited options along
        // and consider a match fulfilled if any child contains all the desired options.

        if !options.isEmpty {
            var foundOptions = optProgress

            if !options.isSubset(of: foundOptions) {
                foundOptions = options.search(item: fItem, progress: foundOptions)
            }
            match = options.isSubset(of: foundOptions)
        }

        if !searchTerm.isEmpty && match {
            match = fItem.title.uppercased().contains(searchTerm.uppercased())
        }

        if let srcChildren = fItem.children {
            fItem.children = srcChildren.compactMap { child -> T.Child? in
                let result = filtered(item: child, inheritedOptions: optProgress)

                return result.match ? result.fItem : nil
            }
            childMatch = fItem.children?.isEmpty == false
        }

        return (fItem, match || childMatch)
    }
}
