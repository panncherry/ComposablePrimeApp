//
//  ActivityFeedReducer.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//

import Combine
import SwiftUI

/// ActivityFeed higher order reducer
/// - Parameter reducer: `appReducer`
/// - Returns:
func activityFeed(_ reducer: @escaping (inout AppState, AppAction) -> Void) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counter(_):
            break
            
        case .primeModal(.saveFavoritePrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))

        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.favoritePrimes[index])))
            }
        }
        
        reducer(&state, action)
    }
}
