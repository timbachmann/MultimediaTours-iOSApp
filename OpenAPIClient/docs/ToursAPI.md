# ToursAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**toursGeneratePost**](ToursAPI.md#toursgeneratepost) | **POST** /tours/generate | Generate a new tour
[**toursGet**](ToursAPI.md#toursget) | **GET** /tours | Retrieve all Tours
[**toursIdDelete**](ToursAPI.md#toursiddelete) | **DELETE** /tours/{id} | Delete Tour by ID
[**toursIdGet**](ToursAPI.md#toursidget) | **GET** /tours/{id} | Retrieve a Tour by ID
[**toursIdPut**](ToursAPI.md#toursidput) | **PUT** /tours/{id} | Update Tour by ID
[**toursPost**](ToursAPI.md#tourspost) | **POST** /tours | Create a new tour


# **toursGeneratePost**
```swift
    open class func toursGeneratePost(generateRequest: GenerateRequest, completion: @escaping (_ data: TourResponse?, _ error: Error?) -> Void)
```

Generate a new tour

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let generateRequest = GenerateRequest(searchQuery: "searchQuery_example") // GenerateRequest | 

// Generate a new tour
ToursAPI.toursGeneratePost(generateRequest: generateRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **generateRequest** | [**GenerateRequest**](GenerateRequest.md) |  | 

### Return type

[**TourResponse**](TourResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **toursGet**
```swift
    open class func toursGet(completion: @escaping (_ data: [TourResponse]?, _ error: Error?) -> Void)
```

Retrieve all Tours

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Retrieve all Tours
ToursAPI.toursGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[TourResponse]**](TourResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **toursIdDelete**
```swift
    open class func toursIdDelete(id: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete Tour by ID

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Delete Tour by ID
ToursAPI.toursIdDelete(id: id) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **toursIdGet**
```swift
    open class func toursIdGet(id: String, completion: @escaping (_ data: TourResponse?, _ error: Error?) -> Void)
```

Retrieve a Tour by ID

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Retrieve a Tour by ID
ToursAPI.toursIdGet(id: id) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 

### Return type

[**TourResponse**](TourResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **toursIdPut**
```swift
    open class func toursIdPut(id: String, tourRequest: TourRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update Tour by ID

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let tourRequest = TourRequest(title: "title_example", source: "source_example", multimediaObjects: ["multimediaObjects_example"], author: "author_example", tags: ["tags_example"]) // TourRequest | 

// Update Tour by ID
ToursAPI.toursIdPut(id: id, tourRequest: tourRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **tourRequest** | [**TourRequest**](TourRequest.md) |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **toursPost**
```swift
    open class func toursPost(tourRequest: TourRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Create a new tour

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let tourRequest = TourRequest(title: "title_example", source: "source_example", multimediaObjects: ["multimediaObjects_example"], author: "author_example", tags: ["tags_example"]) // TourRequest | 

// Create a new tour
ToursAPI.toursPost(tourRequest: tourRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tourRequest** | [**TourRequest**](TourRequest.md) |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

