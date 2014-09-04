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

/// This class can be used for :
/// * Encoding an Array<CLLocation> to a polyline String
/// * Decoding a polyline String to an Array<CLLocation>
///
/// it is based on google's algorithm that can be found here :
/// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
public class Polyline {

    /// The encoded polyline
    public let encodedPolyline : String = ""
    /// The array of location
    public let locations : Array<CLLocation>? = nil
    
    /// This designated init encodes an Array<CLLocation> to a String
    ///
    /// :param: locations The Array of CLLocation that you want to encode
    public init(fromLocationArray locations : Array<CLLocation>) {
        self.locations = locations
        self.encodedPolyline = encodeLocations(locations)
    }

    /// This designated init decodes a polyline String to an Array<CLLocation>
    ///
    /// :param: polyline The polyline that you want to decode
    public init(fromPolyline polyline : String) {
        self.encodedPolyline = polyline
        var decodedPoints = decodePolyline(polyline)
        if !decodedPoints.failed {
            self.locations = decodedPoints.value
        }
    }
    
    // MARK: - Private Methods
    // MARK: - Encoding
    
    private func encodeLocations(locations : Array<CLLocation>) -> String {
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
    
    // MARK: - Decoding

    private func decodePolyline(encodedPolyline : String) -> Result<Array<CLLocation>> {
        
        var remainingPolyline = encodedPolyline.unicodeScalars
        var decodedPoints = [CLLocation]()
        
        var lat = 0.0, lon = 0.0
        
        while countElements(remainingPolyline) > 0 {
            println("remaining polyline : \(remainingPolyline)")
            
            var result = decodeNextValue(&remainingPolyline)
            if result.failed {
                return .Failure
            }
            lat += result.value!
            
            result = decodeNextValue(&remainingPolyline)
            if result.failed {
                return .Failure
            }
            lon += result.value!
            
            decodedPoints.append(CLLocation(latitude: lat, longitude: lon))
        }
        
        return .Success(decodedPoints)
    }
    
    private func decodeNextValue(inout remainingPolyline : String.UnicodeScalarView) -> Result<Double> {
        var currentIndex = remainingPolyline.startIndex
        
        while currentIndex != remainingPolyline.endIndex {
            var currentCharacterValue = Int32(remainingPolyline[currentIndex].value)
            if isSeparator(currentCharacterValue) {
                var extractedScalars = remainingPolyline[remainingPolyline.startIndex...currentIndex]
                remainingPolyline = remainingPolyline[currentIndex.successor()..<remainingPolyline.endIndex]
                
                return .Success(decodeSingleValue(String(extractedScalars)))
            }
            
            currentIndex = currentIndex.successor()
        }
        
        return .Failure
    }
    
    private func decodeSingleValue(value : String) -> Double {
        var scalarArray = [] + value.unicodeScalars
        let lastValue = Int32(scalarArray.last!.value)
        
        var fiveBitComponents = scalarArray.map { (scalar : UnicodeScalar) -> Int32 in
            var value = Int32(scalar.value)
            if value != lastValue {
                return (value - 63) ^ 0x20
            } else {
                return value - 63
            }
        }
        
        var thirtyTwoBitNumber = fiveBitComponents.reverse().reduce(0) { ($0 << 5 ) | $1 }
        // check if number is negative
        if (thirtyTwoBitNumber & 0x1) == 0x1 {
            thirtyTwoBitNumber = ~(thirtyTwoBitNumber >> 1)
        } else {
            thirtyTwoBitNumber = thirtyTwoBitNumber >> 1
        }
        
        return Double(thirtyTwoBitNumber)/1e5
    }
    
    private func isSeparator(value : Int32) -> Bool {
        return (value - 63) & 0x20 != 0x20
    }
}

private enum Result<T> {
    case Success(T)
    case Failure
    var failed: Bool {
        switch self {
        case .Failure:
            return true
        default:
            return false
            }
    }
    var value: T? {
        switch self {
        case .Success(let result):
            return result
            
        default:
            return nil
            }
    }
}