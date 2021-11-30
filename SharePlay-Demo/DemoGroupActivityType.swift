//
//  DemoGroupActivityType.swift
//  SharePlay-Demo
//
//  Created by Shunzhe Ma on 2021/11/10.
//

import Foundation
import GroupActivities

struct DemoGroupActivityType: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Demo Activity"
        metadata.type = .generic
        return metadata
    }
}
