//
//  AppState.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//
import Combine
import SwiftUI
import Counter

struct AppState {
    var count: Int = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
    var alertNthPrime: PrimeAlert? = nil
    var isNthPrimeButtonDisabled: Bool = false

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
    var counterView: CounterViewState {
        get {
            CounterViewState(
                alertNthPrime: self.alertNthPrime,
                count: self.count,
                favoritePrimes: self.favoritePrimes,
                isNthPrimeButtonDisabled: self.isNthPrimeButtonDisabled
            )
        }
        set {
            alertNthPrime = newValue.alertNthPrime
            count = newValue.count
            favoritePrimes = newValue.favoritePrimes
            isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
        }
    }
}
