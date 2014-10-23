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

class PolylineTests:XCTestCase {
    
    // MARK:- Encoding locations
    
    func testEmptyArrayShouldBeEmptyString() {
        let sut = Polyline(locations: [])
        XCTAssertEqual(sut.encodedPolyline, "")
    }

    func testZeroShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "??")
    }

    func testMinimalPositiveDifferenceShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AA")
    }

    func testLowRoundedValuesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: 0.000014, longitude: 0.000014)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AA")
    }

    func testMidRoundedValuesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: 0.000015, longitude: 0.000015)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "CC")
    }

    func testHighRoundedValuesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: 0.000016, longitude: 0.000016)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "CC")
    }

    func testMinimalNegativeDifferenceShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: -0.00001, longitude: -0.00001)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "@@")
    }

    func testLowNegativeRoundedValuesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: -0.000014, longitude: -0.000014)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "@@")
    }

    func testMidNegativeRoundedValuesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: -0.000015, longitude: -0.000015)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "BB")
    }

    func testHighNegativeRoundedValuesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: -0.000016, longitude: -0.000016)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "BB")
    }

    func testSmallIncrementLocationArrayShouldBeEncodedProperly() {
        
        var coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001),
            CLLocationCoordinate2D(latitude: 0.00002, longitude: 0.00002)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AAAA")
    }
    
    func testSmallDecrementLocationArrayShouldBeEncodedProperly() {
        
        var coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001),
            CLLocationCoordinate2D(latitude: 0.00000, longitude: 0.00000)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AA@@")
    }

    // MARK:- Decoding locations
    
    func testEmptyPolylineShouldBeEmptyLocationArray() {
        let sut = Polyline(encodedPolyline: "")
        
        if let resultArray = sut.coordinates {
            XCTAssertEqual(countElements(resultArray), 0)
        } else {
            XCTFail("location array should not be nil for empty string")
        }
    }

    func testInvalidPolylineShouldReturnNilLocationArray() {
        let sut = Polyline(encodedPolyline: "invalidPolylineString")
        
        if let resultArray = sut.coordinates {
            XCTFail("location array should be nil for invalid string")
        } else {
            //Success
        }
    }

    func testValidPolylineShouldReturnValidLocationArray() {
        var sut = Polyline(encodedPolyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@")
        
        if let resultArray = sut.coordinates {
            
            XCTAssertEqual(countElements(resultArray), 3)
            XCTAssertEqualWithAccuracy(resultArray[0].latitude, 38.5, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[0].longitude, -120.2, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].latitude, 40.7, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].longitude, -120.95, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].latitude, 43.252, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].longitude, -126.453, COORD_EPSILON)
        } else {
            XCTFail()
        }
    }

    func testAnotherValidPolylineShouldReturnValidLocationArray() {
        var sut = Polyline(encodedPolyline: "_ojiHa`tLh{IdCw{Gwc_@")
        
        if let resultArray = sut.coordinates {
            
            XCTAssertEqual(countElements(resultArray), 3)
            XCTAssertEqualWithAccuracy(resultArray[0].latitude, 48.8832,  COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[0].longitude, 2.23761, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].latitude, 48.82747, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[1].longitude, 2.23694, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].latitude, 48.87303, COORD_EPSILON)
            XCTAssertEqualWithAccuracy(resultArray[2].longitude, 2.40154, COORD_EPSILON)
        }else {
            XCTFail()
        }
    }

    
    // MARK:- Encoding levels
    
    func testEmptylevelsShouldBeEmptyString() {
        let sut = Polyline(locations: [], levels: [])
        
        XCTAssertEqual(sut.encodedLevels, "")
    }

    func testNillevelsShouldBeEmptyString() {
        let sut = Polyline(locations: [], levels: nil)
        
        XCTAssertEqual(sut.encodedLevels, "")

    }

    func testValidlevelsShouldBeEncodedProperly() {
        let sut = Polyline(locations: [], levels: [0,1,2,3])
        
        XCTAssertEqual(sut.encodedLevels, "?@AB")
    }

    // MARK:- Decoding levels
    
    func testEmptyLevelsShouldBeEmptyLevelArray() {
        let sut = Polyline(encodedPolyline: "", encodedLevels: "")
        
        if let resultArray = sut.levels {
            XCTAssertEqual(countElements(resultArray), 0)
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
    
    // MARK:- Encoding coordinates
    func testLocationsArrayShouldBeEncodedProperly() {
        
        var locations = [CLLocation(latitude: 0.00001, longitude: 0.00001),
            CLLocation(latitude: 0.00000, longitude: 0.00000)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline, "AA@@")
    }


    // MARK:- Issues non-regression tests
    
    // Github Issue 1
    func testSmallNegativeDifferencesShouldBeEncodedProperly() {
        var coordinates = [CLLocationCoordinate2D(latitude: 37.32721043, longitude: 122.02685069),
            CLLocationCoordinate2D(latitude: 37.32727259, longitude: 122.02685280),
            CLLocationCoordinate2D(latitude: 37.32733398, longitude: 122.02684998)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "anybFyjxgVK?K?")
    }
    
    // Github Issue 3
    func testLimitValueIsProperlyEncoded() {
        var sourceCoordinates = [CLLocationCoordinate2D(latitude: 0.00016, longitude: -0.00032)]

        let sut = Polyline(coordinates: sourceCoordinates)
        XCTAssertEqual(sut.encodedPolyline, "_@~@")
    }
    
    // MARK:- README code samples 
    
    func testCoordinatesEncoding() {
        let coordinates = [CLLocationCoordinate2D(latitude: 40.2349727, longitude: -3.7707443),
            CLLocationCoordinate2D(latitude: 44.3377999, longitude: 1.2112933)]
        
        let polyline = Polyline(coordinates: coordinates)
        let encodedPolyline : String = polyline.encodedPolyline
        XCTAssertEqual(polyline.encodedPolyline, "qkqtFbn_Vui`Xu`l]")
    }
    
    func testLocationsEncoding() {
        let locations = [CLLocation(latitude: 40.2349727, longitude: -3.7707443),
            CLLocation(latitude: 44.3377999, longitude: 1.2112933)]
        
        let polyline = Polyline(locations: locations)
        let encodedPolyline : String = polyline.encodedPolyline
        XCTAssertEqual(polyline.encodedPolyline, "qkqtFbn_Vui`Xu`l]")
    }
    
    func testLevelEncoding() {
        let coordinates = [CLLocationCoordinate2D(latitude: 40.2349727, longitude: -3.7707443),
            CLLocationCoordinate2D(latitude: 44.3377999, longitude: 1.2112933)]
        
        let levels : [UInt32] = [0,1,2,255]
        
        let polyline = Polyline(coordinates: coordinates, levels: levels)
        let encodedLevels : String = polyline.encodedLevels
    }
    
    func testPolylineDecodingToCoordinate() {
        let polyline = Polyline(encodedPolyline: "qkqtFbn_Vui`Xu`l]")
        let decodedCoordinates : Array<CLLocationCoordinate2D>? = polyline.coordinates
        
        XCTAssertEqual(2, decodedCoordinates!.count)
    }
    
    func testPolylineDecodingToLocations() {
        let polyline = Polyline(encodedPolyline: "qkqtFbn_Vui`Xu`l]")
        let decodedLocations : Array<CLLocation>? = polyline.locations
        
        XCTAssertEqual(2, decodedLocations!.count)
    }
    
    
    func testLevelDecoding() {
        let polyline = Polyline(encodedPolyline: "qkqtFbn_Vui`Xu`l]", encodedLevels: "BA")
        let decodedLevels : Array<UInt32>? = polyline.levels

        XCTAssertEqual(2, decodedLevels!.count)
    }
    
}
