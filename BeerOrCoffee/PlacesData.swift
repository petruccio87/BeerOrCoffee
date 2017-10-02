//
//  PlacesData.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import Foundation
import RealmSwift

class PlacesData: Object {
    dynamic var place_name: String = ""
    dynamic var place_id: String = ""
    dynamic var place_icon: String = ""
    dynamic var raiting: String = ""
    dynamic var price_level: String = ""
    dynamic var latLng: String = ""
    dynamic var address: String = ""
    dynamic var favorit: Bool = false
    
    override static func primaryKey() -> String? {
        return "place_id"
    }
}

class FavoritsData: Object {
    dynamic var place_name: String = ""
    dynamic var place_id: String = ""
    dynamic var place_icon: String = ""
    dynamic var raiting: String = ""
    dynamic var price_level: String = ""
    dynamic var latLng: String = ""
    dynamic var address: String = ""
    dynamic var favorit: Bool = true
    
    override static func primaryKey() -> String? {
        return "place_id"
    }
}

class PhotosData: Object {
    dynamic var place_id: String = ""
    dynamic var place_photo: String = ""
    dynamic var favorit: Bool = true
    
    override static func primaryKey() -> String? {
        return "place_photo"
    }
}

class IconsData: Object {
    dynamic var icon_type: String = ""
    dynamic var icon_url: String = ""
    dynamic var icon_local: String = ""
    
    override static func primaryKey() -> String? {
        return "icon_url"
    }
}
