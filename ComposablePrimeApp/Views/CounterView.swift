//
//  CounterView.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/28/23.
//

import SwiftUI
import Counter
import StoreArchitecture

typealias CountPrimeState = (count: Int, favoritePrimes: [Int])

struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    @State var isPrimeModalShown: Bool = false
    
    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }
    
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
                .disabled(store.value.isNthPrimeButtonDisabled)
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
                store: self.store
                    .view(
                        value: { ($0.count, $0.favoritePrimes) },
                        action: { .primeModal($0) }
                    )
            )
        }
        .alert(
            item: .constant(self.store.value.alertNthPrime)
        ) { alert in
            Alert(
                title: Text("The \(ordinal(store.value.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok")) {
                    self.store.send(.counter(.alertDismissButtonTapped))
                }
            )
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
        self.store.send(.counter(.nthPrimeButtonTapped))
    }
    
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(store: Store(value: CounterViewState(alertNthPrime: nil, count: 0, favoritePrimes: [], isNthPrimeButtonDisabled: false), reducer: counterViewReducer))
    }
}
