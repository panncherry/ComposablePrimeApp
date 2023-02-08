//
//  StoreArchitecture.swift
//  StoreArchitecture
//
//  Created by Pann Cherry on 1/29/23.
//

import Combine
import SwiftUI

/// Wrapper that conforms ObservableObject protocol
public final class Store<Value, Action>: ObservableObject {
    @Published public private(set) var value: Value
    private let reducer: (inout Value, Action) -> Void
    private var cancellable: Cancellable?
    
    public init(value: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.value = value
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        reducer(&value, action)
    }
    
    public func view<LocalValue>(
        _ f: @escaping (Value) -> LocalValue
    ) -> Store<LocalValue, Action> {
        let localStore = Store<LocalValue, Action>(value: f(self.value),
                                                   reducer: { localValue, action in
            self.send(action)
            localValue = f(self.value)
        })
        
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = f(newValue)
        }
        
        return localStore
    }

}

/// Combine array of reducers
public func combine<Value, Action>(_ reducers: (inout Value, Action) -> Void...) -> (inout Value, Action) -> Void {
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

/// Pulling back reducers along values and actions
/// Pullback reducers that know how to work with local actions to reducers that know how to work on global actions
public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    
    return { globalValue, globalAction in
        // When a global action comes in we will try to extract a local action from it using the key path.
        guard let localAction = globalAction[keyPath: action] else { return }
        // Pass it on through to our reducer, if succeed
        reducer(&globalValue[keyPath: value], localAction)
    }
}


public func logging<Value, Action>(_ reducer: @escaping (inout Value, Action) -> Void) -> (inout Value, Action) -> Void {
    return { value, action in
        reducer(&value, action)
        print("Action: \(action)")
        print("Value:")
        dump(value)
        print("---")
    }
}
