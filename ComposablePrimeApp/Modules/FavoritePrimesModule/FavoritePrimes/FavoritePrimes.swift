//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pann Cherry on 1/29/23.
//
import Combine
import SwiftUI

/// Favorite prime reducer
/// - Parameters:
///   - state: Mutable array of integer (favorite primes)
///   - action: Delete favorite prime
public func favoritePrimeReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}
