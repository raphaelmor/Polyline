// PolylineTests.swift
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

#if canImport(CoreLocation)
import CoreLocation
#endif
import XCTest

import Polyline

private let COORD_EPSILON_1e5: Double = 0.00001
private let COORD_EPSILON_1e6: Double = 0.000001

class PolylineTests:XCTestCase {
    
    // MARK:- Encoding Coordinates
    
    func testEmptyArrayShouldBeEmptyString() {
        let sut = Polyline(coordinates: [])
        XCTAssertEqual(sut.encodedPolyline, "")
    }
    
    func testZeroShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "??")
    }
    
    func testMinimalPositiveDifferenceShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AA")
    }
    
    func testLowRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.000014, longitude: 0.000014)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AA")
    }
    
    func testMidRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.000015, longitude: 0.000015)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "CC")
    }
    
    func testHighRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.000016, longitude: 0.000016)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "CC")
    }
    
    func testMinimalNegativeDifferenceShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.00001, longitude: -0.00001)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "@@")
    }
    
    func testLowNegativeRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.000014, longitude: -0.000014)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "@@")
    }
    
    func testMidNegativeRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.000015, longitude: -0.000015)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "BB")
    }
    
    func testHighNegativeRoundedValuesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: -0.000016, longitude: -0.000016)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "BB")
    }
    
    func testSmallIncrementLocationArrayShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001),
            CLLocationCoordinate2D(latitude: 0.00002, longitude: 0.00002)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AAAA")
    }
    
    func testSmallDecrementLocationArrayShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 0.00001, longitude: 0.00001),
            CLLocationCoordinate2D(latitude: 0.00000, longitude: 0.00000)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "AA@@")
    }
    
    func testPrecisionShouldBeUsedProperlyInEncoding() {
        let coordinates = [CLLocationCoordinate2D(latitude: 10.1234567, longitude:10.1234567)]
        
        var sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "sfx|@sfx|@")
        
        sut = Polyline(coordinates: coordinates, precision: 1e5)
        XCTAssertEqual(sut.encodedPolyline, "sfx|@sfx|@")
        
        sut = Polyline(coordinates: coordinates, precision: 1e6)
        XCTAssertEqual(sut.encodedPolyline, "ak{hRak{hR")
    }
    
    // MARK:- Decoding Coordinates
    
    func testEmptyPolylineShouldBeEmptyLocationArray() {
        let sut = Polyline(encodedPolyline: "")
        XCTAssertTrue(sut.coordinates != nil)
        XCTAssertEqual((sut.coordinates!).count, 0)
    }
    
    func testInvalidPolylineShouldReturnNil() {
        let sut = Polyline(encodedPolyline: "invalidPolylineString")
        XCTAssertTrue(sut.coordinates == nil)
    }

    func testValidPolylineShouldReturnValidLocationArray() {
        let sut = Polyline(encodedPolyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@")
        
        let coordinates = sut.coordinates!
        
        XCTAssertEqual(coordinates.count, 3)
        XCTAssertEqual(coordinates[0].latitude, 38.5, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[0].longitude, -120.2, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[1].latitude, 40.7, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[1].longitude, -120.95, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[2].latitude, 43.252, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[2].longitude, -126.453, accuracy: COORD_EPSILON_1e5)
    }

    func testAnotherValidPolylineShouldReturnValidLocationArray() {
        let sut = Polyline(encodedPolyline: "_ojiHa`tLh{IdCw{Gwc_@")
        
        let coordinates = sut.coordinates!
        
        XCTAssertEqual(coordinates.count, 3)
        XCTAssertEqual(coordinates[0].latitude, 48.8832,  accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[0].longitude, 2.23761, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[1].latitude, 48.82747, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[1].longitude, 2.23694, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[2].latitude, 48.87303, accuracy: COORD_EPSILON_1e5)
        XCTAssertEqual(coordinates[2].longitude, 2.40154, accuracy: COORD_EPSILON_1e5)
    }

    func testPrecisionShouldBeUsedProperlyInDecoding() {
        
        var sut = Polyline(encodedPolyline: "sfx|@sfx|@")
        
        var coordinates = sut.coordinates!
        
        XCTAssertEqual(coordinates.count, 1)
        XCTAssertEqual(coordinates[0].latitude, 10.1234567,  accuracy: COORD_EPSILON_1e5)
        
        sut = Polyline(encodedPolyline: "sfx|@sfx|@", precision: 1e5)
        
        coordinates = sut.coordinates!
        
        XCTAssertEqual(coordinates.count, 1)
        XCTAssertEqual(coordinates[0].latitude, 10.1234567, accuracy: COORD_EPSILON_1e5)
        
        sut = Polyline(encodedPolyline: "ak{hRak{hR", precision: 1e6)

        coordinates = sut.coordinates!
        
        XCTAssertEqual(coordinates.count, 1)
        XCTAssertEqual(coordinates[0].latitude, 10.1234567, accuracy: COORD_EPSILON_1e6)
        
    }

    // MARK:- Encoding levels
    
    func testEmptylevelsShouldBeEmptyString() {
        let sut = Polyline(coordinates: [], levels: [])
        
        XCTAssertTrue(sut.encodedLevels != nil)
        XCTAssertEqual(sut.encodedLevels!, "")
    }

    func testNillevelsShouldBeNil() {
        let sut = Polyline(coordinates: [], levels: nil)
        
        XCTAssertTrue(sut.encodedLevels == nil)
    }

    func testValidlevelsShouldBeEncodedProperly() {
        let sut = Polyline(coordinates: [], levels: [0,1,2,3])
        
        XCTAssertEqual(sut.encodedLevels!, "?@AB")
    }

    // MARK:- Decoding levels
    
    func testEmptyLevelsShouldBeEmptyLevelArray() {
        let sut = Polyline(encodedPolyline: "", encodedLevels: "")
        
        XCTAssertTrue(sut.levels != nil,"Level array should not be nil for empty string")
        XCTAssertEqual((sut.levels!).count, 0)
    }

    func testInvalidLevelsShouldReturnNilLevelArray() {
        let sut = Polyline(encodedPolyline: "", encodedLevels: "invalidLevelString")
        
        XCTAssertTrue(sut.levels == nil, "Level array should be nil for invalid string")
    }

    func testValidLevelsShouldReturnValidLevelArray() {
        let sut = Polyline(encodedPolyline: "", encodedLevels: "?@AB~F")
        
        if let resultArray = sut.levels {
            XCTAssertEqual(resultArray.count, 5)
            XCTAssertEqual(resultArray[0], UInt32(0))
            XCTAssertEqual(resultArray[1], UInt32(1))
            XCTAssertEqual(resultArray[2], UInt32(2))
            XCTAssertEqual(resultArray[3], UInt32(3))
            XCTAssertEqual(resultArray[4], UInt32(255))
            
        } else {
            XCTFail("Valid Levels should be decoded properly")
        }
    }

    // MARK:- Encoding Locations
    func testLocationsArrayShouldBeEncodedProperly() {
        #if canImport(CoreLocation)
        let locations = [CLLocation(latitude: 0.00001, longitude: 0.00001),
            CLLocation(latitude: 0.00000, longitude: 0.00000)]
        
        let sut = Polyline(locations: locations)
        XCTAssertEqual(sut.encodedPolyline, "AA@@")
        #endif
    }
    
    // MARK:- Issues non-regression tests
    
    // Github Issue 1
    func testSmallNegativeDifferencesShouldBeEncodedProperly() {
        let coordinates = [CLLocationCoordinate2D(latitude: 37.32721043, longitude: 122.02685069),
            CLLocationCoordinate2D(latitude: 37.32727259, longitude: 122.02685280),
            CLLocationCoordinate2D(latitude: 37.32733398, longitude: 122.02684998)]
        
        let sut = Polyline(coordinates: coordinates)
        XCTAssertEqual(sut.encodedPolyline, "anybFyjxgVK?K?")
    }
    
    // Github Issue 3
    func testLimitValueIsProperlyEncoded() {
        let sourceCoordinates = [CLLocationCoordinate2D(latitude: 0.00016, longitude: -0.00032)]
        
        let sut = Polyline(coordinates: sourceCoordinates)
        XCTAssertEqual(sut.encodedPolyline, "_@~@")
    }
    
    // Github issue 4
    func testPrecisionIsUsedProperly() {
        let encoded = "}gqefAridwgFrYEAhfA{@jDsAxBoBzBaDtB{iAX{c@EsU]uf@?_WR~@tPlTFfg@?jUNj|@eBtu@K?z]cAjLkDlJuFjGyG`IyCjIsAlM?|k@v@|dArQbv@k@jIpA?"
        let sut : [CLLocationCoordinate2D] = decodePolyline(encoded, precision: 1e6)!
        
        XCTAssertEqual(sut.count, 30)
        XCTAssertEqual(sut[0].latitude, 37.332111, accuracy: COORD_EPSILON_1e6)
        XCTAssertEqual(sut[0].longitude, -122.030762, accuracy: COORD_EPSILON_1e6)
    }
    
    // Github Issue 8
    func testPerformances() {
        self.measure {
            let _ = Polyline(encodedPolyline:"wamrIo{gnAnG_CVIm@{NEsDFgAHu@^{C`@sC@_As@eWEoBIw@?QDYd@oB@Uv@eDHOViAPwB@_ACUGQIcDYiIsA{a@EcB?iBD]JyBV}C@GJKDOCUMOO@MLy@@}ATI@McEQsLCcC?}@De@BQNe@gDcEgBsCSa@Yy@QiAS{D?gAJ_APmAt@wD`@eDDq@?aCk@uTcBif@KiBSkBa@wBUu@u@yB}CmHo@oAw@kA_@g@y@s@w@i@eJiF}BcB_BwAoCsDaB_DwLsWaBaDyB}Dm@qA_AcDEOIq@Sy@AuBBu@LgAR}@|@kCt@}Ab@s@^g@hAoAb@]jBkAdHqDt@[~@QxABNEHEdA}@TYbAyATQXKdC[n@Sr@c@r@}@|BwE~@eBjAyAvAaAlCaBlCoAjC_A|Cu@lLeBnDcAxBy@xDmBlEkCvDcCrFaEHGxAg@nAYf@Cz@@hCd@zAHj@MTIf@c@T]Zo@b@iBFo@DgA?k@CgAEa@Y_BoBeHo@sC{@iFg@qBk@aDqBeJaBcG}E_P{AsFq@kCk@eCwAmIm@yEk@cFg@eHU{FAiBMaIIiHImDSwF_@gGc@wFq@_G]aCc@yCcAsFiAeFCQ}FgUcEaRmBsJ_C}M_BaK{A{KsC_V_Gil@WqDy@kJk@eHyAeSu@mL]{Ha@kNI_GEkKFcV?mHKeHK}Cg@eKa@cFWmCm@}Ea@uCcCqMm@mCmAoEq@wBuA{DuAmD_BiDeDkG]u@{AwC{BaFiA_Dy@gCiA_Em@cCeAyEo@oDs@yEq@wFm@iHIyA]qIQiJIiBAkBDg@Ru@DOJSFc@Bc@AUIg@M[]aDIsAWyUs@cx@MqJ[wL_@gLg@uLo@oLiAkRo@_Iy@kH_@uCy@}Ey@mDaBcGkDsIgBkDgAaBiDiEkBqB}AkAmCaBaImDkAs@{BeBaBkBmBqCaCoEy@sBw@}Bq@aCoA{EeA_Fg@qCsAaJ_@sC]}CUqC_@qFIuAUkGQeIG}QCsRFuD?_CDgIAoJMyMUaLq@mO[wF}@uMe@oFc@kDu@wF{@{E_BwH[wAmDkL{HaToC}HwA{DiAkD_AuDyA_Ig@}Dg@wCyCiTi@cDy@qGcAeGkHyi@oAcJwBoPwAyJs@yFy@kFoFy_@wBeNkA}HcEuZeBqKOyAs@kEk@qEq@qE[cBWkBoAmHsBeOCQCuD\\{Bd@_Cz@aAbDuC~HuH|BsCjBqCdAgBrAgC~AwDjA{ClA}DrAmFf@_Cz@yE^aCh@_EVaCl@eHPcCp@qNbAuPf@_HtA}Nr@gG|@}GfAmHbB_JrAqG~AoItFkX`@_Cd@uDb@iEb@mFTiEXmJDyDAkDGeD]sIe@oG_A_Ko@gGaA{HwAyJi@eDqAoHiCiMmByH_EmOoCkIaGyR]_A}AcF_AiD}@_DwAiHc@oCa@kDa@gGQaEEwJFoD^}Ib@gF^kCZeCT}@x@oE\\yAtCaOb@iCv@qGV{CXwEJwE\\gh@RaMZsIv@iMX}CXyBnAeIj@qCx@cDrCkJrIeWdAmDp@mC`AsE\\gC~AeJTqBJq@VeDd@yH`@qMZaNx@c\\DaCDiAjAmc@f@iOjDwy@RqC|AcR|@}HtAiK~@oGn@oD|Hoa@vAwJ\\oCl@sGb@cF`@kHF_C`@iKJiH?gJIiDCoBo@yRsBga@[cREsFBeU`@sOTwGFeC~@cWf@wK~@_WbAu[vEmuAfAoXHiLHmTKe]GiCYoHY_Ew@aH}CmSwBkQgBcPw@uKScFCwCHeHZcIx@iOf@cMF}Bn@s^v@k\\n@i[j@aRNwGf@aPNsHb@kP|@yWp@wPLiFLqCbBej@?m@f@sQnAi_@b@mNlAg[VqE\\yELaCLuAdAmKXqB`@{D~BcTn@aGDm@NiATqC@i@F_BCeBOqDK}@e@yCAUDYBQFKn@Er@Bt@Jb@ApBS`CHfFIpEo@lFgB`FwC|@u@vCoCxA}AdEsG`CgFr@kBnAcE`BcHd@uCb@{Dj@kHNsCrAq`@T}ZFSFkAR_BBQDIrBwB|Ca@fGKhADbLfBlD`AhCz@pExBtBpAxCtBt@b@dBr@|@TjBTnBCbAK^IxCeAp@]xC}Bv@u@rCuDxSo\\jBsCfnAgnB|TiZjD}Df@a@bD{BpDsBfIyCvh@yXzB}@pAYnEi@tGArD}@nOsFxJuFjLeIvF}C`GkEtBmA|AUn@AdQP~Fo@zBNtO~B`CV`@@b@I~@o@d@i@|@gB`IeT|C{Ib@aB^iB~DmS`AsD~@eCb@_AXe@lBmCjd@m`@rJcIxKgKbEcDzQmS|CyCfDiCbDmBjBy@tEaBfIqAnQmBbA[|AY|EgBdF_CxH_GtAmAbDsDd@o@|e@mt@vCaEhHqIbL{KvF}DrNmJl@El@c@v@g@\\s@~@o@tG_E\\AbEiCZe@dB}@hGsA^EdCBfC[zNy@`Di@fAM`@Mz@_@~UcIdHcB~CWdACx]nAnFl@pBh@fEvBjRfKrP~IvGlCfB\\rF^n@@~AKpC]fYeH`@EfECrDZ`Ej@xFp@rBFtBErAKnCe@~Ae@lBu@~HcEjF{BpJkDzJaDpCmAtDiC|BqBhEaFbCeCXChBuApBcAb@EJ@RBPEFQh@a@pBq@R@RJL@H?Jd@Xf@TFNATONSDKz@o@XMp@OTMpBUfAQjDoA|BwAv@o@j@]~A_BtIyJtEcGpC_EHKLNNEDKBOC[tDqFtAaBt@u@jAeAfBuALKfA_BjDoEfDiC~@a@BCYyDYsBCQz@aAHIP~@")
        }
    }

    // MARK:- README code samples
    
    func testCoordinatesEncoding() {
        let coordinates = [CLLocationCoordinate2D(latitude: 40.2349727, longitude: -3.7707443),
            CLLocationCoordinate2D(latitude: 44.3377999, longitude: 1.2112933)]
        
        let polyline = Polyline(coordinates: coordinates)
        XCTAssertEqual(polyline.encodedPolyline, "qkqtFbn_Vui`Xu`l]")
    }
    
    func testLocationsEncoding() {
        #if canImport(CoreLocation)
        let locations = [CLLocation(latitude: 40.2349727, longitude: -3.7707443),
            CLLocation(latitude: 44.3377999, longitude: 1.2112933)]
        
        let polyline = Polyline(locations: locations)
        XCTAssertEqual(polyline.encodedPolyline, "qkqtFbn_Vui`Xu`l]")
        #endif
    }
    
    func testLevelEncoding() {
        let coordinates = [CLLocationCoordinate2D(latitude: 40.2349727, longitude: -3.7707443),
            CLLocationCoordinate2D(latitude: 44.3377999, longitude: 1.2112933)]
        
        let levels: [UInt32] = [0,1,2,255]
        
        let polyline = Polyline(coordinates: coordinates, levels: levels)
        let _ : String? = polyline.encodedLevels
    }
    
    func testPolylineDecodingToCoordinate() {
        let polyline = Polyline(encodedPolyline: "qkqtFbn_Vui`Xu`l]")
        
        let decodedCoordinates: [CLLocationCoordinate2D]? = polyline.coordinates
        XCTAssertEqual(2, decodedCoordinates!.count)
    }
    
    func testPolylineDecodingToLocations() {
        #if canImport(CoreLocation)
        let polyline = Polyline(encodedPolyline: "qkqtFbn_Vui`Xu`l]")
        let decodedLocations: [CLLocation]? = polyline.locations
        
        XCTAssertEqual(2, decodedLocations!.count)
        #endif
    }
    
    func testLevelDecoding() {
        let polyline = Polyline(encodedPolyline: "qkqtFbn_Vui`Xu`l]", encodedLevels: "BA")
        let decodedLevels: [UInt32]? = polyline.levels
        
        XCTAssertEqual(2, decodedLevels!.count)
    }
    
    func testPrecision() {
        // OSRM uses a 6 digit precision
        let _ = Polyline(encodedPolyline: "ak{hRak{hR", precision: 1e6)
    }
    
    #if canImport(MapKit)
    @available(tvOS 9.2, *)
    func testPolylineConvertionToMKPolyline() {
        let polyline = Polyline(encodedPolyline: "qkqtFbn_Vui`Xu`l]")
        
        let mkPolyline = polyline.mkPolyline
        XCTAssertNotNil(mkPolyline)
        XCTAssertTrue(polyline.coordinates?.count == mkPolyline?.pointCount)
    }
    #endif

    #if canImport(MapKit)
    @available(tvOS 9.2, *)
    func testPolylineConvertionToMKPolylineWhenEncodingFailed() {
        let polyline = Polyline(encodedPolyline: "invalidPolylineString")
        let mkPolyline = polyline.mkPolyline
        XCTAssertNil(mkPolyline)
    }
    #endif
    
    #if canImport(MapKit)
    @available(tvOS 9.2, *)
    func testEmptyPolylineConvertionShouldBeEmptyMKPolyline() {
        let polyline = Polyline(encodedPolyline: "")
        let mkPolyline = polyline.mkPolyline
        XCTAssertTrue(mkPolyline?.pointCount == 0)
    }
    #endif
}
