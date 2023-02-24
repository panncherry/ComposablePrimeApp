//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pann Cherry on 1/29/23.
//

import SwiftUI
import Combine
import StoreArchitecture

public enum FavoritePrimesAction: Equatable {
    case deleteFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveFavoritePrimesButtonTapped
    case loadFavoritePrimesButtonTapped
}

/// Favorite prime reducer
/// - Parameters:
///   - state: Mutable array of integer (favorite primes)
///   - action: Delete favorite prime
public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []
        
    case let .loadedFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return []
        
    case .saveFavoritePrimesButtonTapped:
        //        return [saveEffect(favoritePrimes: state)]
        return [
            Current.fileClient.save("favorite-primes.json",
                                    try! JSONEncoder().encode(state))
            .fireAndForget()
        ]
        
    case .loadFavoritePrimesButtonTapped:
        //        return [loadEffect.compactMap{$0}.eraseToEffect()]
        return [
            Current.fileClient.load("favorite-primes.json")
                .compactMap{$0}
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch({ error in
                    Empty(completeImmediately: true)
                })
                .map(FavoritePrimesAction.loadedFavoritePrimes)
                .eraseToEffect()
        ]
    }
}

//private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
//    return .fireAndForget {
//        let data = try! JSONEncoder().encode(favoritePrimes)
//        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let documentsUrl = URL(fileURLWithPath: documentPath)
//        let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
//        try! data.write(to: favoritePrimesUrl)
//    }
//}
//
//private let loadEffect = Effect<FavoritePrimesAction?>.sync {
//    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//    let documentsUrl = URL(fileURLWithPath: documentPath)
//    let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
//
//    guard let data = try? Data(contentsOf: favoritePrimesUrl),
//          let favoritePrimes = try?  JSONDecoder().decode([Int].self, from: data) else {
//        return nil
//    }
//
//    return .loadedFavoritePrimes(favoritePrimes)
//}


struct FileClient {
    var load: (String) -> Effect<Data?>
    var save: (String, Data) -> Effect<Never>
}

extension FileClient {
    
    static let live = FileClient(
        load: { fileName -> Effect<Data?> in
            Effect<Data?>.sync {
                let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsUrl = URL(fileURLWithPath: documentPath)
                let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                return try? Data(contentsOf: favoritePrimesUrl)
            }
        },
        save: { fileName, data in
            return .fireAndForget {
                let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsUrl = URL(fileURLWithPath: documentPath)
                let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                try! data.write(to: favoritePrimesUrl)
            }
        })
}

struct FavoritePrimesEnvironment {
    var fileClient: FileClient
}

extension FavoritePrimesEnvironment {
    static let live = FavoritePrimesEnvironment(fileClient: .live)
}

func absurd<A>(_ never: Never) -> A {}


var Current = FavoritePrimesEnvironment.live

extension Publisher where Output == Never, Failure == Never {
    func fireAndForget<A>() -> Effect<A> {
        return self.map(absurd).eraseToEffect()
    }
}


// Mock favorite primes environment
#if DEBUG
extension FavoritePrimesEnvironment {
    static let mock = FavoritePrimesEnvironment(
        fileClient: FileClient(
            load: { _ in
                Effect<Data?>.sync {
                    try! JSONEncoder().encode([2,31])
                }
            },
            save: { _, _ in
                    .fireAndForget {}
            })
    )
}
#endif
