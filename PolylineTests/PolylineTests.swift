// PolylineTests.swift
//
// Copyright (c) 2014 Raphaël Mor
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

class PolylineTests: XCTestCase {
    
    // MARK: - Encoding locations
    
    func testEmptyArrayShouldBeEmptyString() {
        let sut = Polyline(locations: [])
        XCTAssertEqual(sut.encodedPolyline,"")
    }
    
    func testOneLocationArrayShouldBeEncodedProperly() {
        
        var locations = [CLLocation(latitude: 48.8648214, longitude: 2.3817409)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"c|fiH{dpM")
    }
    
    func testValidLocationArrayShouldBeEncodedProperly() {
        
        var locations = [CLLocation(latitude: 38.5, longitude: -120.2),
            CLLocation(latitude: 40.7000, longitude: -120.95000),
            CLLocation(latitude: 43.25200, longitude: -126.453000)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"_p~iF~ps|U_ulLnnqC_mqNvxq`@")
    }
    
    // Github issue 1
    func testSmallNegativeDifferencesShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: 37.32721043, longitude: 122.02685069),
            CLLocation(latitude: 37.32727259, longitude: 122.02685280),
            CLLocation(latitude: 37.32733398, longitude: 122.02684998)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline, "anybFyjxgVK?K?")
    }
    
    // MARK: - Decoding locations
    
    func testEmptyPolylineShouldBeEmptyLocationArray() {
        let sut = Polyline(encodedPolyline: "")
        
        if let resultArray = sut.locations {
            XCTAssertEqual(countElements(resultArray),0)
        } else {
            XCTFail("location array should not be nil for empty string")
        }
    }
    
    func testInvalidPolylineShouldReturnNilLocationArray() {
        let sut = Polyline(encodedPolyline: "invalidPolylineString")
        
        if let resultArray = sut.locations {
            XCTFail("location array should be nil for invalid string")
        } else {
            //Success
        }
    }
    
    func testValidPolylineShouldReturnValidLocationArray() {
        var sut = Polyline(encodedPolyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@")
        
        if let resultArray = sut.locations {
            
            XCTAssertEqual(countElements(resultArray), 3)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.latitude, 38.5, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.longitude, -120.2, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.latitude, 40.7, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.longitude, -120.95, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.latitude, 43.252, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.longitude, -126.453, COORD_EPSILON)
        } else {
            XCTFail()
        }
    }
    
    func testAnotherValidPolylineShouldReturnValidLocationArray() {
        var sut = Polyline(encodedPolyline: "_ojiHa`tLh{IdCw{Gwc_@")
        
        if let resultArray = sut.locations {
            
            XCTAssertEqual(countElements(resultArray), 3)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.latitude, 48.8832,  COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.longitude, 2.23761, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.latitude, 48.82747, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.longitude, 2.23694, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.latitude, 48.87303, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.longitude, 2.40154, COORD_EPSILON)
        }else {
            XCTFail()
        }
    }
    
    // MARK: - Encoding levels
    
    func testEmptylevelsShouldBeEmptyString() {
        let sut = Polyline(locations: [], levels: [])
        
        if let resultLevels = sut.encodedLevels {
            XCTAssertEqual(resultLevels,"")
        }
    }
    
    func testNillevelsShouldBeNilString() {
        let sut = Polyline(locations: [], levels: nil)
        
        if let resultLevels = sut.encodedLevels {
            XCTFail()
        }
    }
    
    func testValidlevelsShouldBeEncodedProperly() {
        let sut = Polyline(locations: [], levels: [0,1,2,3])
        
        if let resultLevels = sut.encodedLevels {
            XCTAssertEqual(resultLevels,"?@AB")
        }
    }
    
    // MARK: - Decoding levels
    
    func testEmptyLevelsShouldBeEmptyLevelArray() {
        let sut = Polyline(encodedPolyline: "", encodedLevels: "")
        
        if let resultArray = sut.levels {
            XCTAssertEqual(countElements(resultArray),0)
        } else {
            XCTFail("location array should not be nil for empty string")
        }
    }
    
    func testInvalidLevelsShouldReturnNilLevelArray() {
        let sut = Polyline(encodedPolyline: "", encodedLevels: "invalidLevelString")
        
        if let resultArray = sut.levels {
            XCTFail("level array should be nil for invalid string")
        } else {
            //Success
        }
    }
    
    func testValidLevelsShouldReturnValidLevelArray() {
        var sut = Polyline(encodedPolyline: "", encodedLevels: "?@AB~F")
        
        if let resultArray = sut.levels {
            XCTAssertEqual(countElements(resultArray), 5)
            XCTAssertEqual(resultArray[0], 0)
            XCTAssertEqual(resultArray[1], 1)
            XCTAssertEqual(resultArray[2], 2)
            XCTAssertEqual(resultArray[3], 3)
            XCTAssertEqual(resultArray[4], 255)

        } else {
            XCTFail()
        }
    }
}
