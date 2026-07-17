//
//  Untitled.swift
//  InDecision
//
//  Created by Tracy on 17/7/2026.
//

import Foundation
import SwiftUI

@Observable
class SharedData {
    var Users = [
        User(name: "Tracy", surname: "Zhang", bio: "all time student", favouriteColor: .gray, email: "@gmail.com", password: "230027"),
        User(name: "Mengyao", surname: "Z", bio: "hii", email: "nicai", password: "abc"),
        User(name: "wow", surname: "abc", bio: "wowowow", email: "897235", password: "0000")
    ]
}


var mySharedData = SharedData()


