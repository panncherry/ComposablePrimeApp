//
//  ContentView.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//
import SwiftUI
import Overture
import Counter
import StoreArchitecture


struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>

  var body: some View {
    NavigationView {
      List {
        NavigationLink(
          "Counter demo",
          destination: CounterView(
            store: self.store.view(
              value: { $0.counterView },
              action: { .counterView($0) }
            )
          )
        )
        NavigationLink(
          "Favorite primes",
          destination: FavoritePrimesView (
            store: self.store.view(
              value: { $0.favoritePrimes },
              action: { .favoritePrimes($0) }
            )
          )
        )
      }
      .navigationBarTitle("State management")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(value: AppState(),
                                 reducer: with(appReducer, compose(logging, activityFeed))))
    }
}
