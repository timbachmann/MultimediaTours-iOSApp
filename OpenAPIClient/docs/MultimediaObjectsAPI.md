# MultimediaObjectsAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**multimediaObjectsGet**](MultimediaObjectsAPI.md#multimediaobjectsget) | **GET** /multimedia-objects | Retrieve all MultimediaObjects
[**multimediaObjectsIdDelete**](MultimediaObjectsAPI.md#multimediaobjectsiddelete) | **DELETE** /multimedia-objects/{id} | Delete MultimediaObject by ID
[**multimediaObjectsIdGet**](MultimediaObjectsAPI.md#multimediaobjectsidget) | **GET** /multimedia-objects/{id} | Retrieve a MultimediaObject by ID
[**multimediaObjectsIdPut**](MultimediaObjectsAPI.md#multimediaobjectsidput) | **PUT** /multimedia-objects/{id} | Update MultimediaObject by ID
[**multimediaObjectsPost**](MultimediaObjectsAPI.md#multimediaobjectspost) | **POST** /multimedia-objects | Create a new multimediaObject


# **multimediaObjectsGet**
```swift
    open class func multimediaObjectsGet(completion: @escaping (_ data: [MultimediaObjectResponse]?, _ error: Error?) -> Void)
```

Retrieve all MultimediaObjects

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Retrieve all MultimediaObjects
MultimediaObjectsAPI.multimediaObjectsGet() { (response, error) in
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

[**[MultimediaObjectResponse]**](MultimediaObjectResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **multimediaObjectsIdDelete**
```swift
    open class func multimediaObjectsIdDelete(id: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete MultimediaObject by ID

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Delete MultimediaObject by ID
MultimediaObjectsAPI.multimediaObjectsIdDelete(id: id) { (response, error) in
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

# **multimediaObjectsIdGet**
```swift
    open class func multimediaObjectsIdGet(id: String, completion: @escaping (_ data: MultimediaObjectResponse?, _ error: Error?) -> Void)
```

Retrieve a MultimediaObject by ID

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Retrieve a MultimediaObject by ID
MultimediaObjectsAPI.multimediaObjectsIdGet(id: id) { (response, error) in
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

[**MultimediaObjectResponse**](MultimediaObjectResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **multimediaObjectsIdPut**
```swift
    open class func multimediaObjectsIdPut(id: String, multimediaObjectRequest: MultimediaObjectRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update MultimediaObject by ID

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let multimediaObjectRequest = MultimediaObjectRequest(type: "type_example", title: "title_example", date: "date_example", source: "source_example", tags: ["tags_example"], position: MultimediaObjectPosition(lat: 123, lng: 123, bearing: 123, yaw: 123), data: "data_example", author: "author_example") // MultimediaObjectRequest | 

// Update MultimediaObject by ID
MultimediaObjectsAPI.multimediaObjectsIdPut(id: id, multimediaObjectRequest: multimediaObjectRequest) { (response, error) in
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
 **multimediaObjectRequest** | [**MultimediaObjectRequest**](MultimediaObjectRequest.md) |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **multimediaObjectsPost**
```swift
    open class func multimediaObjectsPost(multimediaObjectRequest: MultimediaObjectRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Create a new multimediaObject

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let multimediaObjectRequest = MultimediaObjectRequest(type: "type_example", title: "title_example", date: "date_example", source: "source_example", tags: ["tags_example"], position: MultimediaObjectPosition(lat: 123, lng: 123, bearing: 123, yaw: 123), data: "data_example", author: "author_example") // MultimediaObjectRequest | 

// Create a new multimediaObject
MultimediaObjectsAPI.multimediaObjectsPost(multimediaObjectRequest: multimediaObjectRequest) { (response, error) in
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
 **multimediaObjectRequest** | [**MultimediaObjectRequest**](MultimediaObjectRequest.md) |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

