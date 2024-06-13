//
//  State.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import Foundation
import Combine

@propertyWrapper
public struct State<Value> {
    public var wrappedValue: Value {
        get { observableValue.value }
        nonmutating set { observableValue.send(newValue) }
    }
    
    public let projectedValue: AnyPublisher<Value, Never>
    
    private let observableValue: CurrentValueSubject<Value, Never>
    public init(wrappedValue: Value) {
        observableValue = CurrentValueSubject(wrappedValue)
        projectedValue = observableValue
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
