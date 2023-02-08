//
//  IsPrimeModalView.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/28/23.
//
import SwiftUI
import Overture
import PrimeModal
import FavoritePrimes
import StoreArchitecture

struct IsPrimeModalView: View {
    @ObservedObject var store: Store<PrimeModalState, AppAction>
    
    var body: some View {
        VStack {
            if isPrime(store.value.count) {
                Text("\(store.value.count) is prime 🎉")
                
                if store.value.favoritePrimes.contains(store.value.count) {
                    Button { store.send(.primeModal(.removeFavoritePrimeTapped))} label: {
                        Text("Remove from favorite primes")
                    }
                } else {
                    Button { store.send(.primeModal(.saveFavoritePrimeTapped)) } label: {
                        Text("Save to favorite primes")
                    }
                }
                
            } else {
                Text("\(store.value.count) is not prime 😞")
            }
        }
    }
    
    /// Checks prime
    /// - Parameter p: The number to be checked
    /// - Returns: Boolean value
    private func isPrime(_ p: Int) -> Bool {
        if p <= 1 { return false }
        if p <= 3 { return true }
        for i in 2...Int(sqrtf(Float(p))) {
            if p % i == 0 { return false }
        }
        return true
    }
    
}

struct IsPrimeModalView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
//        IsPrimeModalView(store: Store(value: PrimeModalState(count: 0, favoritePrimes: []),
//                                      reducer: with(appReducer, compose(logging, activityFeed))))
    }
}
