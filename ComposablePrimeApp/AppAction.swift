//
//  AppAction.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//

import SwiftUI
import Counter
import PrimeModal
import FavoritePrimes

struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}

struct _KeyPath<Root, Value> {
    let get: (Root) -> Value
    let set: (inout Root, Value) -> Void
}

enum AppAction {
  case counterView(CounterViewAction)
  case favoritePrimes(FavoritePrimesAction)

  var counterView: CounterViewAction? {
    get {
      guard case let .counterView(value) = self else { return nil }
      return value
    }
    set {
      guard case .counterView = self, let newValue = newValue else { return }
      self = .counterView(newValue)
    }
  }

  var favoritePrimes: FavoritePrimesAction? {
    get {
      guard case let .favoritePrimes(value) = self else { return nil }
      return value
    }
    set {
      guard case .favoritePrimes = self, let newValue = newValue else { return }
      self = .favoritePrimes(newValue)
    }
  }
}
