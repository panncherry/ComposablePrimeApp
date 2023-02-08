//
//  Counter.swift
//  Counter
//
//  Created by Pann Cherry on 1/29/23.
//

import Combine
import SwiftUI

/// Counter Reducer
/// - Parameters:
///   - state: Mutable count
///   - action: Increment or decrement count
public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrementTapped:
        state -= 1
        
    case .incrementTapped:
        state += 1
    }
}

public enum CounterAction {
    case decrementTapped
    case incrementTapped
}
