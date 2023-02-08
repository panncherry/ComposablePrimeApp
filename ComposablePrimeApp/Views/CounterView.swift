//
//  CounterView.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/28/23.
//

import SwiftUI
import Overture
import StoreArchitecture

struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}

typealias CountPrimeState = (count: Int, favoritePrimes: [Int])

struct CounterView: View {
    @ObservedObject var store: Store<CountPrimeState, AppAction>
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Button { store.send(.counter(.decrementTapped)) } label: {
                        Text("-")
                    }
                    Text("\(store.value.count)")
                    Button { store.send(.counter(.incrementTapped)) } label: {
                        Text("+")
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .font(.system(size: 28, weight: .bold))
                
                Button { isPrimeModalShown = true } label: {
                    Text("Is this prime?")
                }
                .font(.system(size: 20, weight: .regular))
                
                Button { nthPrimeButtonAction() } label: {
                    Text("What is the \(ordinal(store.value.count)) prime?")
                }
                .disabled(isNthPrimeButtonDisabled)
                .font(.system(size: 20, weight: .regular))
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.title)
        .foregroundColor(.black)
        .navigationBarTitle("Counter Demo")
        .sheet(isPresented: $isPrimeModalShown) {
            IsPrimeModalView(
                store: store
                    .view{($0.count, $0.favoritePrimes)}
            )
        }
        .alert(item: $alertNthPrime) { alert in
            Alert(title: Text("The \(ordinal(store.value.count)) prime is \(alert.prime)"), dismissButton: .default(Text("Ok")))
        }
    }
    
    /// Format number
    /// - Parameter n: The number to be formatted
    /// - Returns: Formatted number e.g. nth
    private func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(for: n) ?? ""
    }
    
    private func nthPrimeButtonAction() {
        isNthPrimeButtonDisabled = true
        nthPrime(store.value.count) { prime in
            alertNthPrime = prime.map(PrimeAlert.init(prime:))
            isNthPrimeButtonDisabled = false
        }
    }
    
    /// Request nth prime from Wolfram Alpha
    /// - Parameters:
    ///   - n: nth prime
    ///   - callback:
    /// - Returns: Next nth prime number
    func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
        wolframAlpha(query: "prime \(n)") { result in
            callback(
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
            )
        }
    }
    
    /// Function that takes a query string, sends it to the Wolfram Alpha API, tries to decode the json data into our struct, and invokes a callback with the results:
    /// - Parameters:
    ///   - query: A string value to query
    ///   - callback: A callback with the results
    /// - Returns: WolframAlphaResult
    func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
        var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
        components.queryItems = [
            URLQueryItem(name: "input", value: query),
            URLQueryItem(name: "format", value: "plaintext"),
            URLQueryItem(name: "output", value: "JSON"),
            URLQueryItem(name: "appid", value: "QELT5J-YL7A7EVEPY"),
        ]
        
        // apikey = QELT5J-YL7A7EVEPY
        // appid = ComposablePrimeAppPrime
        URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
            callback(
                data
                    .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
            )
        }
        .resume()
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
//        CounterView(store: Store(value: CountPrimeState(count: 0, favoritePrimes: []),
//                                 reducer: with(appReducer, compose(logging, activityFeed))))}
}
