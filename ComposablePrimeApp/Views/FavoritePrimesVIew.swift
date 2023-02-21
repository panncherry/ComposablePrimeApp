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

public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(self.store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.deleteFavoritePrimes(indexSet))
            }
        }
        .navigationBarTitle("Favorite primes")
        .navigationBarItems(
            trailing: HStack {
                Button("Save") {
                    self.store.send(.saveFavoritePrimesButtonTapped)
                }
                Button("Load") {
                    self.store.send(.loadFavoritePrimesButtonTapped)
                }
            }
        )
    }
}

struct FavoritePrimesView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
        //        FavoritePrimesView(store: Store(value: [],
        //                                        reducer: with(appReducer, compose(logging, activityFeed))))
    }
}
