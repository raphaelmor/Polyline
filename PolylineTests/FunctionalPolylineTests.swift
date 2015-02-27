// PolylineTests.swift
//
// Copyright (c) 2015 Raphaël Mor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import CoreLocation
import XCTest

import Polyline

private let COORD_EPSILON : Double = 0.00001

class FunctionalPolylineTests:XCTestCase {
    
    // MARK:- Encoding locations
    
    func testEmptyArrayShouldBeEmptyString() {
        XCTAssertEqual(encodeLocations([]), "")
    }
    
    func testZeroShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
        XCTAssertEqual(encodeCoordinates(coordinates), "??")
    }
    
    func testMinimalPositiveDifferenceShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001)]
        XCTAssertEqual(encodeCoordinates(coordinates), "AA")
    }
    
    func testLowRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.000014, longitude: 0.000014)]
        XCTAssertEqual(encodeCoordinates(coordinates), "AA")
    }
    
    func testMidRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.000015, longitude: 0.000015)]
        XCTAssertEqual(encodeCoordinates(coordinates), "CC")
    }
    
    func testHighRoundedValuesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: 0.000016, longitude: 0.000016)]
        XCTAssertEqual(encodeCoordinates(coordinates), "CC")
    }
    
    func testMinimalNegativeDifferenceShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.00001, longitude: -0.00001)]
        XCTAssertEqual(encodeCoordinates(coordinates), "@@")
    }
    
    func testLowNegativeRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.000014, longitude: -0.000014)]
        XCTAssertEqual(encodeCoordinates(coordinates), "@@")
    }
    
    func testMidNegativeRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.000015, longitude: -0.000015)]
        XCTAssertEqual(encodeCoordinates(coordinates), "BB")
    }
    
    func testHighNegativeRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.000016, longitude: -0.000016)]
        XCTAssertEqual(encodeCoordinates(coordinates), "BB")
    }
    
    func testSmallIncrementLocationArrayShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001),
            CLLocationCoordinate2D(latitude: 0.00002, longitude: 0.00002)]
        XCTAssertEqual(encodeCoordinates(coordinates), "AAAA")
    }
    
    func testSmallDecrementLocationArrayShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001),
            CLLocationCoordinate2D(latitude: 0.00000, longitude: 0.00000)]
        XCTAssertEqual(encodeCoordinates(coordinates), "AA@@")
    }
    
    // MARK:- Encoding levels
    
    func testEmptylevelsShouldBeEmptyString() {
        XCTAssertEqual(encodeLevels([]), "")
    }
    
    func testValidlevelsShouldBeEncodedProperly() {
        XCTAssertEqual(encodeLevels([0,1,2,3]), "?@AB")
    }
    
}