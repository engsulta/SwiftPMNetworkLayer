# Getting started with AHNetwork Layer

## Summary
In this document, we will learn how to use the AHNetwork Layer, the AHNetwork Layer is a key part of the Foundation module, it is a Swift-based HTTP networking library for iOS, in this guide we will look at how to build and execute a complete network request.

## Getting started with AHNetworkLayer
To get started, you will need to have the AHFoundation pod installed in your workspace by adding the following line to your podfile and running the pod install command.

```
pod 'AHFoundation'
```
## Supported Platform 

 .iOS(.v11) and later
 
## Usage

### 1- Import AHFoundation Module in your file

```
import AHFoundation 
```
### 2- Create a concrete implementation of AHRequestProtocol

The first thing that you need is to define your endpoint request and conform to AHRequestProtocol. This protocol will contain all the information to configure your request.

What is an EndPoint? Well, essentially it is a URLRequest with all its comprising components such as path, HTTP method, headers, query parameters, and body parameters. The EndPointType protocol is the cornerstone of our AHNetwork layers implementation.

Here is the protocol that you need to conform to:

```swift
public protocol AHRequestProtocol {
    /// The relative Endpoint path added to baseUrl
    var path: String {get}
    /// The HTTP request method
    var httpMethod: HTTPMethod {get}
    /// Http task create encoded data sent as the message body of a request, such as for an HTTP POST request or
    /// inline in case of HTTP GET request (default: .request)
    var httpTask: HTTPTask {get}
    /// A dictionary containing all the request’s HTTP header fields related to such endPoint(default: nil)
    var headers: HTTPHeaders? {get}
    /// authentication Flag if exist in protocol network client may ask auth layer to provide new auth token
    var isAuthenticationNeededRequest: Bool? {get}
    ///The constants enum used to specify interaction with the cached responses.
    /** Specifies that the caching logic defined in the protocol implementation, if any, is
     used for a particular URL load request. This is the default policy
     for URL load requests.*/
    var cachePolicy: CachePolicy { get }
}
```
    
Go ahead and create your request by conforming the protocol: 

```swift
public struct AHRequestTest: AHRequestProtocol {
    }
}
```

> Follow this step by configuring the parameters to get your AHRequestTest able to be executed 

### Here are the steps to configure the AHRequestTest: 

 ![width=100%](AHFoundation/Images/AHNetworkLayer/path.png)
 

### Set your path:
```swift

public struct AHRequestTest: AHRequestProtocol {
   public var path: String { return "/posts" }
}
```

### Configure HTTPMethod: 
This enum will be used to set the HTTP method of our request.    
 
```swift
public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
    case options = "OPTIONS"
}
```     
Now, you can set your http method in the your request.

```swift
public struct AHRequestTest: AHRequestProtocol {
   var path: { return "/posts"}
   public var httpMethod: HTTPMethod { return .get }
}
```

### HTTPHeaders
HTTPHeaders is simply just a typealias for a dictionary. You can create this typealias at the top of your HTTPTask file.

```public typealias HTTPHeaders = [String: String]```
Now, you can set your HTTP request headers in your request  

```swift
public struct AHRequestTest: AHRequestProtocol {
   public var path: String { return "/posts" }
   public var httpMethod: HTTPMethod { return .get }
   var headers : { return [:] }
}
```

### HTTPTask:
HTTPTask is responsible for configuring parameters for a specific endPoint request. You can add as many cases as are applicable to your Network Layers requirements. 

- `.request`: If there is no parameters. 
- `.requestParameters`: If you have body and/or url parameters.
- `.requestParametersAndHeaders`: If you have extra headers.

```swift
public enum HTTPTask {
    case request
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: AHParameterEncoder,
        urlParameters: Parameters?)
    case requestParametersAndHeaders(bodyParameters: Parameters?, bodyEncoding: AHParameterEncoder,
        urlParameters: Parameters?,
        extraHeaders: HTTPHeaders?)
}
```
        
Now, you can set your httpTask variable in your request.

```swift
public struct AHRequestTest: AHRequestProtocol {
   public var path: String { return "/posts" }
   public var httpMethod: HTTPMethod { return .get }
   public var headers: HTTPHeaders? { return [:] }
   var httpTask: { return .request }
}
```

For more understanding of how to choose the httpTask read  Parameters & Encoding below.

### Parameters & Encoding

while selecting your httpTask you will find yourself needing to select AHParametersEncoder in case that will be responsible for encoding your parameters depending on the Parameters type.

**Parameters is a typealias**
typealias to make our code cleaner and more concise.
```public typealias Parameters = [String: Any]```

**AHParameterEncoder** is an enum inside the Encoding group uses a protocol ParameterEncoderProtocol with one static function **encode**. 
 
```swift
public protocol ParameterEncodingProtocol {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}
```

The encode method takes two parameters an inout URLRequest and Parameters. Usually, variables are passed to functions as value types.

The ParameterEncoderProtocol will be implemented by our **JSONParameterEncoder** and **URLPameterEncoder**.

A AHParameterEncoder performs one function **encode** which is to encode parameters. This method can fail so it throws custom errors and we need to handle it.

Now, if you have request parameters you can replace httTask in your request with this:
    

```swift
public struct AHRequestTest: AHRequestProtocol {
   public var path: String { return "/posts" }
   public var httpMethod: HTTPMethod { return .get }
   public var headers: HTTPHeaders? { return [:] }
   public var httpTask: HTTPTask { return .requestParameters(
                                       bodyParameters: nil,
                                       bodyEncoding: .urlEncoding,
                                       urlParameters: ["userId": "1"]) }
                                       
}
```
Note if your request doesn't need an authentication token you should ensure to set 

```
isAuthenticationNeededRequest = false
```

You can also set the cash policy with your preferred one for this request  

```swift
public struct AHRequestTest: AHRequestProtocol {
   public var path: String { return "/posts" }
   public var httpMethod: HTTPMethod { return .get }
   public var headers: HTTPHeaders? { return [:] }
   public var httpTask: HTTPTask { return .requestParameters(
                                       bodyParameters: nil,
                                       bodyEncoding: .urlEncoding,
                                       urlParameters: ["userId": "1"]) }
   public var isAuthenticationNeededRequest: Bool? = false
   public var cachePolicy: CachePolicy = .reloadIgnoringLocalCacheData
}

```
Now you completed building your AHRequestTest. Let's go to the Next Step
    
> Note you can also use the AHRequest struct already implemented from AHRequestProtocol and keep the default values, or change it depends on you business logic.

```swift
let inlineRequest = AHRequest(path: "/posts",
                                httpMethod: .get,
                                httpTask: .requestParameters(
                                       bodyParameters: nil,
                                       bodyEncoding: .urlEncoding,
                                       urlParameters: ["userId": "1"]),
                                headers: nil,
                                isAuthenticationNeededRequest: true,
                                cachePolicy: .reloadIgnoringLocalCacheData)                            
```

### 3- Use AHNetworkClient to execute AHRequestProtocol

**AHNetworkClient** is the main class inside the AHNetworkClient group that conforms to a protocol AHNetworkClientProtocol. 

```swift
public typealias AHNetworkCompletion = ( Codable?, Error? ) -> Void
public typealias AHNetworkProgressClosure = ((Double) -> Void)?
public typealias AHNetworkDownloadClosure = ( URL?, URLResponse?, Error? ) -> Void

public protocol AHNetworkClientProtocol {
    /// The URL of the EndPoint at the server.
    var baseUrl: String { get }
    /// A dictionary containing all the Client Related HTTP header fields (default: nil)
    var headers: [String: String]? { get }
     /// The session used during HTTP request (default: URLSession.shared)
    var session: URLSessionProtocol { get }
    /// the authClientProvider module may be injected
    var authClientProvider: AuthTokenProvider? { get set }
    /// The HTTP request timeout.
    var timeout: TimeInterval { get }
    ///start network execution to start http request
    func execute<T: Codable>(request: AHRequestProtocol,
                             model: T.Type,
                             progressClosure: AHNetworkProgressClosure?,
                             completion: @escaping AHNetworkCompletion)
    func upload<T: Codable, U: Codable>(request: AHRequestProtocol,
                                        responseModel: T.Type,
                                        uploadModel: U,
                                        completion: @escaping AHNetworkCompletion)
    func download(url: String,
                  progressClosure: AHNetworkProgressClosure?,
                  completion: @escaping AHNetworkDownloadClosure)
    func cancel(request: AHRequestProtocol, completion: @escaping () -> Void)
}
```

This protocol will contain all the information to configure your network client base URL, headers related to the client, timeout, and session you have noticed that this configuration is shared per same network client.


All that you need to create is an instance of **AHNetworkClient** to start executing your request.

```
let myNetworkClient = AHNetworkClient(baseURL: "https://jsonplaceholder.typicode.com", session: session)
```

or 

```swift
let myNetworkClient = AHNetworkClient(baseURL: "https://jsonplaceholder.typicode.com") 
```

In this case use **URLSession.shared**

It is your responsibility to create a URL session with any URL session configuration you want, and create a client base URL that will vary with the server you communicate with. You can have different clients with different base URLs.

Now, you can easily use the pre-implemented functions **execute**, **cancel**, **upload** for free. They contain all the needed implementation you need to convert your request to URL request and give you the ability to cancel running requests. Also, we provide an upload feature.

 **Now we can start fetching the user posts data:** 
 
 If we need to consume the user posts JSON file through the network 
 we should create codable user posts object that will represent user posts API JSON response
 you can check response here https://jsonplaceholder.typicode.com/posts?userId=1
  
 ```json
 [
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  }
 ]
 ```
 
Now, create codable user posts struct 
 
```swift
struct UserPosts : Codable {
    let body : String?
    let id : Int?
    let title : String?
    let userId : Int?
}
```

Fetch the response at your call side:

```swift
func sampleExecuteDataTask() {
    myNetworkClient.execute(request: AHRequestTest(), model: user [UserPosts].self) { model, error in
        if error != nil {
            //  switch on error and handle each case 
        } else {
            // you have your model as Codable model object cast to your type and easily use it
            if let model = model as? [UserPosts] {
            print(model[0].title)
            }
        }
     }
}

```

output:

```
sunt aut facere repellat provident occaecati excepturi optio reprehenderit
```
 
 **How to download file task:** 
 
 You can use AHNetworkLayer for Downloading file with any extension. Here is an example to download audioFile just pass the file URL to download method in AHNetworkClient
 
 ```swift
 let fileURL = "https://audio-ssl.itunes.apple.com/itunes-assets/Music6/v4/68/34/f1/6834f1f8-8fdb-4247-492a-c0caea580082/mzaf_3920281300599106672.plus.aac.p.m4a"

func testDownloadFile() {
    let client = AHNetworkClient(baseURL: "", session: URLSession.shared)
    client.download(url: fileURL) { location, response, error in
        // you can access the location throw file manager for demo perpos we will just print it
            print(location ?? "")
     }
}
 ```
 
 
 **How to upload file task:** 
 
You can use AHNetworkLayer for uploading tasks. Here is an example to upload an object called "MockModel of type Encodable" just pass the file model to upload method through AHNetworkClient
you can try it 

 ```swift

func testUploadFile() {
    let exp = expectation(description: #function)
    mockClient = AHNetworkClient(baseURL: "https://www.test.com", session: session)
    let request = AHRequest(path: "/uploaded", httpMethod: .post, isAuthenticationNeededRequest: false)
    mockClient.upload(request: request, responseModel: [String].self, uploadModel: MockModel()) { responseModel, error in
        XCTAssertNotNil(responseModel)
        exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
 }

 ```
What if you want to upload non encodable object then you supposed to convert it manually to encodable 

I will see you here as an example to upload UIImage which is not encodable by default.


```swift

extension UIImage: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let data = self.jpegData(compressionQuality: 1.0) else { return }
        try container.encode(data)
    }
}
```


 ```swift
 func testUploadImage() {
     let exp = expectation(description: #function)
     let bundle = Bundle.unitTest
     let image = UIImage(named: "cloud", in: bundle, compatibleWith: nil) ?? UIImage()
     mockClient = AHNetworkClient(baseURL: "https://www.test.com", session: session)
     let request = AHRequest(path: "/uploaded", httpMethod: .post, isAuthenticationNeededRequest: false)   
     mockClient.upload(request: request, responseModel: [String].self, uploadModel: image) { responseModel, _ in
         XCTAssertNotNil(responseModel)
         exp.fulfill()
     }
     wait(for: [exp], timeout: 1.0)
 }
 ```
**How to see progress of a data task:** 
 
 ```swift
 
 //step 1: create an instance of AHNetworkProgressDelegate
 
 let delegate: AHNetworkProgressDelegateMock? =  AHNetworkProgressDelegateMock()
 
// step 2: create session configuration with the delegate of type AHNetworkProgressDelegate

let sessionWithDelegate = URLSession(configuration: URLSessionConfiguration.default, delegate: delegate, delegateQueue: .main)

// step 3: create your own progressClosure of type AHNetworkProgressClosure 

let progressClosure: (Double?) -> Void = { progressValue in
       print(progressValue ?? "0")}
       
// create your request just like normal request but add a progress closure to .execute method      
myNetworkClient.execute(request: AHRequestTest(),
                        model: user [UserPosts].self,
                        progressClosure: progressClosure) { model, error in
    if error != nil {
      //  switch on error and handle each case 
    } else {
      // you have your model as Codable model object cast to your type and easily use it
      if let model = model as? [UserPosts]{
        print(model[0].title)
      }
    }
  }
 ```
 You can also see the progress of the download file task just follow the same procedure.

**How to cancel a task:** 
 
 ```swift
 var sampleRequest = AHRequestTest()
 func testCancelTask() {
    let exp = expectation(description: #function)
    myNetworkClient.execute(request: sampleRequest, model: [UserPosts].self) { _, _ in
    }
    myNetworkClient.cancel(request: sampleRequest) {
        XCTAssertTrue(self.session.urlSessionDataTaskMock.isCancelledCalled)
        exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
}
 ```
  
### AHNetworkError:

AHNetwork layer may throw one of those custom errors to let the call side do any special handling.

```swift
public enum AHNetworkResponse: String, Error {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case serverError = "server encountered an unexpected condition"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

public enum AHNetworkError: String, Error {
    case parse      = "Unable to parse response"
    case network    = "Network operation failed"
    case empty      = "Empty response"
    case missingURL = "missing URL"
    case encodingFailed = "encodingFailed"
    case unknown    = "Unknown"
    case authFailed = "Authentication token missed"
    case noInternetConnection = "no Internet Connection"
}
```

Now, you can switch on those custom error in your completion Handler
