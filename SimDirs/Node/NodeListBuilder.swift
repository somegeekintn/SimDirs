//
//  NodeListBuilder.swift
//  NodeItems
//
//  Created by Casey Fleser on 3/2/23.
//

import SwiftUI

@resultBuilder struct NodeListBuilder {
    typealias P = Node
    typealias OneOf = NodeAB

    static func buildPartialBlock<C: P>(first c: [C]) -> [C] {
        c
    }
    
    // matching types
    static func buildPartialBlock<C: P>(accumulated c0: [C], next c1: [C]) -> [C] {
        c0 + c1
    }

    // matches A of OneOf<A, B>
    static func buildPartialBlock<A: P, B: P>(accumulated ab: [OneOf<A, B>], next a: [A]) -> [OneOf<A, B>] {
        ab + a.map { .a($0) }
    }
    
    // matches B of OneOf<A, B>
    static func buildPartialBlock<A: P, B: P>(accumulated ab: [OneOf<A, B>], next b: [B]) -> [OneOf<A, B>] {
        ab + b.map { .b($0) }
    }
    
    // matches A of OneOf<OneOf<A, B>, C>
    static func buildPartialBlock<A: P, B: P, C: P>(accumulated abc: [OneOf<OneOf<A, B>, C>], next a: [A]) -> [OneOf<OneOf<A, B>, C>] {
        buildPartialBlock(accumulated: [] as [OneOf<A, B>], next: a).map { .a($0) }
    }
    
    // matches B of OneOf<OneOf<A, B>, C>
    static func buildPartialBlock<A: P, B: P, C: P>(accumulated abc: [OneOf<OneOf<A, B>, C>], next b: [B]) -> [OneOf<OneOf<A, B>, C>] {
        buildPartialBlock(accumulated: [] as [OneOf<A, B>], next: b).map { .a($0) }
    }
    
    // matches C of OneOf<OneOf<A, B>, C>
    static func buildPartialBlock<A: P, B: P, C: P>(accumulated abc: [OneOf<OneOf<A, B>, C>], next c: [C]) -> [OneOf<OneOf<A, B>, C>] {
        abc + c.map { .b($0) }
    }
    
    // matches A of OneOf<OneOf<A, B>, OneOf<C, D>>
    static func buildPartialBlock<A: P, B: P, C: P, D: P>(accumulated abcd: [OneOf<OneOf<A, B>, OneOf<C, D>>], next a: [A]) -> [OneOf<OneOf<A, B>, OneOf<C, D>>] {
        buildPartialBlock(accumulated: [] as [OneOf<A, B>], next: a).map { .a($0) }
    }
    
    // matches B of OneOf<OneOf<A, B>, OneOf<C, D>>
    static func buildPartialBlock<A: P, B: P, C: P, D: P>(accumulated abcd: [OneOf<OneOf<A, B>, OneOf<C, D>>], next b: [B]) -> [OneOf<OneOf<A, B>, OneOf<C, D>>] {
        buildPartialBlock(accumulated: [] as [OneOf<A, B>], next: b).map { .a($0) }
    }

    // matches C of OneOf<OneOf<A, B>, OneOf<C, D>>
    static func buildPartialBlock<A: P, B: P, C: P, D: P>(accumulated abcd: [OneOf<OneOf<A, B>, OneOf<C, D>>], next c: [C]) -> [OneOf<OneOf<A, B>, OneOf<C, D>>] {
        buildPartialBlock(accumulated: [] as [OneOf<C, D>], next: c).map { .b($0) }
    }

    // matches D of OneOf<OneOf<A, B>, OneOf<C, D>>
    static func buildPartialBlock<A: P, B: P, C: P, D: P>(accumulated abcd: [OneOf<OneOf<A, B>, OneOf<C, D>>], next d: [D]) -> [OneOf<OneOf<A, B>, OneOf<C, D>>] {
        buildPartialBlock(accumulated: [] as [OneOf<C, D>], next: d).map { .b($0) }
    }

    // non-matching types
    static func buildPartialBlock<C0: P, C1: P>(accumulated c0: [C0], next c1: [C1]) -> [OneOf<C0, C1>] {
        c0.map({ OneOf<C0, C1>.a($0) }) + c1.map({ OneOf<C0, C1>.b($0) })
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
        return [node]
    }

    static func buildExpression<NL: NodeList>(_ nodeList: NL)  -> [NL.Element] {
        return Array(nodeList)
    }
}

