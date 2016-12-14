//
//  AddressUtility.swift
//  PredixMobileReferenceApp
//
//  Created by Henderson, Jonathan (GE Global Research) on 2/16/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Foundation
import CoreLocation

//protocol GetReverseGeocodeProtocol {
//
//}

/**
    To see what the values for a placemark represent, see Apple's documentation:

    https://developer.apple.com/library/prerelease/ios/documentation/CoreLocation/Reference/CLPlacemark_class/index.html
*/
extension CLPlacemark {
    func getSerializeableDictionary() -> [String: String] {
        var placemarkDictionary = [String: String]()
        
        func addEntryIfNotNil(_ key: String, value: String?) {
            guard let _value = value else {
                return
            }
            placemarkDictionary[key] = _value
        }
        
        addEntryIfNotNil("name", value: self.name)
        addEntryIfNotNil("countryCode", value: self.isoCountryCode)
        addEntryIfNotNil("country", value: self.country)
        addEntryIfNotNil("postalCode", value: self.postalCode)
        addEntryIfNotNil("adminstrativeArea", value: self.administrativeArea)
        addEntryIfNotNil("subAdministrativeArea", value: self.subAdministrativeArea)
        addEntryIfNotNil("locality", value: self.locality)
        addEntryIfNotNil("subLocality", value: self.subLocality)
        addEntryIfNotNil("thoroughfare", value: self.thoroughfare)
        addEntryIfNotNil("subThoroughfare", value: self.subThoroughfare)
        addEntryIfNotNil("inlandWater", value: self.inlandWater)
        addEntryIfNotNil("ocean", value: self.ocean)
        
        return placemarkDictionary
    }
}


struct AddressInformation {
    let countryCode: String?
    let country: String?
    let postalCode: String?
    let state: String?
    let city: String?
    let street: String?
    let streetNumber: String?
    
    var serializableDictionary: [String: String] {
        return [
            "countryCode": countryCode ?? "",
            "country": country ?? "",
            "postalCode": postalCode ?? "",
            "state": state ?? "",
            "city": city ?? "",
            "street": street ?? "",
            "streetNumber": streetNumber ?? "",
        ]
    }
}

enum AddressInformationReturn {
    case success([String: String])
    case error(String)
}


class GetReverseGeocode {
    
    static func getAddressPropertiesForLocationCoordinates(_ latitude: Double, longitude: Double, completion: @escaping (AddressInformationReturn)->()) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if let errorUnwrapped = error {
                completion(AddressInformationReturn.error("Reverse geocoder failed with error: \(errorUnwrapped.localizedDescription)"))
                return
            }
            guard let placemark = placemarks?[0] else {
                completion(AddressInformationReturn.error("No data received from reverse geocoder."))
                return
            }
            
            completion(AddressInformationReturn.success(placemark.getSerializeableDictionary()))
        }
    }
}
