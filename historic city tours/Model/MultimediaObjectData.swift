//
//  MultimediaObject.swift
//  historic city tours
//
//  Created by Tim Bachmann on 06.05.2024.
//

import Foundation
import Combine
import MapKit
import AVFoundation
import OpenAPIClient
import SwiftUI

/**
 Observable class image data to represent current images and images to upload.
 Contains functions to save and load data from the app's cache directory
 */
class MultimediaObjectData: ObservableObject {
    @Published var activeTour: TourResponse? = nil
    @Published var activeTourObjectIndex: Int? = nil
    @Published var activeTourObjectCount: Int? = nil
    @Published var multimediaObjects: [MultimediaObjectResponse] = []
    @Published var tours: [TourResponse] = []
    @Published var isLoading: Bool = false
    @State private var placeholderList: [TourResponse] = [TourResponse(generated: false), TourResponse(generated: false), TourResponse(generated: false), TourResponse(generated: true), TourResponse(generated: true), TourResponse(generated: true)]
    
    /**
     Initialize images by loading from cache
     */
    init() {
        loadAllTours { (data, error) in
            if let retrievedData = data {
                self.tours = retrievedData
                self.tours.sort(by: { $0.title ?? "a" < $1.title ?? "b" })
                self.isLoading = false
            }
        }
        
        loadAllMultimediaObjects { (data, error) in
            if let retrievedData = data {
                self.multimediaObjects = retrievedData
                self.multimediaObjects.sort(by: { $0.id ?? "a" < $1.id ?? "b" })
            }
        }
    }
    
    /**
     Loads previously queried images from cache and returns list
     */
    func loadAllToursFromCache(completion: @escaping (_ data: [TourResponse]?, _ error: String?) -> ())  {
        var tours: [TourResponse] = []
        var receivedError: String? = nil
        
        DispatchQueue.global(qos: .background).async {
            let cachePath = self.getCacheDirectoryPath().appendingPathComponent("tours")
            let fileManager: FileManager = FileManager.default
            
            do {
                let tourFolders: [URL] = try fileManager.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: nil)
                
                for tourFolder in tourFolders {
                    var metaData: TourResponse
                    let metaPath = tourFolder.appendingPathComponent("\(tourFolder.lastPathComponent).json")
                    
                    do {
                        let rawMetaData = try Data(contentsOf: metaPath)
                        let decoder = JSONDecoder()
                        metaData = try decoder.decode(TourResponse.self, from: rawMetaData)
                        tours.append(metaData)
                        
                    } catch {
                        receivedError = "Couldn't parse \(metaPath.path) as \(TourResponse.self):\n\(error)"
                    }
                }
            } catch {
                receivedError = "Couldn't iterate cache directory!"
            }
            
            DispatchQueue.main.async {
                completion(tours, receivedError)
            }
        }
    }
    
    func loadAllTours(completion: @escaping (_ data: [TourResponse]?, _ error: String?) -> ())  {
        self.isLoading = true
        self.tours = placeholderList
        self.loadAllToursFromCache() { (response, error) in
            if error != nil {
                ToursAPI.toursGet() { (response, error) in
                    completion(response ?? [], error.debugDescription)
                    self.saveToursToFile()
                }
            } else {
                completion(response ?? [], error.debugDescription)
            }
        }
    }
    
    func refreshTours() {
        self.isLoading = true
        self.tours = placeholderList
        ToursAPI.toursGet() { (response, error) in
            if let retrievedData = response {
                self.tours = retrievedData
                self.tours.sort(by: { $0.title ?? "a" < $1.title ?? "b" })
                self.isLoading = false
                self.saveToursToFile()
            }
        }
    }
    
    /**
     Saves all images to cache while invalidating old state
     */
    func saveToursToFile() {
        let path = getCacheDirectoryPath().appendingPathComponent("tours")
        do {
            try FileManager.default.removeItem(atPath: path.path)
        } catch let error as NSError {
            print("Unable to delete directory \(error.debugDescription)")
        }
        
        for tour in self.tours {
            let folderPath = getCacheDirectoryPath().appendingPathComponent("tours").appendingPathComponent(tour.id!)
            do {
                try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
            }
        
            let metaPath = folderPath.appendingPathComponent("\(tour.id!).json")
            do {
                let jsonDataLocal = try JSONEncoder().encode(tour)
                try jsonDataLocal.write(to: metaPath)
            } catch {
                print("Error writing metadata file: \(error)")
            }
        }
    }
    
    func loadAllMultimediaObjects(completion: @escaping (_ data: [MultimediaObjectResponse]?, _ error: String?) -> ())  {
        self.loadAllMultimediaObjectsFromCache() { (response, error) in
            if error != nil {
                MultimediaObjectsAPI.multimediaObjectsGet() { (response, error) in
                    completion(response ?? [], error.debugDescription)
                    self.saveMultimediaObjectsToFile()
                }
            } else {
                completion(response ?? [], error.debugDescription)
            }
        }
    }
    
    func refreshMultimediaObjects() {
        MultimediaObjectsAPI.multimediaObjectsGet() { (response, error) in
            if let retrievedData = response {
                self.multimediaObjects = retrievedData
                self.multimediaObjects.sort(by: { $0.title ?? "a" < $1.title ?? "b" })
                self.saveMultimediaObjectsToFile()
            }
        }
    }
    
    func loadAllMultimediaObjectsFromCache(completion: @escaping (_ data: [MultimediaObjectResponse]?, _ error: String?) -> ())  {
        var multimediaObjects: [MultimediaObjectResponse] = []
        var receivedError: String? = nil
        
        DispatchQueue.global(qos: .background).async {
            let cachePath = self.getCacheDirectoryPath().appendingPathComponent("multimedia-objects")
            let fileManager: FileManager = FileManager.default
            
            do {
                let multimediaObjectFolders: [URL] = try fileManager.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: nil)
                
                for multimediaObjectFolder in multimediaObjectFolders {
                    var metaData: MultimediaObjectResponse
                    let metaPath = multimediaObjectFolder.appendingPathComponent("\(multimediaObjectFolder.lastPathComponent).json")
                    
                    do {
                        let rawMetaData = try Data(contentsOf: metaPath)
                        let decoder = JSONDecoder()
                        metaData = try decoder.decode(MultimediaObjectResponse.self, from: rawMetaData)
                        multimediaObjects.append(metaData)
                        
                    } catch {
                        receivedError = "Couldn't parse \(metaPath.path) as \(MultimediaObjectResponse.self):\n\(error)"
                    }
                }
            } catch {
                receivedError = "Couldn't iterate cache directory!"
            }
            
            DispatchQueue.main.async {
                completion(multimediaObjects, receivedError)
            }
        }
    }
    
    func saveMultimediaObjectsToFile() {
        let path = getCacheDirectoryPath().appendingPathComponent("multimedia-objects")
        do {
            try FileManager.default.removeItem(atPath: path.path)
        } catch let error as NSError {
            print("Unable to delete directory \(error.debugDescription)")
        }
        
        for multimediaObject in self.multimediaObjects {
            let folderPath = getCacheDirectoryPath().appendingPathComponent("multimedia-objects").appendingPathComponent(multimediaObject.id!)
            do {
                try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
            }
        
            let metaPath = folderPath.appendingPathComponent("\(multimediaObject.id!).json")
            do {
                let jsonDataLocal = try JSONEncoder().encode(multimediaObject)
                try jsonDataLocal.write(to: metaPath)
            } catch {
                print("Error writing metadata file: \(error)")
            }
        }
    }
    
    func getFileForMultimediaObject(id: String, completion: @escaping (_ data: String?, _ error: String?) -> ()) {
        let filesDirectory = getCacheDirectoryPath().appendingPathComponent("multimedia-objects").appendingPathComponent("file")
        let fileDirectory = filesDirectory.appendingPathComponent(id)
        
        DispatchQueue.global(qos: .background).async {
            do {
                let scanItems = try FileManager.default.contentsOfDirectory(atPath: fileDirectory.path())
                
                for scanItem in scanItems {
                    if scanItem.hasPrefix(id) {
                        completion(fileDirectory.appendingPathComponent(scanItem).path(), nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    FilesAPI.multimediaObjectsFileIdGet(id: id) { (response, error) in
                        completion(response?.path(), error.debugDescription)
                    }
                }
            }
        }
    }
    
    func getMultimediaObject(id: String) -> MultimediaObjectResponse? {
        return self.multimediaObjects.first{obj in obj.id == id}
    }
    
    func nextNavigationItemOfTour() {
        if let activeTourObjectIndex = activeTourObjectIndex {
            if let activeTour = activeTour {
                if let multimediaObjects = activeTour.multimediaObjects {
                    if activeTourObjectIndex < multimediaObjects.count - 1 {
                        self.activeTourObjectIndex = self.activeTourObjectIndex ?? 0 + 1
                    } else {
                        self.activeTourObjectIndex = nil
                        self.activeTour = nil
                    }
                }
            }
        }
    }
    
    func generateTour(query: String, completion: @escaping (_ data: TourResponse?, _ error: String?) -> ()) {
        ToursAPI.toursGeneratePost(generateRequest: GenerateRequest(searchQuery: query)) { (response, error) in
            dump(response)
            if let retrievedData = response {
                self.tours.append(retrievedData)
                self.tours.sort(by: { $0.title ?? "a" < $1.title ?? "b" })
                self.saveToursToFile()
                
                print(retrievedData)
                
                DispatchQueue.main.async {
                    completion(retrievedData, error.debugDescription)
                }
            }
        }
    }
    
    /**
     Returns cache directory path
     */
    func getCacheDirectoryPath() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    
    /**
     Schedules notifications for all images with a location trigger.
     */
    func createNotifications(oldTour: TourResponse?, newTour: TourResponse?) {
        print("CREATE NOTIFICATIONS")
        if let oldTour = oldTour {
            let oldTourMultimediaObjects = oldTour.multimediaObjects
            
            if let oldTourMultimediaObjects = oldTourMultimediaObjects {
                var identifiersToRemove: [String] = []
                
                for oldTourObjectId in oldTourMultimediaObjects {
                    identifiersToRemove.append(oldTourObjectId + "_" + "arexplorer")
                }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                CLLocationManager().monitoredRegions.forEach { region in
                    if region is CLCircularRegion {
                        if identifiersToRemove.contains(where: { $0 == region.identifier }) {
                            CLLocationManager().stopMonitoring(for: region)
                        }
                    }
                }
            }
        }
        
        if let activeTour = newTour {
            let tourMultimediaObjects = activeTour.multimediaObjects
            
            if let tourMultimediaObjects = tourMultimediaObjects {
                for objectId in tourMultimediaObjects {
                    let notificationIdentifier = objectId + "_" + "arexplorer"
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                    CLLocationManager().monitoredRegions.forEach { region in
                      if region is CLCircularRegion {
                          if region.identifier == notificationIdentifier {
                              CLLocationManager().stopMonitoring(for: region)
                          }
                      }
                    }
                    
                    let object = getMultimediaObject(id: objectId)
                    
                    if let objectPosition = object?.position {
                        let location = CLLocation(latitude: objectPosition.lat, longitude: objectPosition.lng)
                        
                        let content = UNMutableNotificationContent()
                        content.title = "Tour Object in Range"
                        content.subtitle = "Click to view in AR"
                        content.body = String(format: "50m")
                        content.sound = UNNotificationSound.default
                        content.badge = 1
                        content.categoryIdentifier = "ARExplorer"
                        content.userInfo = ["customDataKey": "cusom_data_value"]
                        
                        let region = CLCircularRegion(center: location.coordinate, radius: 50.0, identifier: notificationIdentifier)
                        region.notifyOnEntry = true
                        region.notifyOnExit = false
                        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
                        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                        
                        if let objectType = object?.type {
                            if objectType == .image {
                                getFileForMultimediaObject(id: objectId) { path, error in
                                    if let path = path {
                                        let url = URL(string: path)
                                        
                                        if let url = url {
                                            let attachment = try! UNNotificationAttachment(identifier: objectId + "_" + "file", url: url)
                                            content.attachments = [attachment]
                                        }
                                    }
                                    
                                    // 3. Create the Request
                                    UNUserNotificationCenter.current().add(request) { error in
                                        
                                        guard error == nil else { return }
                                        
                                        print("Notification scheduled! — ID = \(objectId)")
                                    }
                                }
                            } else {
                                // 3. Create the Request
                                UNUserNotificationCenter.current().add(request) { error in
                                    
                                    guard error == nil else { return }
                                    
                                    print("Notification scheduled! — ID = \(objectId)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
