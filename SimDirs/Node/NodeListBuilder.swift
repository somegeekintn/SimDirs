//
//  NodeListBuilder.swift
//  NodeItems
//
//  Created by Casey Fleser on 3/2/23.
//

import SwiftUI

@resultBuilder struct NodeListBuilder {
    typealias P = Node

    enum OneOf<A: P, B: P>: P, CustomStringConvertible {
        typealias List = [NodeListBuilder.OneOf<A.List.Element, B.List.Element>]

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

        var items       : List? {
            get {
                switch self {
                    case .a(let node): return node.items?.map { .a($0) }
                    case .b(let node): return node.items?.map { .b($0) }
                }
            }
            set { }
        }

        var description : String {
            let valueDesc   : String
            
            switch self {
                case .a(let node): valueDesc = ".a: \(String(describing: node))"
                case .b(let node): valueDesc = ".b: \(String(describing: node))"
            }
            
            return "OneOf<A - \(A.self), B - \(B.self)>: \(valueDesc)"
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
    }

    static func buildBlock<C: P>(_ c: [C]) -> [C] {
        c
    }

    static func buildBlock<C0: P, C1: P> (
        _ c0: [C0], _ c1: [C1]) -> [OneOf<C0, C1>]
    {
        [buildEither(first: c0), buildEither(second: c1)].flatMap { $0 }
    }

    static func buildBlock<C0: P, C1: P, C2: P> (
        _ c0: [C0], _ c1: [C1], _ c2: [C2]) -> [OneOf<OneOf<C0, C1>, C2>]
    {
        [buildEither(first: buildBlock(c0, c1)), buildEither(second: c2)].flatMap { $0 }
    }

    static func buildBlock<C0: P, C1: P, C2: P, C3: P> (
        _ c0: [C0], _ c1: [C1], _ c2: [C2], _ c3: [C3]) -> [OneOf<OneOf<C0, C1>, OneOf<C2, C3>>]
    {
        [buildEither(first: buildBlock(c0, c1)), buildEither(second: buildBlock(c2, c3))].flatMap { $0 }
    }

    static func buildBlock<C0: P, C1: P, C2: P, C3: P, C4: P> (
        _ c0: [C0], _ c1: [C1], _ c2: [C2], _ c3: [C3], _ c4: [C4]) -> [OneOf<OneOf<OneOf<C0, C1>, OneOf<C2, C3>>, C4>]
    {
        [buildEither(first: buildBlock(c0, c1, c2, c3)), buildEither(second: c4)].flatMap { $0 }
    }

    static func buildBlock<C0: P, C1: P, C2: P, C3: P, C4: P, C5: P> (
        _ c0: [C0], _ c1: [C1], _ c2: [C2], _ c3: [C3], _ c4: [C4], _ c5: [C5]) -> [OneOf<OneOf<OneOf<C0, C1>, OneOf<C2, C3>>, OneOf<C4, C5>>]
    {
        [buildEither(first: buildBlock(c0, c1, c2, c3)), buildEither(second: buildBlock(c4, c5))].flatMap { $0 }
    }

    static func buildBlock<C0: P, C1: P, C2: P, C3: P, C4: P, C5: P, C6: P> (
        _ c0: [C0], _ c1: [C1], _ c2: [C2], _ c3: [C3], _ c4: [C4], _ c5: [C5], _ c6: [C6]) -> [OneOf<OneOf<OneOf<C0, C1>, OneOf<C2, C3>>, OneOf<OneOf<C4, C5>, C6>>]
    {
        [buildEither(first: buildBlock(c0, c1, c2, c3)), buildEither(second: buildBlock(c4, c5, c6))].flatMap { $0 }
    }

    static func buildBlock<C0: P, C1: P, C2: P, C3: P, C4: P, C5: P, C6: P, C7: P> (
        _ c0: [C0], _ c1: [C1], _ c2: [C2], _ c3: [C3], _ c4: [C4], _ c5: [C5], _ c6: [C6], _ c7: [C7]) -> [OneOf<OneOf<OneOf<C0, C1>, OneOf<C2, C3>>, OneOf<OneOf<C4, C5>, OneOf<C6, C7>>>]
    {
        [buildEither(first: buildBlock(c0, c1, c2, c3)), buildEither(second: buildBlock(c4, c5, c6, c7))].flatMap { $0 }
    }
    
//    static func buildBlock<C: Node>(_ c: [C]...) -> [C] {
//        c.flatMap { $0 }
//    }
//
    // Same type buildBlocks. This works but buildBlock<C: Node>(_ c: [C]...) -> [C] confuses the compiler

    static func buildBlock<C0: Node> (_ c0: [C0], _ c1: [C0]) -> [C0] {
        [c0, c1].flatMap { $0 }
    }

    static func buildBlock<C0: Node> (_ c0: [C0], _ c1: [C0], _ c2: [C0]) -> [C0] {
        [c0, c1, c2].flatMap { $0 }
    }

    static func buildEither<C0: P, C1: P>(first c0: [C0]) -> [OneOf<C0, C1>] {
        c0.map { OneOf<C0, C1>.a($0) }
    }

    static func buildEither<C0: P, C1: P>(second c1: [C1]) -> [OneOf<C0, C1>] {
        c1.map { OneOf<C0, C1>.b($0) }
    }

    static func buildOptional<C: P>(_ c: [C]?) -> [C] {
        c ?? []
    }

    static func buildArray<C: P>(_ c: [[C]]) -> [C] {
        c.flatMap { $0 }
    }

    static func buildExpression<N: Node>(_ node: N) -> [N] {
        [node]
    }

    static func buildExpression<NL: NodeList>(_ nodeList: NL)  -> [NL.Element] {
        Array(nodeList)
    }
    
    static func buildExpression<NS: NodeSource>(_ nodeSource: NS) -> [NS.List.Element] {
        nodeSource.items.map({ buildExpression($0) }) ?? []
    }
}

