//
//  appReducer.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//

import SwiftUI
import Counter
import PrimeModal
import FavoritePrimes
import StoreArchitecture

//let _appReducer: Reducer<AppState, AppAction> = combine(pullback(counterReducer, value: \.count, action: \.counter),
//                                                        pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
//                                                        pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes))
//
//
//let appReducer = pullback(_appReducer, value: \.self, action: \.self)

let appReducer = combine(
  pullback(counterViewReducer, value: \AppState.counterView, action: \AppAction.counterView),
  pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)
