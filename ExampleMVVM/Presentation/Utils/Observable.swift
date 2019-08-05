//
//  Box.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.02.19.
//

import Foundation

class Observer<Value> {
    
    typealias ObserverBlock  = (Value) -> Void
    
    weak var observer: AnyObject?
    let block: ObserverBlock
    let queue: DispatchQueue
    
    init(observer: AnyObject, queue: DispatchQueue, block: @escaping ObserverBlock) {
        self.observer = observer
        self.queue = queue
        self.block = block
    }
}

public class Observable<Value> {
    
    private var observers = [Observer<Value>]()
    
    public var value : Value {
        didSet {
            self.notifyObservers()
        }
    }
    
    public init(_ value: Value) {
        self.value = value
    }
    
    func observe(on observer: AnyObject, queue: DispatchQueue = .main, observerBlock: @escaping Observer<Value>.ObserverBlock) {
        self.observers.append(Observer(observer: observer, queue: queue, block: observerBlock))
    }
    
    func observeAndFire(on observer: AnyObject, queue: DispatchQueue = .main, observerBlock: @escaping Observer<Value>.ObserverBlock) {
        self.observers.append(Observer(observer: observer, queue: queue, block: observerBlock))
        observerBlock(value)
    }
    
    func remove(observer: AnyObject) {
        self.observers = self.observers.filter({ $0.observer !== observer })
    }
    
    private func notifyObservers() {
        for observer in self.observers {
            observer.queue.async { [weak self] in
                guard let weakSelf = self else { return }
                observer.block(weakSelf.value)
            }
        }
    }
}
