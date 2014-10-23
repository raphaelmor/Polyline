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
/// it is aims to produce the same results as google's iOS sdk not as the online
/// tool which is fuzzy when it comes to rounding values
public class Polyline {
    
    /// The encoded polyline
    public let encodedPolyline : String = ""
    
    /// The array of coordinates
    public var coordinates : Array<CLLocationCoordinate2D>?

    
    /// The array of location
    public var locations : Array<CLLocation>? {
        get {
            if let coordinates = self.coordinates {
                return toLocations(coordinates)
            } else {
                return nil
            }
        }
        set(newLocations) {
            if let locations = newLocations {
                coordinates = toCoordinates(locations)
            } else {
                coordinates = nil
            }
        }
    }
    
    /// The encoded levels
    public let encodedLevels : String = ""
    /// The array of levels
    public let levels : Array<UInt32>?
    
    /// This designated init encodes an Array<CLLocationCoordinate2D> to a String
    ///
    /// :param: coordinates The array of CLLocationCoordinate2D that you want to encode
    /// :param: levels The optional array of levels  that you want to encode
    public init(coordinates: Array<CLLocationCoordinate2D>, levels: Array<UInt32>? = nil) {
        
        self.coordinates = coordinates
        self.levels = levels
        
        self.encodedPolyline = encodeCoordinates()
        
        if let levelsToEncode = levels {
            self.encodedLevels = encodeLevels(levelsToEncode)
        }
    }
    
    /// This designated init decodes a polyline String to an Array<CLLocation>
    ///
    /// :param: encodedPolyline The polyline that you want to decode
    /// :param: encodedLevels The levels that you want to decode
    public init(encodedPolyline:String, encodedLevels:String? = nil) {
        
        self.encodedPolyline = encodedPolyline
        if let levels = encodedLevels {
            self.encodedLevels = levels
        }
        
        var decodedCoordinates = self.decodePolyline(encodedPolyline)
        
        if !decodedCoordinates.failed {
            self.coordinates = decodedCoordinates.value
        }
        
        if let levelsToDecode = encodedLevels {
            var decodedLevels = decodeLevels(levelsToDecode)
            
            if !decodedLevels.failed {
                self.levels = decodedLevels.value
            }
        }
    }
    
    /// This convenience init encodes an Array<CLLocation> to a String
    ///
    /// :param: locations The array of CLLocation that you want to encode
    /// :param: levels The optional array of levels  that you want to encode
    convenience public init(locations: Array<CLLocation>, levels: Array<UInt32>? = nil) {
        
        let coordinates = toCoordinates(locations)
        self.init(coordinates: coordinates, levels: levels)
    }
    
    // MARK:- Private methods
    // MARK:- Encoding locations
    
    private func encodeCoordinates() -> String {
        
        var previousCoordinate = IntegerCoordinates(0, 0)
        var encodedPolyline = ""
        
        if self.coordinates == nil {
            return ""
        }
        
        for coordinate in self.coordinates! {
            let intLatitude  = Int(round(coordinate.latitude * 1e5))
            let intLongitude = Int(round(coordinate.longitude * 1e5))
            
            let coordinatesDifference = (intLatitude - previousCoordinate.latitude, intLongitude - previousCoordinate.longitude)
            
            encodedPolyline += encodeCoordinate(coordinatesDifference)
            
            previousCoordinate = (intLatitude,intLongitude)
        }
        
        return encodedPolyline
    }
    
    private func encodeCoordinate(locationCoordinate: IntegerCoordinates) -> String {
    
        var latitudeString  = encodeSingleCoordinate(locationCoordinate.latitude)
        var longitudeString = encodeSingleCoordinate(locationCoordinate.longitude)
        
        return latitudeString + longitudeString
    }
    
    private func encodeSingleCoordinate(value: Int) -> String {

        var intValue = value
        
        if intValue < 0 {
            intValue = intValue << 1
            intValue = ~intValue
        } else {
            intValue = intValue << 1
        }

        return encodeFiveBitComponents(intValue)
    }
    
    
    // MARK:- Decoding locations
    
    private func decodePolyline(encodedPolyline: String) -> Result<Array<CLLocationCoordinate2D>> {
        
        var remainingPolyline = encodedPolyline.unicodeScalars
        var decodedCoordinates = [CLLocationCoordinate2D]()
        
        var lat = 0.0
        var lon = 0.0
        
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
            
            decodedCoordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        
        return .Success(decodedCoordinates)
    }
    
    private func decodeSingleCoordinate(value: String) -> Double {
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
    
    // MARK:- Encoding levels
    
    private func encodeLevels(levels: Array<UInt32>) -> String {
        return levels.reduce("") {
            $0 + self.encodeLevel($1)
        }
    }
    
    private func encodeLevel(level: UInt32) -> String {
        
       return encodeFiveBitComponents(Int(level))
    }
    
    // MARK:- Decoding levels
    private func decodeLevels(encodedLevels: String) -> Result<Array<UInt32>> {
        var remainingLevels = encodedLevels.unicodeScalars
        var decodedLevels   = [UInt32]()
        
        while countElements(remainingLevels) > 0 {
            var result = extractNextChunk(&remainingLevels)
            if result.failed {
                return .Failure
            }else{
                let level = decodeLevel(result.value!)
                decodedLevels.append(level)
            }
        }
        
        return .Success(decodedLevels)
    }
    
    func decodeLevel(encodedLevel: String) -> UInt32 {
        var scalarArray = [] + encodedLevel.unicodeScalars
        
        return UInt32(agregateScalarArray(scalarArray))
    }
    
    // MARK:- Helper methods
    
    private func isSeparator(value: Int32) -> Bool {
        return (value - 63) & 0x20 != 0x20
    }
    
    private func agregateScalarArray(scalars: [UnicodeScalar]) -> Int32 {
        let lastValue = Int32(scalars.last!.value)
        
        var fiveBitComponents : [Int32] = scalars.map { scalar in
            var value = Int32(scalar.value)
            if value != lastValue {
                return (value - 63) ^ 0x20
            } else {
                return value - 63
            }
        }
        
        return fiveBitComponents.reverse().reduce(0) { ($0 << 5 ) | $1 }
    }
    
    private func extractNextChunk(inout encodedString: String.UnicodeScalarView) -> Result<String> {
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
    
    private func encodeFiveBitComponents(value: Int) -> String {

        var remainingComponents = value
        
        var fiveBitComponent = 0
        var returnString = ""
        
        do {
            fiveBitComponent = remainingComponents & 0x1F
            
            if remainingComponents >= 0x20 {
                fiveBitComponent |= 0x20
            }
            
            fiveBitComponent += 63
            
            returnString.append(UnicodeScalar(fiveBitComponent))
            remainingComponents = remainingComponents >> 5
        } while (remainingComponents != 0)
        
        return returnString
    }
}

// MARK:- Private

typealias IntegerCoordinates = (latitude: Int, longitude: Int)

private enum Result<T> {
    case Success(T)
    case Failure
        var failed: Bool {
            switch self {
            case .Failure :
                return true
            default :
                return false
            }
        }
    var value:T? {
        switch self {
        case .Success(let result):
            return result
            
        default:
            return nil
        }
    }
}

private func toCoordinates(locations:[CLLocation]) -> [CLLocationCoordinate2D] {
    return locations.map {location in location.coordinate}
}

private func toLocations(coordinates:[CLLocationCoordinate2D]) -> [CLLocation] {
    return coordinates.map { coordinate in
        CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
    }
}
