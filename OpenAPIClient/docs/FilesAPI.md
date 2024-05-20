# FilesAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**multimediaObjectsFileIdGet**](FilesAPI.md#multimediaobjectsfileidget) | **GET** /multimedia-objects/file/{id} | Get MultimediaObject Object by ID
[**multimediaObjectsUploadIdPost**](FilesAPI.md#multimediaobjectsuploadidpost) | **POST** /multimedia-objects/upload/{id} | Upload a new Object


# **multimediaObjectsFileIdGet**
```swift
    open class func multimediaObjectsFileIdGet(id: String, completion: @escaping (_ data: URL?, _ error: Error?) -> Void)
```

Get MultimediaObject Object by ID

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Get MultimediaObject Object by ID
FilesAPI.multimediaObjectsFileIdGet(id: id) { (response, error) in
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

**URL**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/png, video/mp4, audio/mp3

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **multimediaObjectsUploadIdPost**
```swift
    open class func multimediaObjectsUploadIdPost(id: String, file: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Upload a new Object

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let file = URL(string: "https://example.com")! // URL |  (optional)

// Upload a new Object
FilesAPI.multimediaObjectsUploadIdPost(id: id, file: file) { (response, error) in
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
 **file** | **URL** |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

