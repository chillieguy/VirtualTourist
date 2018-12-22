//
//  FlickrProvider.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 10/27/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import Foundation

struct FlickrProvider {
    //    URL: https://api.flickr.com/services/rest/?
    //    method=flickr.photos.search
    //    &api_key=c322d705e685edd1144876851dbb1474
    //    &accuracy=13
    //    &lat=44.0582
    //    &lon=-121.3153
    //    &extras=url_m
    //    &per_page=25
    //    &format=json
    //    &nojsoncallback=1
    //    &auth_token=72157702748458094-3612c02ff0416f25
    //    &api_sig=733e034df3b264fe54a6fc3d5eb2b801
    
    let methodParameters = [
        Constants.ParameterKeys.Method: Constants.ParameterValues.GalleryPhotosMethod,
        Constants.ParameterKeys.APIKey: Constants.ParameterValues.APIKey,
        Constants.ParameterKeys.SafeSearch: Constants.ParameterValues.UseSafeSearch,
        Constants.ParameterKeys.Extras: Constants.ParameterValues.MediumURL,
        Constants.ParameterKeys.Format: Constants.ParameterValues.ResponseFormat,
        Constants.ParameterKeys.NoJSONCallback: Constants.ParameterValues.DisableJSONCallback,
        // TODO: Default to Bend, OR while in development
        Constants.ParameterKeys.Lat: Constants.ParameterValues.Lat,
        Constants.ParameterKeys.Lon: Constants.ParameterValues.Lon
    ]
    
    func getFlickrNumberOfPagesByLatLon(completion: @escaping (_ page: Int) -> ()) {
        var page = 0
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // If error print error message and return
            if error != nil {
                print("There was an error with your request: \(String(describing: error?.localizedDescription))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            // GUARD: Did Flickr return an error (stat != ok)?
            guard let stat = parsedResult?[Constants.ResponseKeys.Status] as? String, stat == Constants.ResponseValues.OKStatus else {
                print("Flickr API returned an error. See error code and message in \(String(describing: parsedResult))")
                return
            }
            
            // GUARD: Is "photos" key in our result?
            guard let photosDictionary = parsedResult?[Constants.ResponseKeys.Photos] as? [String:AnyObject] else {
                print("Cannot find keys '\(Constants.ResponseKeys.Photos)' in \(String(describing: parsedResult))")
                return
            }
            
            // GUARD: Is "pages" key in the photosDictionary?
            guard let totalPages = photosDictionary[Constants.ResponseKeys.Pages] as? Int else {
                print("Cannot find key '\(Constants.ResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            page = randomPage
            
            completion(page)
        }
        // start the task!
        task.resume()
    }
    
    func getImagesFromFlickr(completion: @escaping (_ arrayOfImageUrls: [URL]) -> ()) {
        var arrayOfUrls: [URL] = []
        var page = 0
        getFlickrNumberOfPagesByLatLon { (pageNumber) in
            page = pageNumber
        }
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber: [String:AnyObject] = methodParameters as [String : AnyObject]
        methodParametersWithPageNumber[Constants.ParameterKeys.Page] = page as AnyObject?
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParametersWithPageNumber as [String : AnyObject]))
        print(request)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.ResponseKeys.Status] as? String, stat == Constants.ResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(String(describing: parsedResult))")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.ResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.ResponseKeys.Photos)' in \(String(describing: parsedResult))")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.ResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                
                for photo in photosArray {
                        /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photo[Constants.ResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find key '\(Constants.ResponseKeys.MediumURL)' in \(photo)")
                        return
                    }
                    // if an image exists at the url, set the image and title
                    guard let imageURL = URL(string: imageUrlString) else { return }
                    arrayOfUrls.append(imageURL)
                    
                }
            }
            
            completion(arrayOfUrls)
        }
        
        // start the task!
        task.resume()
    }
    
    // Mark: Private functions
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        
        components.scheme = Constants.API.Scheme
        components.host = Constants.API.Host
        components.path = Constants.API.Path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    struct Constants {
        static let APIBaseUrl = "https://api.flickr.com/services/rest/"
        
        struct API {
            static let Scheme = "https"
            static let Host = "api.flickr.com"
            static let Path = "/services/rest"
        }
        
        struct ParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Accuracy = "accuracy"
            static let SafeSearch = "safe_search"
            static let Page = "page"
            static let Lat = "lat"
            static let Lon = "lon"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let AuthToken = "auth_token"
            static let APISig = "api_sig"
        }
        
        struct ParameterValues {
            static let GalleryPhotosMethod = "flickr.photos.search"
            static let APIKey = "3b89868257168f1bc6748261fc1d19c0"
            static let AccuracyLevel = "13" // Level is 1-16, 16 is higher fidelity
            static let UseSafeSearch = "2" // 1 safe, 2 moderate, 3 restricted
            static let Lat = "44.0582" // Default Bend, OR
            static let Lon = "-121.3153" // Default Bend, OR
            static let MediumURL = "url_m"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" // 1 means "yes"
            static let AuthTokenValue = "72157702748458094-3612c02ff0416f25"
            static let APISigValue = "733e034df3b264fe54a6fc3d5eb2b801"
        }
        
        
        struct ResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        struct ResponseValues {
            static let OKStatus = "ok"
        }
    }
}
