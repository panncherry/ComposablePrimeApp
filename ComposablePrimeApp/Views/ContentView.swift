//
//  ContentView.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//
import SwiftUI
import Overture
import StoreArchitecture

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: store.view { ($0.count, $0.favoritePrimes) })) {
                    Text("Counter Demo")
                }
                NavigationLink(destination: FavoritePrimesView(store: store.view { $0.favoritePrimes })) {
                    Text("Favorite Primes")
                }
            }
            .navigationBarTitle("State Management")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(value: AppState(),
                                 reducer: with(appReducer, compose(logging, activityFeed))))
    }
}
