//
//  Funtional.swift
//  Lumino
//
//  Created by Sergey Anisimov on 23/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

enum Result<A> {
    case Error(Error)
    case Value(A)
}

precedencegroup FunctionalBindPrecedence {
    associativity: left
    higherThan: FunctionalPrecedence
}

precedencegroup FunctionalPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator >>> : FunctionalBindPrecedence

func >>><A, B>(a: Result<A>, f: (Result<A>) -> Result<B>) -> Result<B> {
    switch a {
    case .Value(_): return f(a)
    case let .Error(error): return .Error(error)
    }
}

infix operator <^> : FunctionalPrecedence

func <^><A, B>(f: (A) -> B, a: Result<A>) -> Result<B> {
    switch a {
    case let .Value(value): return .Value(f(value))
    case let .Error(error): return .Error(error)
    }
}

infix operator <*> : FunctionalPrecedence

func <*><A, B>(f: Result<(A) -> B>, a: Result<A>) -> Result<B> {
    switch a {
    case let .Value(value):
        switch f {
        case let .Value(fa): return .Value(fa(value))
        case let .Error(error): return .Error(error)
        }
    case let .Error(error): return .Error(error)
    }
}

func <*><A>(a: Optional<A>, b: Optional<A>) -> Optional<A> {
    switch a {
    case .some(_): return a
    case .none: return b
    }
}
