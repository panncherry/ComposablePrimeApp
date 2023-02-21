//
//  StoreArchitecture.swift
//  StoreArchitecture
//
//  Created by Pann Cherry on 1/29/23.


import Combine
import SwiftUI

//public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void
public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void
    
    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }
    
    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in self.run { a in callback(f(a)) } }
    }
}

/// Wrapper that conforms ObservableObject protocol
public final class Store<Value, Action>: ObservableObject {
    
    @Published public private(set) var value: Value
    
    private let reducer: Reducer<Value, Action>
    
    private var cancellable: Cancellable?
    
    public init(value: Value, reducer: @escaping Reducer<Value, Action>) {
        self.value = value
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        let effects = reducer(&value, action)
        effects.forEach { effect in
            effect.run(self.send)
        }
    }
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        
        let localStore = Store<LocalValue, LocalAction>(
            value: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            })
        
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        
        return localStore
    }
    
}

/// Combine array of reducers
public func combine<Value, Action>(_ reducers: Reducer<Value, Action>...) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducers.flatMap { $0(&value, action) }
        return effects
    }
}

/// Pulling back reducers along values and actions
/// Pullback reducers that know how to work with local actions to reducers that know how to work on global actions
//public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
//    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
//    value: WritableKeyPath<GlobalValue, LocalValue>,
//    action: WritableKeyPath<GlobalAction, LocalAction?>
//) -> Reducer<GlobalValue, GlobalAction> {
//
//    return { globalValue, globalAction in
//        // When a global action comes in we will try to extract a local action from it using the key path.
//        guard let localAction = globalAction[keyPath: action] else {
//            return []
//        }
//
//        // Pass it on through to our reducer, if succeed
//        let localEffects = reducer(&globalValue[keyPath: value], localAction)
//        return localEffects.map { localEffect in
//            Effect { callback in
//                localEffect.run { localAction in
//                    var globalAction = globalAction
//                    globalAction[keyPath: action] = localAction
//                    callback(globalAction)
//                }
//            }
//        }
//    }
//}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action] else { return [] }
    let localEffects = reducer(&globalValue[keyPath: value], localAction)

    return localEffects.map { localEffect in
      Effect { callback in
//        guard let localAction = localEffect() else { return nil }
        localEffect.run { localAction in
          var globalAction = globalAction
          globalAction[keyPath: action] = localAction
          callback(globalAction)
        }
      }
    }

//    return effect
  }
}


public func logging<Value, Action>(_ reducer: @escaping Reducer<Value, Action>) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [ Effect{ _ in
            print("Action: \(action)")
            print("Value:")
            dump(newValue)
            print("---")
        }] + effects
    }
}
