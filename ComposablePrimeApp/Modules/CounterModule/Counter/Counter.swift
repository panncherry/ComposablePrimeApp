//
//  Counter.swift
//  Counter
//
//  Created by Pann Cherry on 1/29/23.
//

import Combine
import SwiftUI
import PrimeModal
import StoreArchitecture

public struct PrimeAlert: Identifiable {
    public let prime: Int
    public var id: Int { self.prime }
}

public typealias CounterState = (
    alertNthPrime: PrimeAlert?,
    count: Int,
    isNthPrimeButtonDisabled: Bool
)

public struct CounterViewState {
    public var alertNthPrime: PrimeAlert?
    public var count: Int
    public var favoritePrimes: [Int]
    public var isNthPrimeButtonDisabled: Bool
    
    public init(
        alertNthPrime: PrimeAlert?,
        count: Int,
        favoritePrimes: [Int],
        isNthPrimeButtonDisabled: Bool
    ) {
        self.alertNthPrime = alertNthPrime
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
    }
    
    var counter: CounterState {
        get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) }
        set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) = newValue }
    }
    
    var primeModal: PrimeModalState {
        get { (self.count, self.favoritePrimes) }
        set { (self.count, self.favoritePrimes) = newValue }
    }
}

public enum CounterAction {
    case decrementTapped
    case incrementTapped
    case nthPrimeButtonTapped
    case nthPrimeResponse(Int?)
    case alertDismissButtonTapped
}

public let counterViewReducer = combine(
    pullback(counterReducer, value: \CounterViewState.counter, action: \CounterViewAction.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal)
)


/// Counter Reducer
/// - Parameters:
///   - state: Mutable count
///   - action: Increment or decrement count
public func counterReducer(state: inout CounterState, action: CounterAction) -> [Effect<CounterAction>] {
    switch action {
    case .decrementTapped:
        state.count -= 1
        return []
        
    case .incrementTapped:
        state.count += 1
        return []
        
    case .nthPrimeButtonTapped:
        state.isNthPrimeButtonDisabled = true
        return [
            nthPrime(state.count)
                .map(CounterAction.nthPrimeResponse)
                .receive(on: .main)
        ]
        
    case let .nthPrimeResponse(prime):
        state.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        state.isNthPrimeButtonDisabled = false
        return []
        
    case .alertDismissButtonTapped:
        state.alertNthPrime = nil
        return []
    }
}


public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
}


/// Request nth prime from Wolfram Alpha
/// - Parameters:
///   - n: nth prime
///   - callback:
/// - Returns: Next nth prime number
public func nthPrime(_ n: Int) -> Effect<Int?> {
    return wolframAlpha(query: "prime \(n)").map { result in
        result
            .flatMap {
                $0.queryresult
                    .pods
                    .first(where: { $0.primary == .some(true) })?
                    .subpods
                    .first?
                    .plaintext
            }
            .flatMap(Int.init)
    }
}

/// Function that takes a query string, sends it to the Wolfram Alpha API, tries to decode the json data into our struct, and invokes a callback with the results:
/// - Parameters:
///   - query: A string value to query
///   - callback: A callback with the results
/// - Returns: WolframAlphaResult
public func wolframAlpha(query: String) -> Effect<WolframAlphaResult?> {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: "QELT5J-YL7A7EVEPY"),
    ]
    
    return dataTask(with: components.url(relativeTo: nil)!)
        .decode(as: WolframAlphaResult.self)
}

public func dataTask(with url: URL) -> Effect<(Data?, URLResponse?, Error?)> {
  return Effect { callback in
    URLSession.shared.dataTask(with: url) { data, response, error in
      callback((data, response, error))
    }
    .resume()
  }
}

public struct WolframAlphaResult: Decodable {
    let queryresult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]
            
            struct SubPod: Decodable {
                let plaintext: String
            }
        }
    }
}


extension Effect where A == (Data?, URLResponse?, Error?) {
    func decode<M: Decodable>(as type: M.Type) -> Effect<M?> {
        self.map { data, _ , _ in
            data
                .flatMap {
                    try? JSONDecoder().decode(M.self, from: $0)
                }
        }
    }
}


extension Effect {
    func receive(on queue: DispatchQueue) -> Effect {
        return Effect { callback in
            self.run { a in
                queue.async {
                    callback(a)
                }
            }
        }
    }
}
