import Foundation


#if os(Linux)

public typealias CLLocationDegrees = Double
public typealias CLLocationSpeed = Double
public typealias CLLocationDirection = Double
public typealias CLLocationDistance = Double
public typealias CLLocationAccuracy = Double

public struct CLLocationCoordinate2D {
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees
}

public struct CLLocation {
    public let coordinate: CLLocationCoordinate2D
    public let horizontalAccuracy: CLLocationAccuracy
    public let verticalAccuracy: CLLocationAccuracy
    public let speed: CLLocationSpeed
    public let course: CLLocationDirection
    public let timestamp: Date

    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.horizontalAccuracy = -1
        self.verticalAccuracy = -1
        self.speed = -1
        self.course = -1
        self.timestamp = Date()
    }

    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
}

#endif