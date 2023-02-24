//
//  IsPrimeModalView.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/28/23.
//
import SwiftUI
import Counter
import PrimeModal
import FavoritePrimes
import StoreArchitecture

struct IsPrimeModalView: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            if isPrime(store.value.count) {
                Text("\(store.value.count) is prime 🎉")
                
                if store.value.favoritePrimes.contains(store.value.count) {
                    Button { self.store.send(.removeFavoritePrimeTapped) } label: {
                        Text("Remove from favorite primes")
                    }
                } else {
                    Button { store.send(.saveFavoritePrimeTapped) } label: {
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
        IsPrimeModalView(
            store: Store<PrimeModalState, PrimeModalAction>(
                value: (2, [2, 3, 5]),
                reducer: primeModalReducer))
    }
}
