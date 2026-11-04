//
//  CustomIcon.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/08.
//

import SwiftUI

enum CustomIcon: CaseIterable {
    case sqwoorl
}

extension CustomIcon {
    var displayName: LocalizedStringKey {
        "Sqwoorl"
    }
    
    var description: LocalizedStringKey {
        "Yes, that's his real name"
    }
    
    var fileName: String? {
        nil
    }
    
    var imageName: String {
        "\(fileName ?? "AppIcon")_Image"
    }
}
