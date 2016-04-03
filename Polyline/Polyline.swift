// Polyline.swift
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

import Foundation
import CoreLocation

// MARK: - Public Classes -

/// This class can be used for :
///
/// - Encoding an [CLLocation] or a [CLLocationCoordinate2D] to a polyline String
/// - Decoding a polyline String to an [CLLocation] or a [CLLocationCoordinate2D]
/// - Encoding / Decoding associated levels
///
/// it is aims to produce the same results as google's iOS sdk not as the online
/// tool which is fuzzy when it comes to rounding values
///
/// it is based on google's algorithm that can be found here :
///
/// :see: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
public struct Polyline {
    
    /// The array of coordinates (nil if polyline cannot be decoded)
    public let coordinates: [CLLocationCoordinate2D]?
    /// The encoded polyline
    public let encodedPolyline: String
    
    /// The array of levels (nil if cannot be decoded, or is not provided)
    public let levels: [UInt32]?
    /// The encoded levels (nil if cannot be encoded, or is not provided)
    public let encodedLevels: String?
    
    /// The array of location (computed from coordinates)
    public var locations: [CLLocation]? {
        return self.coordinates.map(toLocations)
    }
    
    // MARK: - Public Methods -
    
    /// This designated initializer encodes a `[CLLocationCoordinate2D]`
    ///
    /// - parameter coordinates: The `Array` of `CLLocationCoordinate2D` that you want to encode
    /// - parameter levels: The optional `Array` of levels  that you want to encode (default: `nil`)
    /// - parameter precision: The precision used for encoding (default: `1e5`)
    public init(coordinates: [CLLocationCoordinate2D], levels: [UInt32]? = nil, precision: Double = 1e5) {
        
        self.coordinates = coordinates
        self.levels = levels
        
        encodedPolyline = encodeCoordinates(coordinates, precision: precision)
        
        encodedLevels = levels.map(encodeLevels)
    }
    
    /// This designated initializer decodes a polyline `String`
    ///
    /// - parameter encodedPolyline: The polyline that you want to decode
    /// - parameter encodedLevels: The levels that you want to decode (default: `nil`)
    /// - parameter precision: The precision used for decoding (default: `1e5`)
    public init(encodedPolyline: String, encodedLevels: String? = nil, precision: Double = 1e5) {
        
        self.encodedPolyline = encodedPolyline
        self.encodedLevels = encodedLevels
        
        coordinates = decodePolyline(encodedPolyline, precision: precision)

        levels = self.encodedLevels.flatMap(decodeLevels)
    }
    
    /// This init encodes a `[CLLocation]`
    ///
    /// - parameter locations: The `Array` of `CLLocation` that you want to encode
    /// - parameter levels: The optional array of levels  that you want to encode (default: `nil`)
    /// - parameter precision: The precision used for encoding (default: `1e5`)
    public init(locations: [CLLocation], levels: [UInt32]? = nil, precision: Double = 1e5) {
        
        let coordinates = toCoordinates(locations)
        self.init(coordinates: coordinates, levels: levels, precision:precision)
    }
}

// MARK: - Public Functions -

/// This function encodes an `[CLLocationCoordinate2D]` to a `String`
///
/// - parameter coordinates: The `Array` of `CLLocationCoordinate2D` that you want to encode
/// - parameter precision: The precision used to encode coordinates (default: `1e5`)
///
/// - returns: A `String` representing the encoded Polyline
public func encodeCoordinates(coordinates: [CLLocationCoordinate2D], precision: Double = 1e5) -> String {
    
    var previousCoordinate = IntegerCoordinates(0, 0)
    var encodedPolyline = ""
    
    for coordinate in coordinates {
        let intLatitude  = Int(round(coordinate.latitude * precision))
        let intLongitude = Int(round(coordinate.longitude * precision))
        
        let coordinatesDifference = (intLatitude - previousCoordinate.latitude, intLongitude - previousCoordinate.longitude)
        
        encodedPolyline += encodeCoordinate(coordinatesDifference)
        
        previousCoordinate = (intLatitude,intLongitude)
    }
    
    return encodedPolyline
}

/// This function encodes an `[CLLocation]` to a `String`
///
/// - parameter coordinates: The `Array` of `CLLocation` that you want to encode
/// - parameter precision: The precision used to encode locations (default: `1e5`)
///
/// - returns: A `String` representing the encoded Polyline
public func encodeLocations(locations: [CLLocation], precision: Double = 1e5) -> String {
    
    return encodeCoordinates(toCoordinates(locations), precision: precision)
}

/// This function encodes an `[UInt32]` to a `String`
///
/// - parameter levels: The `Array` of `UInt32` levels that you want to encode
///
/// - returns: A `String` representing the encoded Levels
public func encodeLevels(levels: [UInt32]) -> String {
    return levels.reduce("") {
        $0 + encodeLevel($1)
    }
}

/// This function decodes a `String` to a `[CLLocationCoordinate2D]?`
///
/// - parameter encodedPolyline: `String` representing the encoded Polyline
/// - parameter precision: The precision used to decode coordinates (default: `1e5`)
///
/// - returns: A `[CLLocationCoordinate2D]` representing the decoded polyline if valid, `nil` otherwise
public func decodePolyline(encodedPolyline: String, precision: Double = 1e5) -> [CLLocationCoordinate2D]? {
    
    let data = encodedPolyline.dataUsingEncoding(NSUTF8StringEncoding)!
    
    let byteArray = unsafeBitCast(data.bytes, UnsafePointer<Int8>.self)
    let length = Int(data.length)
    var position = Int(0)
    
    var decodedCoordinates = [CLLocationCoordinate2D]()
    
    var lat = 0.0
    var lon = 0.0
    
    while position < length {
      
        do {
            let resultingLat = try decodeSingleCoordinate(byteArray: byteArray, length: length, position: &position, precision: precision)
            lat += resultingLat
            
            let resultingLon = try decodeSingleCoordinate(byteArray: byteArray, length: length, position: &position, precision: precision)
            lon += resultingLon
        } catch {
            return nil
        }

        decodedCoordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
    }
    
    return decodedCoordinates
}

/// This function decodes a String to a [CLLocation]?
///
/// - parameter encodedPolyline: String representing the encoded Polyline
/// - parameter precision: The precision used to decode locations (default: 1e5)
///
/// - returns: A [CLLocation] representing the decoded polyline if valid, nil otherwise
public func decodePolyline(encodedPolyline: String, precision: Double = 1e5) -> [CLLocation]? {
    
    return decodePolyline(encodedPolyline, precision: precision).map(toLocations)
}

/// This function decodes a `String` to an `[UInt32]`
///
/// - parameter encodedLevels: The `String` representing the levels to decode
///
/// - returns: A `[UInt32]` representing the decoded Levels if the `String` is valid, `nil` otherwise
public func decodeLevels(encodedLevels: String) -> [UInt32]? {
    var remainingLevels = encodedLevels.unicodeScalars
    var decodedLevels   = [UInt32]()
    
    while remainingLevels.count > 0 {
        
        do {
            let chunk = try extractNextChunk(&remainingLevels)
            let level = decodeLevel(chunk)
            decodedLevels.append(level)
        } catch {
            return nil
        }
    }
    
    return decodedLevels
}


// MARK: - Private -

// MARK: Encode Coordinate

private func encodeCoordinate(locationCoordinate: IntegerCoordinates) -> String {
    
    let latitudeString  = encodeSingleComponent(locationCoordinate.latitude)
    let longitudeString = encodeSingleComponent(locationCoordinate.longitude)
    
    return latitudeString + longitudeString
}

private func encodeSingleComponent(value: Int) -> String {
    
    var intValue = value
    
    if intValue < 0 {
        intValue = intValue << 1
        intValue = ~intValue
    } else {
        intValue = intValue << 1
    }
    
    return encodeFiveBitComponents(intValue)
}

// MARK: Encode Levels

private func encodeLevel(level: UInt32) -> String {
    return encodeFiveBitComponents(Int(level))
}

private func encodeFiveBitComponents(value: Int) -> String {
    var remainingComponents = value
    
    var fiveBitComponent = 0
    var returnString = ""
    
    repeat {
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

// MARK: Decode Coordinate

// We use a byte array (UnsafePointer<Int8>) here for performance reasons. Check with swift 2 if we can
// go back to using [Int8]
private func decodeSingleCoordinate(byteArray byteArray: UnsafePointer<Int8>, length: Int, inout position: Int, precision: Double = 1e5) throws -> Double {
    
    guard position < length else { throw PolylineError.SingleCoordinateDecodingError }
    
    let bitMask = Int8(0x1F)
    
    var coordinate: Int32 = 0
    
    var currentChar: Int8
    var componentCounter: Int32 = 0
    var component: Int32 = 0
    
    repeat {
        currentChar = byteArray[position] - 63
        component = Int32(currentChar & bitMask)
        coordinate |= (component << (5*componentCounter))
        position += 1
        componentCounter += 1
    } while ((currentChar & 0x20) == 0x20) && (position < length) && (componentCounter < 6)
    
    if (componentCounter == 6) && ((currentChar & 0x20) == 0x20) {
        throw PolylineError.SingleCoordinateDecodingError
    }
    
    if (coordinate & 0x01) == 0x01 {
        coordinate = ~(coordinate >> 1)
    } else {
        coordinate = coordinate >> 1
    }
    
    return Double(coordinate) / precision
}

// MARK: Decode Levels

private func extractNextChunk(inout encodedString: String.UnicodeScalarView) throws -> String {
    var currentIndex = encodedString.startIndex
    
    while currentIndex != encodedString.endIndex {
        let currentCharacterValue = Int32(encodedString[currentIndex].value)
        if isSeparator(currentCharacterValue) {
            let extractedScalars = encodedString[encodedString.startIndex...currentIndex]
            encodedString = encodedString[currentIndex.successor()..<encodedString.endIndex]
            
            return String(extractedScalars)
        }
        
        currentIndex = currentIndex.successor()
    }
    
    throw PolylineError.ChunkExtractingError
}

private func decodeLevel(encodedLevel: String) -> UInt32 {
    let scalarArray = [] + encodedLevel.unicodeScalars
    
    return UInt32(agregateScalarArray(scalarArray))
}

private func agregateScalarArray(scalars: [UnicodeScalar]) -> Int32 {
    let lastValue = Int32(scalars.last!.value)
    
    let fiveBitComponents: [Int32] = scalars.map { scalar in
        let value = Int32(scalar.value)
        if value != lastValue {
            return (value - 63) ^ 0x20
        } else {
            return value - 63
        }
    }
    
    return Array(fiveBitComponents.reverse()).reduce(0) { ($0 << 5 ) | $1 }
}

// MARK: Utilities

enum PolylineError: ErrorType {
    case SingleCoordinateDecodingError
    case ChunkExtractingError
}

private func toCoordinates(locations: [CLLocation]) -> [CLLocationCoordinate2D] {
    return locations.map {location in location.coordinate}
}

private func toLocations(coordinates: [CLLocationCoordinate2D]) -> [CLLocation] {
    return coordinates.map { coordinate in
        CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
    }
}

private func isSeparator(value: Int32) -> Bool {
    return (value - 63) & 0x20 != 0x20
}

private typealias IntegerCoordinates = (latitude: Int, longitude: Int)
