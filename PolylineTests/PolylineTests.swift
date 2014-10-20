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

    func testZeroShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: 0, longitude: 0)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"??")
    }

    func testMinimalPositiveDifferenceShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: 0.00001, longitude: 0.00001)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"AA")
    }

    func testLowRoundedValuesShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: 0.000014, longitude: 0.000014)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"AA")
    }

    func testMidRoundedValuesShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: 0.000015, longitude: 0.000015)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"CC")
    }

    func testHighRoundedValuesShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: 0.000016, longitude: 0.000016)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"CC")
    }

    func testMinimalNegativeDifferenceShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: -0.00001, longitude: -0.00001)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"@@")
    }

    func testLowNegativeRoundedValuesShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: -0.000014, longitude: -0.000014)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"@@")
    }

    func testMidNegativeRoundedValuesShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: -0.000015, longitude: -0.000015)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"BB")
    }

    func testHighNegativeRoundedValuesShouldBeEncodedProperly() {
        var locations = [CLLocation(latitude: -0.000016, longitude: -0.000016)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"BB")
    }

    func testSmallIncrementLocationArrayShouldBeEncodedProperly() {
        
        var locations = [CLLocation(latitude: 0.00001, longitude: 0.00001),
            CLLocation(latitude: 0.00002, longitude: 0.00002)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"AAAA")
    }
    
    func testSmallDecrementLocationArrayShouldBeEncodedProperly() {
        
        var locations = [CLLocation(latitude: 0.00001, longitude: 0.00001),
            CLLocation(latitude: 0.00000, longitude: 0.00000)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline,"AA@@")
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

    // MARK: - Issues
    
    func testIssue2DumbedDown() {
        var sourceLocations = [CLLocation(latitude: 0.00016, longitude: -0.00032)]

        let sut = Polyline(locations: sourceLocations)
        XCTAssertEqual(sut.encodedPolyline, "_@~@")
    }
    
    func testIssue2() {
        var sourceLocations = [
            CLLocation(latitude: 37.36489494, longitude: -122.12775531),
            CLLocation(latitude: 37.36489561, longitude: -122.12814457),
            CLLocation(latitude: 37.36489536, longitude: -122.12851823),
            CLLocation(latitude: 37.36490102, longitude: -122.12889651),
            CLLocation(latitude: 37.364913, longitude: -122.12927755),
            CLLocation(latitude: 37.36492641, longitude: -122.12966111),
            CLLocation(latitude: 37.36495642, longitude: -122.13002966),
            CLLocation(latitude: 37.36500231, longitude: -122.13039762),
            CLLocation(latitude: 37.36505801, longitude: -122.13076299),
            CLLocation(latitude: 37.36513495, longitude: -122.13112023),
            CLLocation(latitude: 37.36522619, longitude: -122.13147671),
            CLLocation(latitude: 37.36533088, longitude: -122.13182204),
            CLLocation(latitude: 37.36543834, longitude: -122.13217241),
            CLLocation(latitude: 37.36554852, longitude: -122.13253006),
            CLLocation(latitude: 37.36565505, longitude: -122.13287858),
            CLLocation(latitude: 37.36576171, longitude: -122.13322476),
            CLLocation(latitude: 37.3658664, longitude: -122.13358057),
            CLLocation(latitude: 37.36597474, longitude: -122.1339342),
            CLLocation(latitude: 37.36607239, longitude: -122.13427694),
            CLLocation(latitude: 37.36617599, longitude: -122.13462026),
            CLLocation(latitude: 37.36627984, longitude: -122.13496408),
            CLLocation(latitude: 37.36637342, longitude: -122.13530514),
            CLLocation(latitude: 37.3664761, longitude: -122.13564763),
            CLLocation(latitude: 37.36657341, longitude: -122.13598643),
            CLLocation(latitude: 37.36667454, longitude: -122.13633075),
            CLLocation(latitude: 37.3667825, longitude: -122.13667173),
            CLLocation(latitude: 37.3668918, longitude: -122.13700784),
            CLLocation(latitude: 37.36700588, longitude: -122.13734664),
            CLLocation(latitude: 37.36714083, longitude: -122.13768569),
            CLLocation(latitude: 37.36728357, longitude: -122.13801602),
            CLLocation(latitude: 37.36743034, longitude: -122.13834434),
            CLLocation(latitude: 37.36759001, longitude: -122.13866201),   // FAILS !!!
            CLLocation(latitude: 37.36776176, longitude: -122.13898061),
            CLLocation(latitude: 37.36794754, longitude: -122.13929619),
            CLLocation(latitude: 37.36813371, longitude: -122.13959391),
            CLLocation(latitude: 37.36833646, longitude: -122.13988803),
            CLLocation(latitude: 37.36854278, longitude: -122.1401674),
            CLLocation(latitude: 37.36876231, longitude: -122.14043713),
            CLLocation(latitude: 37.36898397, longitude: -122.14069152),
            CLLocation(latitude: 37.36921459, longitude: -122.14094005),
            CLLocation(latitude: 37.36945654, longitude: -122.1411796),
            CLLocation(latitude: 37.3697059, longitude: -122.14141823),
            CLLocation(latitude: 37.36994839, longitude: -122.1416339),
            CLLocation(latitude: 37.37019243, longitude: -122.14186189),
            CLLocation(latitude: 37.37043777, longitude: -122.14209172),
            CLLocation(latitude: 37.37068524, longitude: -122.14231367),
            CLLocation(latitude: 37.37092857, longitude: -122.14253931),
            CLLocation(latitude: 37.37117332, longitude: -122.14276269),
            CLLocation(latitude: 37.37142067, longitude: -122.14297886),
            CLLocation(latitude: 37.37167049, longitude: -122.14320232),
            CLLocation(latitude: 37.37190954, longitude: -122.14341883),
            CLLocation(latitude: 37.37215601, longitude: -122.14364204),
            CLLocation(latitude: 37.37240005, longitude: -122.14386038),
            CLLocation(latitude: 37.37263743, longitude: -122.14409064),
            CLLocation(latitude: 37.37287229, longitude: -122.14430781),
            CLLocation(latitude: 37.37311268, longitude: -122.14451887),
            CLLocation(latitude: 37.37336271, longitude: -122.14472699),
            CLLocation(latitude: 37.37361371, longitude: -122.14495984),
            CLLocation(latitude: 37.37385134, longitude: -122.14517802),
            CLLocation(latitude: 37.37409077, longitude: -122.14540877),
            CLLocation(latitude: 37.37433481, longitude: -122.14563986),
            CLLocation(latitude: 37.37457281, longitude: -122.14588663),
            CLLocation(latitude: 37.37481249, longitude: -122.14611939),
            CLLocation(latitude: 37.37503792, longitude: -122.14636347),
            CLLocation(latitude: 37.37527039, longitude: -122.14662055),
            CLLocation(latitude: 37.37550207, longitude: -122.14687494)
            ]
      
        let sut = Polyline(locations: sourceLocations)
        XCTAssertEqual(sut.encodedPolyline, "qy`cFnalhVAjA?jA?jAAjACjAEhAGhAKfAMfASfASbAUdAUfAUdASbAUfASdASdAUbASbAQdAUbAQbASbAUbAUbAWbAYbA[`A]~@_@~@a@~@e@~@c@x@i@z@g@v@k@t@k@p@m@p@q@n@q@n@o@h@o@l@q@l@q@j@o@l@o@j@q@j@q@j@o@j@q@j@o@j@o@l@m@j@o@h@q@h@q@l@o@j@o@l@o@l@o@p@o@l@m@n@m@r@m@p@")
    }
    
}
