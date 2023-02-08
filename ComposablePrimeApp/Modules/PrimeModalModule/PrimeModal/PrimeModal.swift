//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Pann Cherry on 1/29/23.
//

/// Prime modal reducer
/// - Parameters:
///   - state: Mutable `AppState`
///   - action: Save or remove favorite prime
public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)
        
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
    }
}

public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])
