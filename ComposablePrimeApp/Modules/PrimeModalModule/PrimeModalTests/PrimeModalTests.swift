//
//  PrimeModalTests.swift
//  PrimeModalTests
//
//  Created by Pann Cherry on 1/29/23.
//

import XCTest
@testable import PrimeModal

final class PrimeModalTests: XCTestCase {

    func testSaveFavoritePrimeTapped() throws {
        var state = (count: 2, favoritePrimes: [3,5])
        let effects = primeModalReducer(state: &state, action: .saveFavoritePrimeTapped)
        
        //let (count, favoritePrimes) = state
        XCTAssertEqual(state.count, 2)
        XCTAssertEqual(state.favoritePrimes, [3,5,2])
        XCTAssert(effects.isEmpty)
    }
    
    func testRemoveFavoritePrimeTapped() throws {
        var state = (count: 3, favoritePrimes: [3,5])
        let effects = primeModalReducer(state: &state, action: .removeFavoritePrimeTapped)
        
        //let (count, favoritePrimes) = state
        XCTAssertEqual(state.count, 3)
        XCTAssertEqual(state.favoritePrimes, [5])
        XCTAssert(effects.isEmpty)
    }
    
}
