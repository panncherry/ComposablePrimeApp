//
//  AppState.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//
import Combine
import SwiftUI
import PrimeModal

struct AppState {
    var count: Int = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []

    struct Activity {
      let timestamp: Date
      let type: ActivityType

      enum ActivityType {
        case addedFavoritePrime(Int)
        case removedFavoritePrime(Int)
      }
    }

    struct User {
      let id: Int
      let name: String
      let bio: String
    }
}

extension AppState {
    var primeModal: PrimeModalState {
        get {
            PrimeModalState(
                count: count,
                favoritePrimes: favoritePrimes
            )
        }
        set {
            count = newValue.count
            favoritePrimes = newValue.favoritePrimes
        }
    }
}
