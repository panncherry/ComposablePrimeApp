//
//  ComposablePrimeAppApp.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/29/23.
//
import SwiftUI
import Overture
import StoreArchitecture

@main
struct ComposablePrimeAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(value: AppState(),
                                     reducer: with(appReducer, compose(logging, activityFeed))))
        }
    }
}
