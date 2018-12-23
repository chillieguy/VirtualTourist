//
//  FlickrProvider.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 10/27/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import Foundation

class FlickrProvider: NSObject {

    class func sharedInstance() -> FlickrProvider {
        struct Singleton {
            static var sharedInstance = FlickrProvider()
        }
        return Singleton.sharedInstance
    }
    
    func getPhotosforLocation(_ latitude: Double, _ longitude: Double,_ page: Int, _ completion: @escaping (_ success: Bool, _ data: [[String: Any]]? ) -> Void) {
        
        let params = [ParameterKeys.APIKey  : Constants.APIKey,
                      ParameterKeys.Method  : Methods.SearchMethod,
                      ParameterKeys.Extras  : ParameterValues.MediumURL,
                      ParameterKeys.Format  : ParameterValues.ResponseFormat,
                      ParameterKeys.Lat     : String(describing: latitude),
                      ParameterKeys.Lon     : String(describing: longitude),
                      ParameterKeys.Page    : String(describing: page),
                      ParameterKeys.PerPage : "25",
                      ParameterKeys.NoJSONCallback : ParameterValues.DisableJSONCallback]
        
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            func displayError(_ errorString: String) {
                print(errorString)
                completion(false, nil)
                return
            }
            
            /* GUARD: Error-Checking for this request */
            guard (error == nil) else {
                displayError("There was an error with your request.")
                return
            }
            
            /* GUARD: Check for valid respone code for request */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode < 300 else {
                displayError("Unsuccessful request response retured.")
                return
            }
            
            let parsedData: [String: AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
            } catch {
                displayError("Could not parse data")
                return
            }
            
            guard let photos = parsedData[ResponseKeys.Photos] as! [String: Any]?,
                let photo = photos[ResponseKeys.Photo] as! [[String: Any]]? else {
                    displayError("Could not extract photos and/or photo dict")
                    return
            }
            
            completion(true, photo)
        }
        
        task.resume()
    }
    
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        static let APIKey = "3b89868257168f1bc6748261fc1d19c0"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
    }
    
    struct ParameterKeys {
        static let APIKey = "api_key"
        static let Method = "method"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let BoundingBox = "bbox"
        static let PerPage = "per_page"
        static let Page = "page"
        static let Lat = "lat"
        static let Lon = "lon"
    }
    
    struct ParameterValues {
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
    }
    
    struct Methods {
        static let SearchMethod = "flickr.photos.search"
    }
    
    struct ResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
    }
}
