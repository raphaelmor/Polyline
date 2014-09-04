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
    public let locations : Array<CLLocation>?
    
    /// The encoded levels
    public let encodedLevels : String?
    /// The array of levels
    public let levels : Array<UInt32>?
    
    /// This designated init encodes an Array<CLLocation> to a String
    ///
    /// :param: locations The array of locations that you want to encode
    /// :param: levels The optional array of levels  that you want to encode
    public init(locations: Array<CLLocation>, levels: Array<UInt32>? = nil) {
        self.locations = locations
        self.levels = levels
        
        self.encodedPolyline = encodeLocations(locations)
        if let levelsToEncode = levels {
            self.encodedLevels = encodeLevels(levelsToEncode)
        }
    }
    
    /// This designated init decodes a polyline String to an Array<CLLocation>
    ///
    /// :param: encodedPolyline The polyline that you want to decode
    /// :param: encodedLevels The levels that you want to decode
    public init(encodedPolyline: String, encodedLevels: String? = nil) {
        self.encodedPolyline = encodedPolyline
        self.encodedLevels   = encodedLevels
        
        var decodedLocations    = self.decodePolyline(encodedPolyline)
        if !decodedLocations.failed {
            self.locations = decodedLocations.value
        }
        if let levelsToDecode = encodedLevels {
            var decodedLevels    = decodeLevels(levelsToDecode)
            if !decodedLevels.failed {
                self.levels = decodedLevels.value
            }
        }
    }
    
    // MARK: - Private methods
    // MARK: - Encoding locations
    
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
        var latitudeString  = encodeSingleCoordinate(locationCoordinate.latitude)
        var longitudeString = encodeSingleCoordinate(locationCoordinate.longitude)
        
        return latitudeString + longitudeString
    }
    
    private func encodeSingleCoordinate(value : Double) -> String {
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
    
    // MARK: - Decoding locations
    
    private func decodePolyline(encodedPolyline : String) -> Result<Array<CLLocation>> {
        
        var remainingPolyline = encodedPolyline.unicodeScalars
        var decodedLocations = [CLLocation]()
        
        var lat = 0.0, lon = 0.0
        
        while countElements(remainingPolyline) > 0 {
            var result = extractNextChunk(&remainingPolyline)
            if result.failed {
                return .Failure
            }
            lat += decodeSingleCoordinate(result.value!)
            
            result = extractNextChunk(&remainingPolyline)
            if result.failed {
                return .Failure
            }
            lon += decodeSingleCoordinate(result.value!)
            
            decodedLocations.append(CLLocation(latitude: lat, longitude: lon))
        }
        
        return .Success(decodedLocations)
    }
    
    private func decodeSingleCoordinate(value : String) -> Double {
        var scalarArray = [] + value.unicodeScalars
        
        var thirtyTwoBitNumber = agregateScalarArray(scalarArray)
        // check if number is negative
        if (thirtyTwoBitNumber & 0x1) == 0x1 {
            thirtyTwoBitNumber = ~(thirtyTwoBitNumber >> 1)
        } else {
            thirtyTwoBitNumber = thirtyTwoBitNumber >> 1
        }
        
        return Double(thirtyTwoBitNumber)/1e5
    }
    
    // MARK: - Encoding levels
    
    private func encodeLevels(levels : Array<UInt32>) -> String {
        return levels.reduce("") {
            $0 + self.encodeLevel($1)
        }
    }
    
    private func encodeLevel(level : UInt32) -> String {
        var value = Int(level)
        var fiveBitComponent = 0
        var returnString = ""
        
        do {
            fiveBitComponent = value & 0x1F
            
            if value > 0x20 {
                fiveBitComponent |= 0x20
            }
            
            fiveBitComponent += 63
            
            returnString.append(UnicodeScalar(fiveBitComponent))
            value = value >> 5
        } while (value != 0)
        
        return returnString
    }
    
    // MARK: - Decoding levels
    private func decodeLevels(encodedLevels : String) -> Result<Array<UInt32>> {
        var remainingLevels = encodedLevels.unicodeScalars
        var decodedLevels = [UInt32]()
        
        while countElements(remainingLevels) > 0 {
            var result = extractNextChunk(&remainingLevels)
            if result.failed {
                return .Failure
            }else{
                let level = decodeLevel(result.value!)
                decodedLevels.append(UInt32(level))
            }
        }
        
        return .Success(decodedLevels)
    }
    
    func decodeLevel(encodedLevel : String) -> UInt32 {
        var scalarArray = [] + encodedLevel.unicodeScalars
        
        return UInt32(agregateScalarArray(scalarArray))
    }
    
    // MARK: - Helper methods
    
    private func isSeparator(value : Int32) -> Bool {
        return (value - 63) & 0x20 != 0x20
    }
    
    private func agregateScalarArray(scalars : [UnicodeScalar]) -> Int32 {
        let lastValue = Int32(scalars.last!.value)
        
        var fiveBitComponents = scalars.map { (scalar : UnicodeScalar) -> Int32 in
            var value = Int32(scalar.value)
            if value != lastValue {
                return (value - 63) ^ 0x20
            } else {
                return value - 63
            }
        }
        
        return fiveBitComponents.reverse().reduce(0) { ($0 << 5 ) | $1 }
    }
    
    private func extractNextChunk(inout encodedString : String.UnicodeScalarView) -> Result<String> {
        var currentIndex = encodedString.startIndex
        
        while currentIndex != encodedString.endIndex {
            var currentCharacterValue = Int32(encodedString[currentIndex].value)
            if isSeparator(currentCharacterValue) {
                var extractedScalars = encodedString[encodedString.startIndex...currentIndex]
                encodedString = encodedString[currentIndex.successor()..<encodedString.endIndex]
                
                return .Success(String(extractedScalars))
            }
            
            currentIndex = currentIndex.successor()
        }
        
        return .Failure
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