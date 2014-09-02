// Polyline.swift
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

import Foundation

import CoreLocation


//https://developers.google.com/maps/documentation/utilities/polylinealgorithm
public class Polyline {
    
    public lazy var encodedPolyline : String = {
        let temporaryPolyline = self.encodePoints(self.locations)
        return temporaryPolyline
    }()
    public let locations : Array<CLLocation>
    
    public init(fromLocationArray locations : Array<CLLocation>) {
        self.locations = locations
    }
    
// MARK: - Private Methods
    
    private func encodePoints(locations : Array<CLLocation>) -> String {
        var previousCoordinate = CLLocationCoordinate2DMake(0.0, 0.0)
        var encodedPolyline = ""
        
        for location in locations {
            let coordinatesDifference = CLLocationCoordinate2DMake(location.coordinate.latitude - previousCoordinate.latitude, location.coordinate.longitude - previousCoordinate.longitude)
            
            encodedPolyline += encodeCoordinate(coordinatesDifference)
            
            previousCoordinate = location.coordinate
        }
        
        return encodedPolyline
    }
    
    private func encodeCoordinate(locationCoordinate : CLLocationCoordinate2D) -> String {
        var latitudeString  = encodeSingleValue(locationCoordinate.latitude)
        var longitudeString = encodeSingleValue(locationCoordinate.longitude)
        
        return latitudeString + longitudeString
    }
    
    private func encodeSingleValue(value : Double) -> String {
        
        let e5Value = value * 1e5
        var intValue = Int(round(e5Value))
        intValue = intValue << 1
        
        if value < 0 {
            intValue = ~intValue
        }
        var fiveBitComponent = 0
        var returnString = ""
        
        do {
            fiveBitComponent = intValue & 0x1F
            if intValue > 0x20 {
                fiveBitComponent |= 0x20
            }
            fiveBitComponent += 63
            
            returnString.append(UnicodeScalar(fiveBitComponent))
            intValue = intValue >> 5
        } while (intValue != 0)
        
        return returnString
    }
}
