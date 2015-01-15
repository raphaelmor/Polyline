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
public struct Polyline {
	
	/// The array of coordinates
	public let coordinates: Array<CLLocationCoordinate2D>
	/// The encoded polyline
	public let encodedPolyline: String = ""
	
	/// The array of levels
	public let levels: Array<UInt32>?
	// The encoded levels
	public let encodedLevels: String = ""
	
	/// The array of location
	public var locations: Array<CLLocation> {
		return toLocations(coordinates)
	}
	
	/// This designated init encodes an Array<CLLocationCoordinate2D> to a String
	///
	/// :param: coordinates The array of CLLocationCoordinate2D that you want to encode
	/// :param: levels The optional array of levels  that you want to encode
	public init(coordinates: Array<CLLocationCoordinate2D>, levels: Array<UInt32>? = nil) {
		
		self.coordinates = coordinates
		self.levels = levels
		
		encodedPolyline = encodeCoordinates()
		
		if let levelsToEncode = levels {
			encodedLevels = encodeLevels(levelsToEncode)
		}
	}
	
	/// This designated init decodes a polyline String to an Array<CLLocation>
	///
	/// :param: encodedPolyline The polyline that you want to decode
	/// :param: encodedLevels The levels that you want to decode
	public init(encodedPolyline: String, encodedLevels: String? = nil) {
		
		self.encodedPolyline = encodedPolyline
		coordinates = []
		
		let decodedCoordinates = decodePolyline(encodedPolyline)
		
		if !decodedCoordinates.failed {
			coordinates = decodedCoordinates.value!
		}
		
		if let levelsToDecode = encodedLevels {
			self.encodedLevels = levelsToDecode
			
			let decodedLevels = decodeLevels(levelsToDecode)
			
			if !decodedLevels.failed {
				levels = decodedLevels.value
			}
		}
	}
	
	/// This init encodes an Array<CLLocation> to a String
	///
	/// :param: locations The array of CLLocation that you want to encode
	/// :param: levels The optional array of levels  that you want to encode
	public init(locations: Array<CLLocation>, levels: Array<UInt32>? = nil) {
		
		let coordinates = toCoordinates(locations)
		self.init(coordinates: coordinates, levels: levels)
	}
	
	// MARK:- Private methods
	// MARK:- Encoding locations
	
	private func encodeCoordinates() -> String {
		
		var previousCoordinate = IntegerCoordinates(0, 0)
		var encodedPolyline = ""
		
		for coordinate in coordinates {
			let intLatitude  = Int(round(coordinate.latitude * 1e5))
			let intLongitude = Int(round(coordinate.longitude * 1e5))
			
			let coordinatesDifference = (intLatitude - previousCoordinate.latitude, intLongitude - previousCoordinate.longitude)
			
			encodedPolyline += encodeCoordinate(coordinatesDifference)
			
			previousCoordinate = (intLatitude,intLongitude)
		}
		
		return encodedPolyline
	}
	
	private func encodeCoordinate(locationCoordinate: IntegerCoordinates) -> String {
		
		let latitudeString  = encodeSingleCoordinate(locationCoordinate.latitude)
		let longitudeString = encodeSingleCoordinate(locationCoordinate.longitude)
		
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
		
        let data = encodedPolyline.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let byteArray = unsafeBitCast(data.bytes, UnsafePointer<Int8>.self)
        let length = Int(data.length)
        var position = Int(0)
        
        var decodedCoordinates = [CLLocationCoordinate2D]()
        
        var lat = 0.0
        var lon = 0.0
        
        while position < length {

            lat += decodeSingleCoordinate(byteArray, length: length, position: &position)
            lon += decodeSingleCoordinate(byteArray, length: length, position: &position)
            
            decodedCoordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        
        return .Success(decodedCoordinates)
    }
	
    private func decodeSingleCoordinate(byteArray: UnsafePointer<Int8>, length: Int, inout position: Int ) -> Double {
		
        var value : Int32 = 0
        
        if position >= length {
            return 0.0
        }
        
        var firstComponent: Int32 = 0
        var secondComponent: Int32 = 0
        var thirdComponent: Int32 = 0
        var fourthComponent: Int32 = 0
        var fifthComponent: Int32 = 0
        var sixthComponent: Int32 = 0
        
        let bitMask = Int8(0x1F)
        
        
       
        var currentChar = byteArray[position] - 63
        firstComponent = Int32(currentChar & bitMask)
        position++;
        
        if (((currentChar & 0x20) == 0x20) && (position < length)) {
            currentChar = byteArray[position]-63;
            position++;
            secondComponent = Int32(currentChar & bitMask)
        }
        
        if (((currentChar & 0x20) == 0x20) && (position < length)) {
            currentChar = byteArray[position]-63;
            position++;
            thirdComponent = Int32(currentChar & bitMask)
        }
        
        if (((currentChar & 0x20) == 0x20) && (position < length)) {
            currentChar = byteArray[position]-63;
            position++;
            fourthComponent = Int32(currentChar & bitMask)
        }
        
        if (((currentChar & 0x20) == 0x20) && (position < length)) {
            currentChar = byteArray[position]-63;
            position++;
            fifthComponent = Int32(currentChar & bitMask)
        }
        
        if (((currentChar & 0x20) == 0x20) && (position < length)) {
            currentChar = byteArray[position]-63;
            position++;
            sixthComponent = Int32(currentChar & bitMask)
        }
        
        value |= firstComponent
        value |= (secondComponent << (5 * 1))
        value |= (thirdComponent << (5 * 2))
        value |= (fourthComponent << (5 * 3))
        value |= (fifthComponent << (5 * 4))
        value |= (sixthComponent << (5 * 5))
                
        if ( (value & 0x01) == 0x01) {
            // le nombre codé est negatif :
            value = ~(value>>1);
        } else {
            value = value>>1;
        }
        
        return Double(value) / 100000.0;
        
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
	
	private func decodeLevel(encodedLevel: String) -> UInt32 {
		let scalarArray = [] + encodedLevel.unicodeScalars
		
		return UInt32(agregateScalarArray(scalarArray))
	}
	
	// MARK:- Helper methods
	
	private func isSeparator(value: Int32) -> Bool {
		return (value - 63) & 0x20 != 0x20
	}
	
	private func agregateScalarArray(scalars: [UnicodeScalar]) -> Int32 {
		let lastValue = Int32(scalars.last!.value)
		
		var fiveBitComponents: [Int32] = scalars.map { scalar in
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
			let currentCharacterValue = Int32(encodedString[currentIndex].value)
			if isSeparator(currentCharacterValue) {
				let extractedScalars = encodedString[encodedString.startIndex...currentIndex]
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
	var value: T? {
		switch self {
		case .Success(let result):
			return result
		default:
			return nil
		}
	}
}

private func toCoordinates(locations: [CLLocation]) -> [CLLocationCoordinate2D] {
	return locations.map {location in location.coordinate}
}

private func toLocations(coordinates: [CLLocationCoordinate2D]) -> [CLLocation] {
	return coordinates.map { coordinate in
		CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
	}
}
