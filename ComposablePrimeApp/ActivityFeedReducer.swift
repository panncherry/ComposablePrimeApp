//
//  ActivityFeedReducer.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//

import Combine
import SwiftUI
import StoreArchitecture

/// ActivityFeed higher order reducer
/// - Parameter reducer: `appReducer`
/// - Returns:
func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
    
    return { state, action in
        switch action {
        case .counterView(.counter),
                .favoritePrimes(.loadedFavoritePrimes),
                .favoritePrimes(.loadFavoritePrimesButtonTapped),
                .favoritePrimes(.saveFavoritePrimesButtonTapped):
            break
        case .counterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
            
        case .counterView(.primeModal(.saveFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
            
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            }
        }
        
        return reducer(&state, action)
    }
}
