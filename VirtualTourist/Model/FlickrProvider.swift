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
    
    struct Constants {
        static let APIBaseUrl = "https://api.flickr.com/services/rest/"
        
        struct ParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Accuracy = "accuracy"
            static let Lat = "lat"
            static let Lon = "lon"
            static let Extras = "url_m"
            static let Format = "json"
            static let NoJSONCallBack = "nojsoncallback"
            static let AuthToken = "auth_token"
            static let APISig = "api_sig"
        }
        
        struct ParameterValues {
            static let GalleryPhotosMethod = "flickr.photos.search"
            static let APIKey = "c322d705e685edd1144876851dbb1474"
            static let AccuracyLevel = "13" // Level is 1-16, 16 is higher fidelity
            static let Lat = "" // Default Bend, OR
            static let Lon = "" // Default Bend, OR
            static let MediumURL = "url_m"
            static let ResponseFormat = "json"
            static let DisableJSONCallBack = "1" // 1 means "yes"
            static let AuthTokenValue = "72157702748458094-3612c02ff0416f25"
            static let APISigValue = "733e034df3b264fe54a6fc3d5eb2b801"
        }
    }
}
