//
//  FavoritePrimesTests.swift
//  FavoritePrimesTests
//
//  Created by Pann Cherry on 1/29/23.
//

import XCTest
import StoreArchitecture
@testable import FavoritePrimes

final class FavoritePrimesTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        Current = .mock
    }

    func testDeleteFavoritePrimes() throws {
        var state = [2,3,5,7]
        let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))
        
        XCTAssertEqual(state, [2,3,7])
        XCTAssert(effects.isEmpty)
    }

    func testSaveFavoritePrimesButtonTapped() throws {
        var didSave = false
        Current.fileClient.save = { _,_ in
                .fireAndForget {
                    didSave = true
                }
        }
        
        var state = [2,3,5,7]
        let effects = favoritePrimesReducer(state: &state, action: .saveFavoritePrimesButtonTapped)
        
        XCTAssertEqual(state, [2,3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        // Test the effects
        let _ = effects[0].sink { _ in
            XCTFail()
        }
        XCTAssert(didSave)
    }
    
    func testLoadFavoritePrimesFlow() throws {
        // Test load effect
        Current.fileClient.load = { _ in
                .sync {
                    try! JSONEncoder().encode([2, 31])
                }
        }
        
        var state = [2,3,5,7]
        var effects = favoritePrimesReducer(state: &state, action: .loadFavoritePrimesButtonTapped)
        
        XCTAssertEqual(state, [2,3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        var nextAction: FavoritePrimesAction!
        let receivedCompletion = self.expectation(description: "receivedCompletion")
        
        let _ = effects[0].sink { _ in
            receivedCompletion.fulfill()
        } receiveValue: { action in
            XCTAssertEqual(action, .loadedFavoritePrimes([2, 31]))
            nextAction = action
        }

        self.wait(for: [receivedCompletion], timeout: 0)

        effects = favoritePrimesReducer(state: &state, action: nextAction)
        XCTAssertEqual(state, [2, 31])
        XCTAssert(effects.isEmpty)
    }
}
