//
//  NodeAB.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/18/23.
//

import SwiftUI

enum NodeAB<A: Node, B: Node>: Node, CustomStringConvertible {
    case a(A)
    case b(B)

    var title       : String {
        switch self {
            case .a(let node): return node.title
            case .b(let node): return node.title
        }
    }
    
    var headerTitle : String {
        switch self {
            case .a(let node): return node.headerTitle
            case .b(let node): return node.headerTitle
        }
    }
    
    @ViewBuilder
    var header      : some View {
        switch self {
            case .a(let node): node.header
            case .b(let node): node.header
        }
    }

    @ViewBuilder
    var content     : some View {
        switch self {
            case .a(let node): node.content
            case .b(let node): node.content
        }
    }

    var items       : [NodeAB<A.Child, B.Child>]? {
        get {
            switch self {
                case .a(let node): return node.items?.map { .a($0) }
                case .b(let node): return node.items?.map { .b($0) }
            }
        }
        set {
            switch self {
                case .a(var node):
                    let items : [A.Child]? = newValue?.compactMap({ ab in
                        guard case .a(let a) = ab else { return nil }
                        
                        return a
                    })
                    
                    node.items = items
                    self = .a(node)

                case .b(var node):
                    let items : [B.Child]? = newValue?.compactMap({ ab in
                        guard case .b(let b) = ab else { return nil }
                        
                        return b
                    })
                    
                    node.items = items
                    self = .b(node)
            }
        }
    }

    var description : String {
        let valueDesc   : String
        
        switch self {
            case .a(let node): valueDesc = ".a: \(String(describing: node))"
            case .b(let node): valueDesc = ".b: \(String(describing: node))"
        }
        
        return "NodeAB<A-\(A.self), B-\(B.self)>: \(valueDesc)"
    }
    
    func icon(forHeader: Bool) -> some View {
        switch self {
            case .a(let node): node.icon(forHeader: forHeader)
            case .b(let node): node.icon(forHeader: forHeader)
        }
    }
    
    func matchedFilterOptions() -> SourceFilter.Options {
        switch self {
            case .a(let node): return node.matchedFilterOptions()
            case .b(let node): return node.matchedFilterOptions()
        }
    }

    @discardableResult
    mutating func processUpdate(_ update: SimModel.Update) -> Bool {
        switch self {
            case .a(var node):
                let result = node.processUpdate(update)

                self = .a(node)

                return result
                
            case .b(var node):
                let result = node.processUpdate(update)

                self = .b(node)

                return result
        }
    }
}
