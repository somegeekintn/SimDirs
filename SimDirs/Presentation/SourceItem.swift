//
//  SourceItem.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/14/22.
//

import SwiftUI

protocol SourceItem: Identifiable, ObservableObject {
    associatedtype Model    : SourceItemData
    associatedtype Child    : SourceItem

    var id              : UUID { get }
    var data            : Model { get }
    var children        : [Child] { get set }
    var visibleChildren : [Child] { get set }
    var customImgDesc   : SourceImageDesc? { get }
}

extension SourceItem {
    var title           : String { data.title }
    var headerTitle     : String { data.headerTitle }
    var header          : some View { data.header }
    var content         : some View { data.content }
    var imageDesc       : SourceImageDesc { customImgDesc ?? data.imageDesc }
    var customImgDesc   : SourceImageDesc? { nil }

    func applyFilter(_ filter: SourceFilter) {
        visibleChildren = children.filter { $0.applyingFilter(filter) }
    }

    func applyingFilter(_ filter: SourceFilter, inheritedOptions: SourceFilter.Options = []) -> Bool {
        var match           = true
        let optProgress     = inheritedOptions.union(data.optionTrait)  // options inherited by children

        // If there are options to match then do that first passing inherited options along
        // and consider a match fulfilled if any child contains all the desired options.

        if !filter.options.isEmpty {
            var foundOptions = optProgress

            if !filter.options.isSubset(of: foundOptions) {
                foundOptions = filter.options.search(item: self, progress: foundOptions)
            }
            match = filter.options.isSubset(of: foundOptions)
        }

        if !filter.searchTerm.isEmpty && match {
            match = title.uppercased().contains(filter.searchTerm.uppercased())
        }

        visibleChildren = children.filter { $0.applyingFilter(filter, inheritedOptions: optProgress) }

        return match || !visibleChildren.isEmpty
    }
}

class SourceItemVal<Model: SourceItemData, Child: SourceItem>: SourceItem {
    @Published var visibleChildren  : [Child]
    
    var id              = UUID()
    var data            : Model
    var children        : [Child]
    var customImgDesc   : SourceImageDesc?
    
    init(id: UUID = UUID(), data: Model, children: [Child] = [], customImgDesc: SourceImageDesc? = nil) {
        self.id = id
        self.data = data
        self.children = children
        self.visibleChildren = children
        self.customImgDesc = customImgDesc
    }
}

class SourceItemNone: SourceItem {
    var id              = UUID()
    var data            = SourceItemDataNone()
    var children        = [SourceItemNone]()
    var visibleChildren = [SourceItemNone]()
}
