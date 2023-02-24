//
//  CounterTests.swift
//  CounterTests
//
//  Created by Pann Cherry on 1/29/23.
//

import XCTest
import TestSupport
@testable import Counter

final class CounterTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        Current = .mock
    }
    
    func testIncrementDecrementButtonTapped() {
        assert(
            initialValue: CounterViewState(count: 2),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.incrementTapped)) { $0.count = 3 },
            Step(.send, .counter(.incrementTapped)) { $0.count = 4 },
            Step(.send, .counter(.decrementTapped)) { $0.count = 3 }
        )
    }
    
    func testNthPrimeButtonHappyFlow() {
        Current.nthPrime = { _ in .sync { 17 } }
        
        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.nthPrimeButtonTapped)) {
                $0.isNthPrimeButtonDisabled = true
            },
            Step(.receive, .counter(.nthPrimeResponse(17))) {
                $0.alertNthPrime = PrimeAlert(prime: 17)
                $0.isNthPrimeButtonDisabled = false
            },
            Step(.send, .counter(.alertDismissButtonTapped)) {
                $0.alertNthPrime = nil
            }
        )
    }
    
    func testNthPrimeButtonUnhappyFlow() {
        Current.nthPrime = { _ in .sync { nil } }
        
        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.nthPrimeButtonTapped)) {
                $0.isNthPrimeButtonDisabled = true
            },
            Step(.send, .counter(.nthPrimeResponse(nil))) {
                $0.isNthPrimeButtonDisabled = false
            }
        )
    }
    
    func testPrimeModal() {
        assert(
            initialValue: CounterViewState(
                count: 2,
                favoritePrimes: [3, 5]
            ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .primeModal(.saveFavoritePrimeTapped)) {
                $0.favoritePrimes = [3, 5, 2]
            },
            Step(.send, .primeModal(.removeFavoritePrimeTapped)) {
                $0.favoritePrimes = [3, 5]
            }
        )
    }
}
