//
//  AsyncOperation.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation

/// This is a parent operation for asynchronous operations.
/// This class should never be instantiated by itself. It is meant to be subclassed.
class AsyncOperation: Operation {
    override var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting: Bool = false
    override var isExecuting: Bool {
        get {
            return _isExecuting
        }
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    override var isFinished: Bool {
        get {
            return _isFinished
        }
        set {
            self.willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    /**
     This is called when the operation begins. Subclasses should override this method
     and call `super.start()` at the beginning of their method.
     */
    override func start() {
        isFinished = false
        isExecuting = true
    }
    
    /// The operation completes only when this method is called.
    func finish() {
        isFinished = true
    }
}
