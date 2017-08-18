//
//  GLTFErrors.swift
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/18.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import Foundation

public enum GLTFUnarchiveError : Error {
    case DataInconsistent(String)
    case NotSupported(String)
    case Unknown(String)
}

public enum GLTFArhiverError : Error {
    case Unknown(String)
}
