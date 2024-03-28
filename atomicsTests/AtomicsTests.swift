//
//  atomicsTests.swift
//  atomicsTests
//
//  Created by Alexandre Fenyo on 28/03/2024.
//

import XCTest
@testable import atomics

final class AtomicsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SpinLock.initialize()
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SpinLock.deinitialize()
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBasic() {
        let at_foo = AdvancedAtomic(Foo())
        
        // incrémenter foo.bar
        at_foo.tryAtomic { foo in
            foo.bar += 1
        }
        
        // prendre une copie de foo.bar
        let bar = at_foo.atomic { $0.bar }
        print("bar:\(bar)")
    }

    func testBasicException() {
        let at_foo = AdvancedAtomic(Foo())
        
        // incrémenter foo.bar
        do {
            try at_foo.tryAtomicEx { foo in
                foo.bar += 1
            }
            
            // prendre une copie de foo.bar
            let bar = try at_foo.tryAtomicEx { $0.bar }
            print("bar:\(bar)")
        } catch {
            print("Exception thrown")
        }
    }
}
