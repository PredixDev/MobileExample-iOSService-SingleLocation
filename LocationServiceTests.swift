//
//  LocationServiceTests.swift
//  PredixMobileReferenceApp
//
//  Created by Henderson, Jonathan (GE Global Research) on 2/3/16.
//  Copyright © 2016 GE. All rights reserved.
//

import XCTest
@testable import PredixMobileReferenceApp
import PredixMobileSDK
import CoreLocation

enum Status: String {
    case Success = "success"
    case Error = "error"
}

class LocationServiceTests: XCTestCase {
    
    var locationManagerAuthorized: SingleLocationManager!
    
    var locationManagerUnauthorized: SingleLocationManager!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // AUTHORIZED
        locationManagerAuthorized = SingleLocationManager()
        locationManagerAuthorized.authorizationStatus = {
            return CLAuthorizationStatus.AuthorizedWhenInUse
        }
        locationManagerAuthorized.authorizationStatusWithStatus = { (status) -> (CLAuthorizationStatus) in
            return CLAuthorizationStatus.AuthorizedWhenInUse
        }
        locationManagerAuthorized.startUpdatingLocation = { (manager)->() in
            let location = CLLocation(latitude: 1.2,longitude: 2.0)
            self.locationManagerAuthorized._locationCompletion!(.Success(location))
        }
        
        // UNAUTHORIZED
        locationManagerUnauthorized = SingleLocationManager()
        locationManagerUnauthorized.authorizationStatus = {
            return CLAuthorizationStatus.Denied
        }
        locationManagerUnauthorized.authorizationStatusWithStatus = { (status) -> (CLAuthorizationStatus) in
            return CLAuthorizationStatus.Denied
        }
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationUtilityAuthorized() {
        let testExpectation = self.expectationWithDescription("We expect the location completion block to run.")
        self.locationManagerAuthorized.fetchLocationWithCompletion({ (locationType) -> () in
            switch locationType {
                case .Success(let location):
                    print(location)
                case .Error:
                    XCTAssertTrue(false, "Expected a location, but received an ERROR")
            }
            
            testExpectation.fulfill()
        })
        // Wait so that we have time to click Allow or Deny for location services in the simulator.  If it takes longer than 20 seconds to do this, then this will fail.  However, if it takes you longer than 20 seconds to click a button, you should start some sort of agility training.
        self.waitForExpectationsWithTimeout(20, handler: nil)
    }
    
    
    func testLocationUtilityUnauthorized() {
        let testExpectation = self.expectationWithDescription("We expect the location completion block to run.")
        self.locationManagerUnauthorized.fetchLocationWithCompletion({ (locationType) -> () in
            switch locationType {
            case .Success:
                XCTAssertTrue(false, "Expected an ERROR but got a location, small victories?")
            case .Error(let errorType):
                switch errorType {
                case .Error(let message):
                    print("Location Error: \(message)")
                }
            }
            
            testExpectation.fulfill()
        })
        // Wait so that we have time to click Allow or Deny for location services in the simulator.  If it takes longer than 20 seconds to do this, then this will fail.  However, if it takes you longer than 20 seconds to click a button, you should start some sort of agility training.
        self.waitForExpectationsWithTimeout(20, handler: nil)
    }
    
    
    func testLocationSuccess() {
        print("🎏🎏🎏")
        // As service calls are asyncronous this entire interaction is wrapped in an XCTest expectation, and the timeout for expectations is 20 seconds.
        // You can create new expectations and fulfill them in the testResponse and/or testData blocks.
        // let's create an expectation, that we'll fulfill in the data block when we examine the return data. This will ensure our call actually does return data.
        let dataExpectation = self.expectationWithDescription("\(__FUNCTION__): testData closure called expectation.")
        
        // Calls our location service
        print("Calls our location service")
        self.serviceTester(SingleLocationService.self, path: "http://pmapi/singlelocation", expectedStatusCode: HTTPStatusCode.OK, testResponse: nil) { (data) in
            
            print("💥💥💥")
            
            do {
                guard let locationResponseDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] else {
                    
                    XCTAssertTrue(false, "locationResponseDictionary was not the expected type: \(data)")
                    return
                }
                
                print(locationResponseDictionary)
                
                guard let locationResponseStatus = Status.init(rawValue: (locationResponseDictionary["status"] as? String) ?? "")  else
                {
                    XCTAssertTrue(false, "Status key with string value was not found in response data.")
                    return
                    
                }
                switch locationResponseStatus {
                case .Success:
                    print (locationResponseDictionary["latitude"])
                    print (locationResponseDictionary["longitude"])
                    XCTAssertNotNil(locationResponseDictionary["latitude"] as? String, "Latitude key with string value was not found in response data.")
                    XCTAssertNotNil(locationResponseDictionary["longitude"] as? String, "Longitude key with string value was not found in response data.")
                case .Error:
                    print (locationResponseDictionary["message"])
                    XCTAssertNotNil(locationResponseDictionary["message"] as? String, "Message key with string value was not found in response data")
                }
            } catch let error {
                XCTAssertTrue(false, "JSON deserialization of the returned data failed: \(error)")
            }
            
            // fulfill our expectation.
            dataExpectation.fulfill()
        }
    }
    
    func testLocationUnacceptedMethod() {
        // Our request url string
        let path = "\(API_SCHEME)://\(PredixMobilityConfiguration.API_HOST)/singlelocation"
        
        // create a mutable request:
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        // change the HTTPMethod to POST
        request.HTTPMethod = "POST"
        
        // now we run the service tester. Since we're expecting an error, and our service only returns data when there are no errors, we
        // don't need a testData block. But, we will include a testResponse block to ensure our headers are being added properly.
        self.serviceTester(SingleLocationService.self, request: request, expectedStatusCode: .MethodNotAllowed, testResponse: { (response: NSURLResponse) -> Void in
            
            // we need to cast the reponse. We could be more defensive here by optionally casting and doing an XCTAssert if it failed...
            
            let httpResponse = response as! NSHTTPURLResponse
            
            // now check that our expected "Allow" header is there, and is the value we expect.
            XCTAssertEqual(httpResponse.allHeaderFields["Allow"] as? String, "GET", "Allow header was not as expected")
            
            }, testData: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
