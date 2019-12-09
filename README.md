# EasyNetRequest

[![CI Status](https://img.shields.io/travis/m-kinesis/EasyNetRequest.svg?style=flat)](https://travis-ci.org/osmely/EasyNetRequest)
[![Version](https://img.shields.io/cocoapods/v/EasyNetRequest.svg?style=flat)](https://cocoapods.org/pods/EasyNetRequest)
[![License](https://img.shields.io/cocoapods/l/EasyNetRequest.svg?style=flat)](https://cocoapods.org/pods/EasyNetRequest)
[![Platform](https://img.shields.io/cocoapods/p/EasyNetRequest.svg?style=flat)](https://cocoapods.org/pods/EasyNetRequest)


## Installation

EasyNetRequest esta disponible mediante [CocoaPods](https://cocoapods.org). Para instalarlo agrege esta linea
en su Podfile:

```ruby
pod 'EasyNetRequest'
```

## Como usarlo?

```swift
struct User: Codable {
    let id: Int
    let username: String
}

struct GetAllUsers: EasyNetRequest {
    typealias EasyNetResponseType = [User]
    
    var data: EasyNetRequestData {
        return EasyNetRequestData(path: "https://jsonplaceholder.typicode.com/users", method: .GET)
    }
    
    var validators: [EasyNetResponseValidator]? { nil }
}

if let users = try? result.get() {
            
}
```

## Author

Osmely Fernandez <osmelyf@gmail.com> 


## License

EasyNetRequest is available under the MIT license. See the LICENSE file for more info.
