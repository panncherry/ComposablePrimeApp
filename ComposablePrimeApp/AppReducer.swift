//
//  appReducer.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//

import SwiftUI
import Counter
import FavoritePrimes
import StoreArchitecture

let appReducer = combine(
  pullback(counterViewReducer, value: \AppState.counterView, action: \AppAction.counterView),
  pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)
