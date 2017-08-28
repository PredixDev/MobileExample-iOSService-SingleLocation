//
//  LocationServiceTests.swift
//  PredixMobileReferenceApp
//
//  Created by Henderson, Jonathan (GE Global Research) on 2/3/16.
//  Copyright © 2016 GE. All rights reserved.
//

import XCTest
@testable import PredixMobileiOS
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
            return CLAuthorizationStatus.authorizedWhenInUse
        }
        locationManagerAuthorized.authorizationStatusWithStatus = { (status) -> (CLAuthorizationStatus) in
            return CLAuthorizationStatus.authorizedWhenInUse
        }
        locationManagerAuthorized.startUpdatingLocation = { (manager) -> Void in
            let location = CLLocation(latitude: 1.2, longitude: 2.0)
            self.locationManagerAuthorized._locationCompletion!(.success(location))
        }

        // UNAUTHORIZED
        locationManagerUnauthorized = SingleLocationManager()
        locationManagerUnauthorized.authorizationStatus = {
            return CLAuthorizationStatus.denied
        }
        locationManagerUnauthorized.authorizationStatusWithStatus = { (status) -> (CLAuthorizationStatus) in
            return CLAuthorizationStatus.denied
        }

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLocationUtilityAuthorized() {
        let testExpectation = self.expectation(description: "We expect the location completion block to run.")
        self.locationManagerAuthorized.fetchLocationWithCompletion({ (locationType) -> Void in
            switch locationType {
                case .success(let location):
                    print(location)
                case .error:
                    XCTAssertTrue(false, "Expected a location, but received an ERROR")
            }

            testExpectation.fulfill()
        })
        // Wait so that we have time to click Allow or Deny for location services in the simulator.  If it takes longer than 20 seconds to do this, then this will fail.  However, if it takes you longer than 20 seconds to click a button, you should start some sort of agility training.
        self.waitForExpectations(timeout: 20, handler: nil)
    }

    func testLocationUtilityUnauthorized() {
        let testExpectation = self.expectation(description: "We expect the location completion block to run.")
        self.locationManagerUnauthorized.fetchLocationWithCompletion({ (locationType) -> Void in
            switch locationType {
            case .success:
                XCTAssertTrue(false, "Expected an ERROR but got a location, small victories?")
            case .error(let errorType):
                switch errorType {
                case .error(let message):
                    print("Location Error: \(message)")
                }
            }

            testExpectation.fulfill()
        })
        // Wait so that we have time to click Allow or Deny for location services in the simulator.  If it takes longer than 20 seconds to do this, then this will fail.  However, if it takes you longer than 20 seconds to click a button, you should start some sort of agility training.
        self.waitForExpectations(timeout: 20, handler: nil)
    }

    func testLocationSuccess() {
        print("🎏🎏🎏")
        // As service calls are asyncronous this entire interaction is wrapped in an XCTest expectation, and the timeout for expectations is 20 seconds.
        // You can create new expectations and fulfill them in the testResponse and/or testData blocks.
        // let's create an expectation, that we'll fulfill in the data block when we examine the return data. This will ensure our call actually does return data.
        let dataExpectation = self.expectation(description: "\(#function): testData closure called expectation.")

        // Calls our location service
        print("Calls our location service")
        self.serviceTester(LocationService.self, path: "http://pmapi/location/single", expectedStatusCode: Http.StatusCode.ok, testResponse: nil) { (data) in

            print("💥💥💥")

            do {
                guard let locationResponseDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] else {

                    XCTAssertTrue(false, "locationResponseDictionary was not the expected type: \(data)")
                    return
                }

                print(locationResponseDictionary)

                guard let locationResponseStatus = Status.init(rawValue: (locationResponseDictionary["status"] as? String) ?? "")  else {
                    XCTAssertTrue(false, "Status key with string value was not found in response data.")
                    return

                }
                switch locationResponseStatus {
                case .Success:
                    print (locationResponseDictionary["latitude"] ?? "nil")
                    print (locationResponseDictionary["longitude"] ?? "nil")
                    XCTAssertNotNil(locationResponseDictionary["latitude"] as? String, "Latitude key with string value was not found in response data.")
                    XCTAssertNotNil(locationResponseDictionary["longitude"] as? String, "Longitude key with string value was not found in response data.")
                case .Error:
                    print (locationResponseDictionary["message"] ?? "nil")
                    XCTAssertNotNil(locationResponseDictionary["message"] as? String, "Message key with string value was not found in response data")
                }
            } catch let error {
                XCTAssertTrue(false, "JSON deserialization of the returned data failed: \(error)")
            }

            // fulfill our expectation.
            dataExpectation.fulfill()
        }
    }

    func testAddressSuccess() {

        let dataExpectation = self.expectation(description: "\(#function): testData closure called expectation.")

        //Calls the location service with the coordinate parameters
        self.serviceTester(LocationService.self, path: "http://pmapi/location/address?latitude=38.8977&longitude=-77.0366", expectedStatusCode: Http.StatusCode.ok, testResponse: nil) { (data) in

            do {
                guard let addressResponseDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] else {

                    XCTAssertTrue(false, "locationResponseDictionary was not the expected type: \(data)")
                    return
                }

                print(addressResponseDictionary)
                /*
                guard let locationResponseStatus = Status.init(rawValue: (addressResponseDictionary["status"] as? String) ?? "")  else
                {
                    XCTAssertTrue(false, "Status key with string value was not found in response data.")
                    return
                    
                }
                switch locationResponseStatus {
                case .Success:
                    print (addressResponseDictionary["latitude"])
                    print (addressResponseDictionary["longitude"])
                    XCTAssertNotNil(addressResponseDictionary["latitude"] as? String, "Latitude key with string value was not found in response data.")
                    XCTAssertNotNil(addressResponseDictionary["longitude"] as? String, "Longitude key with string value was not found in response data.")
                case .Error:
                    print (addressResponseDictionary["message"])
                    XCTAssertNotNil(addressResponseDictionary["message"] as? String, "Message key with string value was not found in response data")
                }
                */
            } catch let error {
                XCTAssertTrue(false, "JSON deserialization of the returned data failed: \(error)")
            }

            //fulfill our expectation
            dataExpectation.fulfill()
        }
    }

    func testLocationUnacceptedMethod() {
        // Our request url string
        let path = "\(Http.scheme)://\(PredixMobilityConfiguration.apiHostname)/location/single"

        // create a mutable request:
        var request = URLRequest(url: URL(string: path)!)

        // change the HTTPMethod to POST
        request.httpMethod = "POST"

        // now we run the service tester. Since we're expecting an error, and our service only returns data when there are no errors, we
        // don't need a testData block. But, we will include a testResponse block to ensure our headers are being added properly.
        self.serviceTester(LocationService.self, request: request, expectedStatusCode: .methodNotAllowed, testResponse: { (response: URLResponse) -> Void in

            // we need to cast the reponse. We could be more defensive here by optionally casting and doing an XCTAssert if it failed...

            let httpResponse = response as! HTTPURLResponse

            // now check that our expected "Allow" header is there, and is the value we expect.
            XCTAssertEqual(httpResponse.allHeaderFields["Allow"] as? String, "GET", "Allow header was not as expected")

            }, testData: nil)
    }

    func testGetAddressFromLocationCoordinates() {
        let dataExpectation = self.expectation(description: "\(#function): testData closure called expectation.")

        GetReverseGeocode.getAddressPropertiesForLocationCoordinates(38.8977, longitude: -77.0366) { (addressType) in

            switch addressType {
            case .success(let addressInformation):
                print(addressInformation)
                break
            case .error(let message):
                XCTAssertTrue(false, "Received error when expecting address information. \(message)")
            }

            dataExpectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
