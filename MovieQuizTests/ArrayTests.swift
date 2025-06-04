//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Максим on 5/30/25.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    func testGetValueInRange() throws {
        // G
        let array = [1, 1, 2, 3, 5]
        // W
        let value = array[safe: 2]
        // T
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    func testGetValueOutOfRange() throws {
        
        // G
        let array = [1, 1, 2, 3, 5]
        // W
        let value = array[safe: 20]
        // T
        XCTAssertNil(value)
    }
}
