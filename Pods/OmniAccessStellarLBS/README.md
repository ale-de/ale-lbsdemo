#OmniAccessStellarLBS for iOS - Integration Guide
[![Version](https://img.shields.io/cocoapods/v/OmniacessStellarLBS.svg?style=flat)](http://cocoapods.org/pods/OmniAccessStellarLBS)
[![License](https://img.shields.io/cocoapods/l/OmniacessStellarLBS.svg?style=flat)](http://cocoapods.org/pods/OmniAccessStellarLBS)
[![Platform](https://img.shields.io/cocoapods/p/OmniacessStellarLBS.svg?style=flat)](http://cocoapods.org/pods/OmniAccessStellarLBS)

This page describes how to integrate OmniAccessStellarLBS into your application using CocoaPods

### Requirements
* Xcode 8 or higher
* iOS 9.0 or higher
* [CocoaPods](http://cocoapods.org/) package manager:

# Building demo application
To run the provided sample project (NAODemoApplication), clone or download this repo, and run:
```bash
$ cd Example
$ pod install
$ open NAODemoApplication.xcworkspace

```

#Install

```
#!bash

$ sudo gem install cocoapods

```

##Get Started

### 1- pod init

Creates a Podfile for the current directory if none currently exists. If an XCODEPROJ project file is specified or if there is only a single project file in the current directory, targets will be automatically generated based on targets defined in the project.

```
#!bash

$ pod init

```


### 2- Update Podfile

List the dependencies in Podfile in your Xcode project directory:

```
#!bash

target 'MyApp' do

pod 'OmniAccessStellarLBS'

end

```

### 3- pod install

Now you can install the dependencies in your project:

```
#!bash

$ pod install

```

Make sure to always open the Xcode workspace instead of the project file when building your project:

```
#!bash

$ open App.xcworkspace

```

Then, [configure your Xcode project](http://docs.omniaccess-stellar-lbs.com/index.php/docs/nao-sdk/ios-sdk/configure-your-xcode-project/).
