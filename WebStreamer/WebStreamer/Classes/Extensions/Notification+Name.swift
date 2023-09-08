//
//  Notification+Name.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 8/5/22.
//

import UIKit

extension Notification.Name {

    static let playlistChanged = Notification.Name(rawValue: kPlaylistChangedNotification)
    static let playlistGenerated = Notification.Name(rawValue: kPlaylistGeneratedNotification)
    static let selectSongsRenamed = Notification.Name(rawValue: kSelectSongsRenamedNotification)
    static let selectedFastForward = Notification.Name(rawValue: kSelectFastForwardNotification)
    static let volumeChanged = Notification.Name(rawValue: kVolumeChangedNotification)
    static let systemVolumeChanged = Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    static let playlistRemoved = Notification.Name(rawValue: kPlaylistRemovedNotification)
    static let selectSongsChanged = Notification.Name(rawValue: kSelectSongsChangedNotification)
    static let productPurchased = Notification.Name(rawValue: kProductPurchasedNotification)
    static let purchaseFailed = Notification.Name(rawValue: kPurchaseFailedNotification)
    static let browserChanged = Notification.Name(rawValue: kBrowserChangedNotification)
}
