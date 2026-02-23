//
//  Metadata.swift
//  remi-ssc
//
//  Created by Pratham S on 2/23/26.
//

import SwiftUI
import SwiftData

@Model
class Metadata {
    var appStartDate: Date
    
    init () {
        self.appStartDate = Date()
    }
}
