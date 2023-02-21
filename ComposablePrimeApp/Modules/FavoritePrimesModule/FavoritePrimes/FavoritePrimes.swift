//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pann Cherry on 1/29/23.
//

import SwiftUI
import Overture
import StoreArchitecture

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveFavoritePrimesButtonTapped
    case loadFavoritePrimesButtonTapped
}

/// Favorite prime reducer
/// - Parameters:
///   - state: Mutable array of integer (favorite primes)
///   - action: Delete favorite prime
public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []

    case let .loadedFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return []

    case .saveFavoritePrimesButtonTapped:
        return [saveEffect(favoritePrimes: state)]
        
    case .loadFavoritePrimesButtonTapped:
        return [loadEffect]
    }
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
    return Effect { _ in
        let data = try! JSONEncoder().encode(favoritePrimes)
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsUrl = URL(fileURLWithPath: documentPath)
        let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
        try! data.write(to: favoritePrimesUrl)
    }
}

private let loadEffect = Effect<FavoritePrimesAction> { callback in
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsUrl = URL(fileURLWithPath: documentPath)
    let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
    
    guard let data = try? Data(contentsOf: favoritePrimesUrl),
          let favoritePrimes = try?  JSONDecoder().decode([Int].self, from: data) else {
        return
    }
        
    callback(.loadedFavoritePrimes(favoritePrimes))
}
