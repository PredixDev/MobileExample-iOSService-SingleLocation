## Predix Mobile iOS Service Example

This repo contains a Predix Mobile iOS service example,  demonstrating a simple native service implementation.

### Step 0 - Prerequisites

It is assumed you already have a Predix Mobile cloud services installation, have installed the Predix Mobile command line tool, and have installed a Predix Mobile iOS Container, following the Getting Started examples for those repos.

It is also assumed you have a basic knowledge of mobile iOS development using XCode and Swift.

### Step 1 - Integrate the example code

Here you will add the _VendorIDService.swift_, and _VendorIDServiceTests.swift_ files from this repo to your container project.

Open your Predix Mobile container app project. In the Project Manager in left-hand pane, expand the PredixMobileReferenceApp project, then expand the PredixMobileReferenceApp group. Within that group, expand the Classes group. In this group, create a group called "Services". 

Add the file _VendorIDService.swift_ to this group, either by dragging from Finder, or by using the Add Files dialog in XCode. When doing this, ensure the _VendorIDService.swift_ file is copied to your project, and added to your PredixMobileReferenceApp target.

Likewise, add a "Services" group to your PredixMobileReferenceAppTests group. Add the _VendorIDServiceTests.swift_ file to this group, ensuring that you copy the file, and add it to the PredixMobileReferenceAppTests unit testing target.

### Step 2 - Register your new service

The _VendorIDService.swift_ file contains all the code needed for our example service, however we still need to register our service in the container in order for it to be available to our webapp. In order to do this, we will add a line of code to our AppDelegate.

In the _AppDelegate.swift_ file, navigate to the _application: didFinishLaunchingWithOptions:_ method. In this method, you will see a line that looks like this:

    PredixMobilityConfiguration.loadConfiguration()

Directly after that line, add the following:

    PredixMobilityConfiguration.additionalBootServicesToRegister = [VendorIDService.self]

This will inform the iOS Predix Mobile SDK framework to load your new service when the app starts, thus making it available to your webapp.

#### Step 3 - Review the code

The Swift files you added to your container are heavily documented. Read through these for a full understanding of how they work, and what they are doing.

In brief - they take you through creating an implemenation of the ServiceProtocol protoccol, handling requests to the service with this protocol, and returning data or error status codes to callers.

#### Step 4 - Run the unit tests.

Unit tests are a key component in all software development. In a services-based architecture like Predix Mobile,
they are critical to ensure the services are working properly, and changes do not negatively impact
consumers of the service.

Review and run the unit tests that you added to the project.

#### Step 5 - Call the service from a webapp

Your new iOS client service is exposed through the service identifier "vendorid". So calling _http://pmapi/vendorid_ from a webapp will call this service.

A simple demo webapp is provided in the demo-webapp directory in the git repo.
