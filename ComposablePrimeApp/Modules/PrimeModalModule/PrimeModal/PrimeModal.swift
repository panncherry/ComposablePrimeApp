//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Pann Cherry on 1/29/23.
//

import SwiftUI
import Combine
import StoreArchitecture

/// Prime modal reducer
/// - Parameters:
///   - state: Mutable `AppState`
///   - action: Save or remove favorite prime
public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> [Effect<PrimeModalAction>] {
    switch action {
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)
        return []
        
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
        return []
    }
}

public enum PrimeModalAction: Equatable {
  case saveFavoritePrimeTapped
  case removeFavoritePrimeTapped
}

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])
