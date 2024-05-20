# Swift5 API client for OpenAPIClient

Multimedia Tours API

## Overview
This API client was generated by the [OpenAPI Generator](https://openapi-generator.tech) project.  By using the [openapi-spec](https://github.com/OAI/OpenAPI-Specification) from a remote server, you can easily generate an API client.

- API version: 1.0.0
- Package version: 
- Generator version: 7.5.0
- Build package: org.openapitools.codegen.languages.Swift5ClientCodegen

## Installation

### Carthage

Run `carthage update`

### CocoaPods

Run `pod install`

## Documentation for API Endpoints

All URIs are relative to *http://localhost*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*FilesAPI* | [**multimediaObjectsFileIdGet**](docs/FilesAPI.md#multimediaobjectsfileidget) | **GET** /multimedia-objects/file/{id} | Get MultimediaObject Object by ID
*FilesAPI* | [**multimediaObjectsUploadIdPost**](docs/FilesAPI.md#multimediaobjectsuploadidpost) | **POST** /multimedia-objects/upload/{id} | Upload a new Object
*MultimediaObjectsAPI* | [**multimediaObjectsGet**](docs/MultimediaObjectsAPI.md#multimediaobjectsget) | **GET** /multimedia-objects | Retrieve all MultimediaObjects
*MultimediaObjectsAPI* | [**multimediaObjectsIdDelete**](docs/MultimediaObjectsAPI.md#multimediaobjectsiddelete) | **DELETE** /multimedia-objects/{id} | Delete MultimediaObject by ID
*MultimediaObjectsAPI* | [**multimediaObjectsIdGet**](docs/MultimediaObjectsAPI.md#multimediaobjectsidget) | **GET** /multimedia-objects/{id} | Retrieve a MultimediaObject by ID
*MultimediaObjectsAPI* | [**multimediaObjectsIdPut**](docs/MultimediaObjectsAPI.md#multimediaobjectsidput) | **PUT** /multimedia-objects/{id} | Update MultimediaObject by ID
*MultimediaObjectsAPI* | [**multimediaObjectsPost**](docs/MultimediaObjectsAPI.md#multimediaobjectspost) | **POST** /multimedia-objects | Create a new multimediaObject
*ToursAPI* | [**toursGeneratedGet**](docs/ToursAPI.md#toursgeneratedget) | **GET** /tours/generated | Retrieve all generated Tours
*ToursAPI* | [**toursGeneratedPost**](docs/ToursAPI.md#toursgeneratedpost) | **POST** /tours/generated | Generate a new tour
*ToursAPI* | [**toursGet**](docs/ToursAPI.md#toursget) | **GET** /tours | Retrieve all Tours
*ToursAPI* | [**toursIdDelete**](docs/ToursAPI.md#toursiddelete) | **DELETE** /tours/{id} | Delete Tour by ID
*ToursAPI* | [**toursIdGet**](docs/ToursAPI.md#toursidget) | **GET** /tours/{id} | Retrieve a Tour by ID
*ToursAPI* | [**toursIdPut**](docs/ToursAPI.md#toursidput) | **PUT** /tours/{id} | Update Tour by ID
*ToursAPI* | [**toursPost**](docs/ToursAPI.md#tourspost) | **POST** /tours | Create a new tour
*UsersAPI* | [**usersGet**](docs/UsersAPI.md#usersget) | **GET** /users | Retrieve all Users
*UsersAPI* | [**usersIdDelete**](docs/UsersAPI.md#usersiddelete) | **DELETE** /users/{id} | Delete User by ID
*UsersAPI* | [**usersIdGet**](docs/UsersAPI.md#usersidget) | **GET** /users/{id} | Retrieve a User by ID
*UsersAPI* | [**usersIdPut**](docs/UsersAPI.md#usersidput) | **PUT** /users/{id} | Update User by ID
*UsersAPI* | [**usersPost**](docs/UsersAPI.md#userspost) | **POST** /users | Create a new user


## Documentation For Models

 - [GenerateRequest](docs/GenerateRequest.md)
 - [LoginRequest](docs/LoginRequest.md)
 - [LogoutRequest](docs/LogoutRequest.md)
 - [MultimediaObject](docs/MultimediaObject.md)
 - [MultimediaObjectPosition](docs/MultimediaObjectPosition.md)
 - [MultimediaObjectRequest](docs/MultimediaObjectRequest.md)
 - [MultimediaObjectResponse](docs/MultimediaObjectResponse.md)
 - [Tour](docs/Tour.md)
 - [TourRequest](docs/TourRequest.md)
 - [TourResponse](docs/TourResponse.md)
 - [User](docs/User.md)
 - [UserRequest](docs/UserRequest.md)
 - [UserResponse](docs/UserResponse.md)
 - [UserSession](docs/UserSession.md)
 - [UserSessionResponse](docs/UserSessionResponse.md)


<a id="documentation-for-authorization"></a>
## Documentation For Authorization

Endpoints do not require authorization.


## Author


