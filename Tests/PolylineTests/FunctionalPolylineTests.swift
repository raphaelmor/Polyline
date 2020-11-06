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

#if canImport(CoreLocation)
import CoreLocation
#endif
import XCTest

import Polyline

private let COORD_EPSILON: Double = 0.00001

class FunctionalPolylineTests : XCTestCase {
    
    // MARK:- Encoding Coordinates
    
    func testEmptyArrayShouldBeEmptyString() {
        XCTAssertEqual(encodeCoordinates([]), "")
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
        let coordinates = [CLLocationCoordinate2D(latitude: 0.000016, longitude: 0.000016)]
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
    
    // MARK: - Decoding Coordinates
    
    func testEmptyPolylineShouldBeEmptyLocationArray() {
        let coordinates: [CLLocationCoordinate2D] = decodePolyline("")!
        
        XCTAssertEqual(coordinates.count, 0)
    }
    
    func testInvalidPolylineShouldReturnEmptyLocationArray() {
        XCTAssertNil(decodePolyline("invalidPolylineString") as [CLLocationCoordinate2D]?)
    }
    
    func testValidPolylineShouldReturnValidLocationArray() {
        let coordinates: [CLLocationCoordinate2D] = decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@")!
        
        XCTAssertEqual(coordinates.count, 3)
        XCTAssertEqual(coordinates[0].latitude, 38.5, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[0].longitude, -120.2, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[1].latitude, 40.7, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[1].longitude, -120.95, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[2].latitude, 43.252, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[2].longitude, -126.453, accuracy: COORD_EPSILON)
    }
    
    func testAnotherValidPolylineShouldReturnValidLocationArray() {
        let coordinates: [CLLocationCoordinate2D] = decodePolyline("_ojiHa`tLh{IdCw{Gwc_@")!
        
        XCTAssertEqual(coordinates.count, 3)
        XCTAssertEqual(coordinates[0].latitude, 48.8832,  accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[0].longitude, 2.23761, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[1].latitude, 48.82747, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[1].longitude, 2.23694, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[2].latitude, 48.87303, accuracy: COORD_EPSILON)
        XCTAssertEqual(coordinates[2].longitude, 2.40154, accuracy: COORD_EPSILON)
    }
    
    // MARK:- Encoding levels
    
    func testEmptylevelsShouldBeEmptyString() {
        XCTAssertEqual(encodeLevels([]), "")
    }
    
    func testValidlevelsShouldBeEncodedProperly() {
        XCTAssertEqual(encodeLevels([0,1,2,3]), "?@AB")
    }
    
    // MARK:- Decoding levels
    
    func testEmptyLevelsShouldBeEmptyLevelArray() {
        if let resultArray = decodeLevels("") {
            XCTAssertEqual(resultArray.count, 0)
        } else {
            XCTFail("Level array should not be nil for empty string")
        }
    }
    
    func testInvalidLevelsShouldReturnNilLevelArray() {
        if let _ = decodeLevels("invalidLevelString") {
            XCTFail("Level array should be nil for invalid string")
        } else {
            //Success
        }
    }
    
    func testValidLevelsShouldReturnValidLevelArray() {
        if let resultArray = decodeLevels("?@AB~F") {
            XCTAssertEqual(resultArray.count, 5)
            XCTAssertEqual(resultArray[0], UInt32(0))
            XCTAssertEqual(resultArray[1], UInt32(1))
            XCTAssertEqual(resultArray[2], UInt32(2))
            XCTAssertEqual(resultArray[3], UInt32(3))
            XCTAssertEqual(resultArray[4], UInt32(255))
            
        } else {
            XCTFail("Valid Levels should be decoded properly")
        }
    }
    
    // MARK: - Encoding Locations
    func testLocationsArrayShouldBeEncodedProperly() {
        #if canImport(CoreLocation)
        let locations = [CLLocation(latitude: 0.00001, longitude: 0.00001),
            CLLocation(latitude: 0.00000, longitude: 0.00000)]
        
        XCTAssertEqual(encodeLocations(locations), "AA@@")
        #endif
    }
    
    func testDecodingPolyline() {
        let coordinates = decodePolyline("afvnFdrebO@o@", precision: 1e5) as [LocationCoordinate2D]?
        XCTAssertNotNil(coordinates)
        XCTAssertEqual(coordinates?.count, 2)
        XCTAssertEqual(coordinates?.first?.latitude ?? 0.0, 39.27665, accuracy: 1e-5)
        XCTAssertEqual(coordinates?.first?.longitude ?? 0.0, -84.411389, accuracy: 1e-5)
        XCTAssertEqual(coordinates?.last?.latitude ?? 0.0, 39.276635, accuracy: 1e-5)
        XCTAssertEqual(coordinates?.last?.longitude ?? 0.0, -84.411148, accuracy: 1e-5)
    }
}
