//
//  FatalErrorExpectations.swift
//  ErrorAssertionExpectations
//
//  Created by Jeff Kelley on 7/1/19.
//

import XCTest

import ErrorAssertions

extension XCTestCase {
    
    /// Executes the `testcase` closure and expects it to produce a specific
    /// fatal error.
    ///
    /// - Parameters:
    ///   - expectedError: The `Error` you expect `testcase` to pass to
    ///                    `fatalError()`.
    ///   - timeout: How long to wait for `testcase` to produce its error.
    ///              defaults to 2 seconds.
    ///   - file: The test file. By default, this will be the file from which
    ///           you’re calling this method.
    ///   - line: The line number in `file` where this is called.
    ///   - testcase: The closure to run that produces the error.
    public func expectFatalError<T: Error>(
        expectedError: T,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line,
        testcase: @escaping () -> Void
    ) where T: Equatable {
        let expectation = self
            .expectation(description: "expectingFatalError_\(file):\(line)")
        
        var fatalError: T? = nil
        
        FatalErrorUtilities.replaceFatalError { error, _, _ in
            fatalError = error as? T
            expectation.fulfill()
            unreachable()
        }
        
        let thread = ClosureThread(testcase)
        thread.start()
        
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(fatalError,
                           expectedError,
                           file: file,
                           line: line)
            
            FatalErrorUtilities.restoreFatalError()
            
            thread.cancel()
        }
    }
    
    /// Executes the `testcase` closure and expects it to produce a specific
    /// fatal error message.
    ///
    /// - Parameters:
    ///   - message: The `String` you expect `testcase` to pass to
    ///              `fatalError()`.
    ///   - timeout: How long to wait for `testcase` to produce its error.
    ///              defaults to 2 seconds.
    ///   - file: The test file. By default, this will be the file from which
    ///           you’re calling this method.
    ///   - line: The line number in `file` where this is called.
    ///   - testcase: The closure to run that produces the error.
    public func expectFatalError(
        expectedMessage message: String,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line,
        testcase: @escaping () -> Void
    ) {
        expectFatalError(expectedError: AnonymousError(string: message),
                         timeout: timeout,
                         file: file,
                         line: line,
                         testcase: testcase)
    }
    
    /// Executes the `testcase` closure and expects it to produce a fatal error.
    ///
    /// - Parameters:
    ///   - timeout: How long to wait for `testcase` to produce its error.
    ///              defaults to 2 seconds.
    ///   - file: The test file. By default, this will be the file from which
    ///           you’re calling this method.
    ///   - line: The line number in `file` where this is called.
    ///   - testcase: The closure to run that produces the error.
    public func expectFatalError(
        timeout: TimeInterval = 2,
        in context: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line,
        testcase: @escaping () -> Void
    ) {
        let expectation = self
            .expectation(description: "expectingFatalError_\(file):\(line)")
        
        FatalErrorUtilities.replaceFatalError { _, _, _ in
            expectation.fulfill()
            unreachable()
        }
        
        let thread = ClosureThread(testcase)
        thread.start()
        
        waitForExpectations(timeout: timeout) { _ in
            FatalErrorUtilities.restoreFatalError()
            thread.cancel()
        }
    }
    
    /// Executes the `testcase` closure and expects it execute without producing
    /// a fatal error.
    ///
    /// - Parameters:
    ///   - timeout: How long to wait for `testcase` to finish. Defaults to 2
    ///              seconds.
    ///   - file: The test file. By default, this will be the file from which
    ///           you’re calling this method.
    ///   - line: The line number in `file` where this is called.
    ///   - testcase: The closure to run.
    public func expectNoFatalError(
        timeout: TimeInterval = 2,
        in context: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line,
        testcase: @escaping () -> Void
    ) {
        let expectation = self.expectation(
            description: "Expecting no fatal error to occur."
        )
        
        FatalErrorUtilities.replaceFatalError { _, _, _ in
            XCTFail("Received a fatal error when expecting none",
                    file: file,
                    line: line)
            
            expectation.fulfill()
            unreachable()
        }
        
        let thread = ClosureThread {
            testcase()
            expectation.fulfill()
        }
        
        thread.start()
        
        waitForExpectations(timeout: timeout) { _ in
            FatalErrorUtilities.restoreFatalError()
            thread.cancel()
        }
    }
    
}
