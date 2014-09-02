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

    func testEmptyPolylineShouldBeEmptyString() {
        let sut = Polyline(fromLocationArray: [])
        XCTAssertEqual(sut.encodedPolyline,"", "Pass")
    }
    
    func testOnePointPolylineShouldBeEncodedProperly() {
        
        var points = [CLLocation(latitude: 48.8648214, longitude: 2.3817409)]
        
        let sut = Polyline(fromLocationArray: points)
        XCTAssertEqual(sut.encodedPolyline,"c|fiH{dpM", "Pass")
    }
    
    func testValidPolylineShouldBeEncodedProperly() {
        
        var points = [CLLocation(latitude: 38.5, longitude: -120.2),
            CLLocation(latitude: 40.7000, longitude: -120.95000),
            CLLocation(latitude: 43.25200, longitude: -126.453000)]
        
        let sut = Polyline(fromLocationArray: points)
        XCTAssertEqual(sut.encodedPolyline,"_p~iF~ps|U_ulLnnqC_mqNvxq`@", "Pass")
    }
    



}
