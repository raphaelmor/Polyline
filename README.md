![Polyline: Polyline encoding/decoding in Swift](https://raw.githubusercontent.com/raphaelmor/Polyline/assets/polyline.png)

Polyline encoder / decoder in Swift

## Features

- Encode a CLLocation array to a polyline
- Decode a polyline to an Array of point

### Planned for 1.0.0

- Encode/Decode associated levels
- 100% Unit Test Coverage
- Complete Documentation
- Example project


## Requirements

- Xcode 6 Beta 7
- iOS 7.0+ / Mac OS X 10.9+


---

## Usage

### Polyline Encoding

```swift
let polyline = Polyline(fromLocationArray: locations)
let encodedPolyline : String = polyline.encodedPolyline
```

### Polyline Decoding

```swift
let polyline = Polyline(fromPolyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@")
let decodedLocations : Array<CLLocation>? = polyline.locations
```


### Creator

- [Raphael Mor](http://github.com/raphaelmor) ([@raphaelmor](https://twitter.com/raphaelmor))

## License

Polyline is released under an MIT license. See LICENSE for more information.