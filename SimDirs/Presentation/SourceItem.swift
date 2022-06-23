//
//  SourceItem.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/14/22.
//

import SwiftUI

protocol SourceItem: Identifiable {
    associatedtype Model    : SourceItemData
    associatedtype Child    : SourceItem

    var id              : UUID { get }
    var data            : Model { get }
    var children        : [Child]? { get set }
    var customImgDesc   : SourceImageDesc? { get }
}

extension SourceItem {
    var title           : String { data.title }
    var headerTitle     : String { data.headerTitle }
    var header          : some View { data.header }
    var content         : some View { data.content }
    var imageDesc       : SourceImageDesc { customImgDesc ?? data.imageDesc }
    var customImgDesc   : SourceImageDesc? { nil }
}

struct SourceItemVal<Model: SourceItemData, Child: SourceItem>: SourceItem {
    var id              = UUID()
    var data            : Model
    var children        : [Child]?
    var customImgDesc   : SourceImageDesc?
}

struct SourceRoot<Item: SourceItem> {
    var items       : [Item]
}

extension Never: SourceItem {
    public var id       : UUID   { fatalError() }
    public var data     : Never    { fatalError() }
    public var children : [Never]? { get { fatalError() } set { } }
}
