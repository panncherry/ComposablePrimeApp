//
//  FavoritePrimesView.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//
import SwiftUI
import Overture
import FavoritePrimes
import StoreArchitecture

struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], AppAction>
    
    var body: some View {
        List {
            ForEach(store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet))) }
        }
        .navigationBarTitle("Favorite Primes")
    }
}

struct FavoritePrimesView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
//        FavoritePrimesView(store: Store(value: [],
//                                        reducer: with(appReducer, compose(logging, activityFeed))))
    }
}
