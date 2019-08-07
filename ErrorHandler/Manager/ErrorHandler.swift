//
//  ErrorHandler.swift
//  ErrorHandler
//
//  Created by Stefan Renne on 05/07/2019.
//  Copyright © 2019 stefanrenne. All rights reserved.
//

import Foundation

public typealias OnErrorHandled = (() -> Void)?

open class ErrorHandler {
    
    private let view: ErrorHandlerView
    public init(for errorHandlerView: ErrorHandlerView) {
        self.view = errorHandlerView
    }
    
    private var specificErrorActions = [(ErrorMatcher, ActionHandler)]()
    private var defaultAction: ActionHandler?
    
    /// adds an error handler for a specific error to the ErrorHandler
    ///
    /// - Parameters:
    ///   - error: The error matcher
    ///   - then action: The action that needs to be performed when the error matches
    /// - Returns: an instance of self (for chaining purposes)
    @discardableResult
    public func `if`(error errors: ErrorMatcher..., then action: ActionHandler) -> ErrorHandler {
        errors.forEach { (error) in
            self.specificErrorActions.append((error, action))
        }
        return self
    }
    
    /// adds a default error handler to the ErrorHandler
    ///
    /// - Parameters:
    ///   - then action: the catch-all action that needs to be performed when no other match can be found
    /// - Returns: an instance of self (for chaining purposes)
    @discardableResult
    public func `else`(then action: ActionHandler) -> ErrorHandler {
        self.defaultAction = action
        return self
    }
    
    /// This function is called to handle an error
    ///
    /// - Parameter error: The error that should be handled
    /// - Parameter onHandled: The optional block that gets executed after the error has been handled successfully
    /// - Returns: an boolean inidication if the error was handled successfully
    @discardableResult
    public func handle(error: Error, onHandled: OnErrorHandled) -> Bool {
        
        var handled = false
        
        // Check if we have a handler for this error:
        if let action = specificErrorActions.firstAction(for: error) {
            handled = action.perform(on: view, for: error, onHandled: onHandled)
        }
        
        // use the default handler if present
        if !handled, let defaultAction = defaultAction {
            handled = defaultAction.perform(on: view, for: error, onHandled: onHandled)
        }
        
        // If the error is still unhandled -> Log it
        if !handled {
            print("unhandled error: \(error.localizedDescription)")
        }
        
        return handled
    }
    
    /// This convenience function is called to handle an error
    /// The main reason for this function is to handle RxSwift errors inline
    /// Example: subscribe(onError: errorHandler.handle)
    ///
    /// - Parameter error: The error that should be handled
    public func handle(error: Error) {
        handle(error: error, onHandled: nil)
    }
}
