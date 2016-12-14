//
//  LocationUtility.swift
//  PredixMobileReferenceApp
//
//  Created by Henderson, Jonathan (GE Global Research) and Matt Hoffman on 2/3/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Foundation
import CoreLocation

/**
 Type to be returned from fetching a location from the SingleLocationProtocol
*/
enum SingleLocationReturn {
    case success(CLLocation)
    case error(SingleLocationError)
}

/**
 Error cases from SingleLocation functionality
*/
enum SingleLocationError {
    case error(String)
}


protocol SingleLocationProtocol {
    
    func fetchLocationWithCompletion(_ completion: @escaping (SingleLocationReturn)->())
    
}


/* // EXAMPLE
class ClassThatNeedsLocation {
    
    var manager: SingleLocationProtocol!
    
    func getLocation() {
        manager = SingleLocationManager()

        manager.fetchLocationWithCompletion { (locationType) -> () in
            switch locationType {
            case .Success(let location):
                // SUCCESS
                print(location)
            case .Error(let errorType):
                switch errorType {
                case .Error(let message):
                    // ERROR
                    print("ERROR: \(message)")
                }
            }
        }
    }
}
*/

class SingleLocationManager: NSObject, SingleLocationProtocol, CLLocationManagerDelegate {
    
    fileprivate var locationManager: CLLocationManager?
    
    // Expose for testing
    internal var _locationCompletion: ((SingleLocationReturn)->())?
    
    // This allows us to mock Apple's functionality that shows the pop-up when location is
    var authorizationStatus: ()->(CLAuthorizationStatus) = {
        return CLLocationManager.authorizationStatus()
    }
    var authorizationStatusWithStatus: (CLAuthorizationStatus?)->(CLAuthorizationStatus) = { (status) -> (CLAuthorizationStatus) in 
        return status!
    }

    var startUpdatingLocation: (CLLocationManager?)->() = { (manager)->() in
        manager!.startUpdatingLocation()
    }
    
    
    //destroy the manager
    deinit {
        print("🌋 deinitializing...")
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    /**
     Wrapper around fetchLocationWithCompletion so that we can handle the fact that an instance of SingleLocationManager needs to stay around in memory until the time when we actually receive a location.  To do this, we pass the instance of SingleLocationManager into the completion closure so that it has something referencing it until the time the closure is run.  After we get the location, we remove the reference by setting _locationCompletion to nil in the locationReceived method.
    */
    static func fetchSingleLocation(_ completion: @escaping (SingleLocationReturn) -> ()) {
        // Instantiate a new SingleLocationManager
        let locationManager = SingleLocationManager()
        // Call the normal location fetching method
        locationManager.fetchLocationWithCompletion { (locationType) -> () in
            // Store a reference to our location manager
            _ = locationManager
            // Call the closure that the user of this method passed through
            completion(locationType)
        }
    }
    
    /**
     Wrapper around locationCompletion.  Handles the fact that we only want to get the location once, and not a continous stream of locations.
    */
    fileprivate func locationReceived(_ location: SingleLocationReturn){
        locationManager?.stopUpdatingLocation()
        _locationCompletion?(location)
        locationManager?.delegate = nil
        locationManager = nil
        // This will prevent memory leaks because we need access to ourself in _locationCompletion so that our object doesn't disappear
        _locationCompletion = nil
    }
    
    /**
     Location fetching method to be called when we have an instance of SingleLocationManager.  When using this method, ensure that you retain the instance of SingleLocationManager until we receive a location from CLLocationManager and call _locationCompletion; otherwise, we'll lose the reference to the instance, and the completion closure will never be run, because we will have never received a location.
    */
    func fetchLocationWithCompletion(_ completion: @escaping (SingleLocationReturn) -> ()) {
        //store the completion closure
        _locationCompletion = completion
        
        //fire the location manager
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        // Check if the user has not been prompted for location yet
        if self.authorizationStatus() == .notDetermined {
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    //location authorization status changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        // Check the status of location authorization of the user
        switch authorizationStatusWithStatus(status) {
        case .authorizedWhenInUse, .authorizedAlways:
            print("🍎🍎 It says we're authorized")
            self.startUpdatingLocation(manager)
        case .denied, .restricted:
            locationReceived(SingleLocationReturn.error(SingleLocationError.error("Location services are not enabled, allow location use in the settings of this app in order to use location services.")))
        default:
            print("🎁")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("🐣🐣🐣 Location Received")
        let location = locations[0]
        locationReceived(.success(location))
    }
    
}
