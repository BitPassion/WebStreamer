//
//  UIFont+Extension.swift
//  WebStreamer
//
//  Created by Yinjing Li on 10/13/22.
//

import UIKit

enum FontWeight: Int {
    case regular
    case semiBold
    case bold
    case boldit
}

extension UIFont {
    static func custom(size: CGFloat, weight: FontWeight) -> UIFont? {
        switch weight {
        case .regular:
            return UIFont(name: "MyriadPro-Regular", size: size)
        case .semiBold:
            return UIFont(name: "MyriadPro-Semibold", size: size)
        case .bold:
            return UIFont(name: "MyriadPro-Bold", size: size)
        case .boldit:
            return UIFont(name: "MyriadPro-BoldIt", size: size)
        }
    }
}
