//
//  DistanceTimeUtil.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/28/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import Firebase
import CocoaLumberjack
import Alamofire

struct DistanceTimeUtil {
    /*
     Returns a dictionary with the following format:
         ["addressId1" :  [
                "restaurantId1" : DistanceTime for restaurantId1 to addressId1,
                "restaurantId2" : DistanceTime for restaurantId2 to addressId1,
                 etc... ]],
         ["addressId2" :  [
                 "restaurantId1" : DistanceTime for restaurantId1 to addressId2,
                 "restaurantId2" : DistanceTime for restaurantId2 to addressId2,
                  etc... ]],
     */
    private static func getStoredDistanceTimes() -> [String : [String : DistanceTime]] {
        if let distanceTimesData = UserDefaults.standard.data(forKey: UDKeys.distanceTimes) {
            return try! JSONDecoder().decode([String : [String : DistanceTime]].self, from: distanceTimesData)
        }
        return [:]
    }
    
    // Merges, saves and returns a DistanceTime dictionary for a given address
    private static func saveNewDistanceTimes(_ newDistanceTimes: [String : DistanceTime], forAddressId addressId: String) -> [String : DistanceTime] {
        var storedDistanceTimes = getStoredDistanceTimes()
        if let _ = storedDistanceTimes[addressId] {
            // Entry already exists for address
            storedDistanceTimes[addressId]!.merge(newDistanceTimes) { (_, new) in new}
        } else {
            // Create new entry for address
            storedDistanceTimes[addressId] = newDistanceTimes
        }
        
        let storedDistanceTimesData = try! JSONEncoder().encode(storedDistanceTimes)
        UserDefaults.standard.set(storedDistanceTimesData, forKey: UDKeys.distanceTimes)
        
        return storedDistanceTimes[addressId]!
    }
    
    // Returns a dictionary of restaurant ids and distanceTimes
    static func getDistanceTimes(_ restaurants: [Restaurant], forAddress address: Address, completionHandler: @escaping (_ result: [String : DistanceTime]?, _ error: Error?) -> Void) {
        let selectedAddressId = address.id
        
        guard let distanceTimesForCurrentAddress = getStoredDistanceTimes()[selectedAddressId] else {
            // No dictionary entry for this address id. Must be New address
            DDLogDebug("New address detected, requesting all distanceTimes")
            return requestDistanceTimes(restaurants, forAddressId: selectedAddressId, completionHandler: completionHandler)
        }
        
        // Store any restaurants that don't already have a DistanceTime object
        // for the currently selected address OR have a DistanceTime object with non-OK status.
        // Will be used to construct the Distance API request later
        let missingRestaurants = restaurants.filter({ distanceTimesForCurrentAddress[$0.id] == nil ||
                                                      distanceTimesForCurrentAddress[$0.id]?.status != "OK" })
        
        if missingRestaurants.isEmpty {
            return completionHandler(distanceTimesForCurrentAddress, nil)
        }
        
        return requestDistanceTimes(missingRestaurants, forAddressId: selectedAddressId, completionHandler: completionHandler)
    }
    
    private static func requestDistanceTimes(_ restaurants: [Restaurant], forAddressId addressId: String,
                                             completionHandler: @escaping (_ result: [String : DistanceTime]?, _ error: Error?) -> Void) {
        let geopoints = restaurants.compactMap({ $0.geoPoint })
        
        let url = APIRequestBuilder.getDistanceMatrixRequestUrl(restaurantGeopoints: geopoints)
        
        DDLogDebug("Requesting distances")
        AF.request(url).responseJSON { response in
            do {
                let dtMatrix = try JSONDecoder().decode(DistanceTimeMatrix.self, from: response.data!)
                
                if let newResponseDistanceTimes = processResponse(restaurants, dtMatrix) {
                    completionHandler(saveNewDistanceTimes(newResponseDistanceTimes, forAddressId: addressId), nil)
                } else {
                    completionHandler(nil, nil)
                    DDLogError("Error processing json!")
                }
            } catch {
                completionHandler(nil, nil)
                DDLogError("Error parsing json! \(error)")
            }
        }
    }
    
    private static func processResponse(_ restaurants: [Restaurant], _ dtMatrix: DistanceTimeMatrix) -> [String : DistanceTime]? {
        guard dtMatrix.status == "OK", let row = dtMatrix.rows.first else {
            DDLogError("INCORRECT DISTANCE MATRIX RESPONSE STATUS OR EMPTY ROWS IN RESPONSE")
            return nil
        }
        
        var distanceTimes = row.elements.compactMap({ DistanceTime(status: $0.status,
                                                                   distance: $0.distance.text,
                                                                   distanceValue: $0.distance.value,
                                                                   time: $0.duration.text,
                                                                   timeValue: $0.duration.value) })
        var newDistanceTimes: [String : DistanceTime] = [:]
        for restaurant in restaurants {
            newDistanceTimes[restaurant.id] = distanceTimes.removeFirst()
        }
        return newDistanceTimes
    }
}

struct DistanceTime: Codable {
    let status: String
    let distance: String
    let distanceValue: Int
    let time: String
    let timeValue: Int
}

struct APIRequestBuilder {
    static func getDistanceMatrixRequestUrl(restaurantGeopoints: [GeoPoint]) -> String {
        var request = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric"
        
        let user = UserUtil.currentUser!
        
        let originString = "&origins=\(user.selectedAddress.latitude),\(user.selectedAddress.longitude)"
        
        request.append(originString + "&destinations=")
        
        for geopoint in restaurantGeopoints {
            let destinationString = "\(geopoint.latitude)%2C\(geopoint.longitude)%7C"
            request.append(destinationString)
        }
        request = request.chompLast(3)
        
        let keyString = "&key=AIzaSyDA9qrmg1UNFPnlAZWC1Xlis5TdkNIzavM"
        
        request.append(keyString)
        DDLogDebug("API Request string: \(request)")
        return request
    }
}

struct DistanceTimeMatrix: Codable {
    let destinationAddresses: [String]
    let originAddresses: [String]
    let rows: [Row]
    let status: String
    
    struct Row: Codable {
        let elements: [Element]
        
        struct Element: Codable {
            let status: String
            let distance: Distance
            let duration: Duration
            
            struct Distance: Codable {
                let text: String
                let value: Int
            }
            
            struct Duration: Codable {
                let text: String
                let value: Int
            }
        }
    }
}

extension DistanceTimeMatrix {
    enum CodingKeys: String, CodingKey {
        case destinationAddresses = "destination_addresses"
        case originAddresses = "origin_addresses"
        case rows
        case status
    }
}
