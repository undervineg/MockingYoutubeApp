//
//  Video.swift
//  YoutubeApp
//
//  Created by 심승민 on 10/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

struct Video: Decodable {
    var thumbnailImageName: String?
    var title: String?
    var numberOfViews: Int?
    var uploadDate: Date?
    
    var channel: Channel?
}
