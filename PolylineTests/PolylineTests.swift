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

class PolylineTests: XCTestCase {
    
    // MARK: - Encoding
    
    func testEmptyArrayShouldBeEmptyString() {
        let sut = Polyline(fromLocationArray: [])
        XCTAssertEqual(sut.encodedPolyline,"")
    }
    
    func testOneLocationArrayShouldBeEncodedProperly() {
        
        var locations = [CLLocation(latitude: 48.8648214, longitude: 2.3817409)]
        
        let sut = Polyline(fromLocationArray: locations)
        XCTAssertEqual(sut.encodedPolyline,"c|fiH{dpM")
    }
    
    func testValidLocationArrayShouldBeEncodedProperly() {
        
        var locations = [CLLocation(latitude: 38.5, longitude: -120.2),
            CLLocation(latitude: 40.7000, longitude: -120.95000),
            CLLocation(latitude: 43.25200, longitude: -126.453000)]
        
        let sut = Polyline(fromLocationArray: locations)
        XCTAssertEqual(sut.encodedPolyline,"_p~iF~ps|U_ulLnnqC_mqNvxq`@")
    }
    
    // MARK: - Encoding
    
    func testEmptyPolylineShouldBeEmptyLocationArray() {
        let sut = Polyline(fromPolyline: "")

        if let resultArray = sut.locations {
            XCTAssertEqual(countElements(resultArray),0)
        } else {
            XCTFail("location array should not be nil for empty string")
        }
    }
    
    func testInvalidPolylineShouldReturnNilLocationArray() {
        let sut = Polyline(fromPolyline: "invalidPolylineStrig")
        
        if let resultArray = sut.locations {
            XCTFail("location array should be nil for invalid string")
        } else {
            //Success
        }
    }
    
    func testValidPolylineShouldReturnValidLocationArray() {
        var sut = Polyline(fromPolyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@")
        
        if let resultArray = sut.locations {
            
            XCTAssertEqual(countElements(resultArray), 3)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.latitude, 38.5, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.longitude, -120.2, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.latitude, 40.7, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.longitude, -120.95, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.latitude, 43.252, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.longitude, -126.453, 0.00001)
        }
    }
    
    func testAnotherValidPolylineShouldReturnValidLocationArray() {
        var sut = Polyline(fromPolyline: "_ojiHa`tLh{IdCw{Gwc_@")
        
        if let resultArray = sut.locations {
            
            XCTAssertEqual(countElements(resultArray), 3)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.latitude, 48.8832, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[0].coordinate.longitude, 2.23761, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.latitude, 48.82747, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[1].coordinate.longitude, 2.23694, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.latitude, 48.87303, 0.00001)
            XCTAssertEqualWithAccuracy(resultArray[2].coordinate.longitude, 2.40154, 0.00001)
        }
    }
    


}
