//
//  Constants.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 7/20/22.
//

import UIKit

// MARK: - App Keys Common
let kInitWebStreamer = "InitWebStreamer"
let kAppInstalledDate = "AppInstalledDate"
let kAppAlreadySetted = "AppAlreadySetted"
let kAppFirstRunning = "AppFirstRunning"
let kAppLiveURLs = "LiveURLs"
let kAppCurrentURLIndex = "AppCurrentURLIndex"
let kAppHistories = "AppHistories"
let kAppBookmarks = "AppBookmarks"

// MARK: - Playlist
let kAllPlaylists = "AllPlaylists"
let kPlaylistSelected_1 = "PlaylistSelected_1"
let kPlaylistSelected_2 = "PlaylistSelected_2"

let kCurrentSongIndex = "CurrentSongIndex"
let kCurrentPlaylist = "CurrentPlaylist"
let kJingleInterval = "JingleInterval"
let kGreetingsArray = "GreetingsArray"
let kCurrentGreetingIndex = "CurrentGreetingIndex"
let kThatWasArray = "ThatWasArray"
let kCurrentThatWasIndex = "CurrentThatWasIndex"
let kPreparedArtistsArray = "PreparedArtistsArray"
let kCurrentPreparedArtistIndex = "CurrentPreparedArtistIndex"
let kTriviasArray = "TriviasArray"
let kCurrentTriviaIndex = "CurrentTriviaIndex"
let kCurrentTriviaName = "CurrentTriviaName"
let kJingleLoaded = "JingleLoaded"
let kJingleSelections = "JingleSelections"
let kNewsArray = "NewsArray"
let kCurrentNewsIndex = "CurrentNewsIndex"
let kOverlapInterval = "OverlapInterval"

// MARK: - Play
let kFadeout1Duration = "Fadeout1Duration"
let kFadeout2Duration = "Fadeout2Duration"
let kFadeoutJingleDuration = "FadeoutJingleDuration"
let kOverlap1Duration = "Overlap1Duration"
let kOverlap2Duration = "Overlap2Duration"
let kOverlapJingleDuration = "OverlapJingleDuration"

let kJingleActive = "JingleActive"
let kAnnouncementActive = "AnnouncementActive"

let kShufflePlaylist_1 = "ShufflePlaylist_1"
let kShufflePlaylist_2 = "ShufflePlaylist_2"
let kShuffleJingle = "ShuffleJingle"

let kRepeatPlaylist_1 = "RepeatPlaylist_1"
let kRepeatPlaylist_2 = "RepeatPlaylist_2"
let kRepeatJingle = "RepeatJingle"

enum RepeatType: Int {
    case off = 0
    case song
    case playlist
}

enum ShuffleType: Int {
    case off = 0
    case on
}

enum InstantType: Int {
    case ready = 0
    case song
    case jingle
    case ended
}

enum SortType: Int {
    case title = 1
    case artist
    case duration
}

enum JingleType: Int {
    case instant = 0
    case request
}

// MARK: - Announcement
let kSiriSelected_1 = "SiriSelected_1"
let kSiriSelected_2 = "SiriSelected_2"
let kSiriSelected_3 = "SiriSelected_3"
let kSiriSelected_4 = "SiriSelected_4"
let kAnnouncementVolume = "AnnouncementVolume"
let kSpeechRate = "SpeechRate"
let kMaleSiriVoices = "MaleSiriVoices"
let kFemaleSiriVoices = "FemaleSiriVoices"
let kSelectedVoiceIdentifier = "SelectedVoiceIdentifier"

let MALE_BUTTON_TAG: Int = 1000000
let FEMALE_BUTTON_TAG: Int = 2000000

// MARK: - Volume
let kVolumePlaylist_1 = "VolumePlaylist_1"
let kVolumePlaylist_2 = "VolumePlaylist_2"
let kVolumeJingle = "VolumeJingle"
let kVolumeAnnouncement = "VolumeAnnouncement"
let kVolumeDefault = "VolumeDefault"

// MARK: - PlayViewController
let SONG_TILTE_ANIMATION_INTERVAL: Float = 14.0   //10.0
let APP_DIDDOWNLOAD_INSTALLED = "APP_DIDDOWNLOAD_INSTALLED"
let APP_EXPIRE_SECONDS: TimeInterval = 3.0 * 24.0 * 60.0 * 60.0 // 3 Days
let APP_WEBSITES_INITIALIZED = "APP_WEBSITES_INITIALIZED"
let APP_SELECTSONGS_TITLE_DEFAULT = "MyOS™Radio Select Songs"
let APP_SELECTSONGS_PERSISTENT_DEFAULT = 202003091206000
let APP_SELECTSONGS_PERSISTENT_DEFAULT2 = 202006171206000
let APP_SELECTSONGS_INITIALIZED = "APP_SELECTSONGS_INITIALIZED"
let APP_NAME = "Web Streamer"
let APP_ALERT_TITLE = "Web Streamer"
let APP_WIFI_HTTP_PASSWORD = "APP_WIFI_HTTP_PASSWORD"
let APP_WIFI_SELECT_FOLDER = "APP_WIFI_SELECT_FOLDER"
let APP_SELECTSONGS_UPDATED = "APP_SELECTSONGS_UPDATED"
let MIN_INSTANT_JINGLE_INDEX = 1
let MAX_INSTANT_JINGLE_INDEX = 3
let MIN_REQUEST_JINGLE_INDEX = 1
let MAX_REQUEST_JINGLE_INDEX = 1

let OVERLAP_DEFAULT_VALUE = 2.25
let FADE_DEFAULT_VALUE = 1.5
let VOLUME_DEFAULT_VALUE = 0.5
let VOLUME_DEFAULT_SIRI = 0.4

let SONG_TYPE_JINGLE = 0
let SONG_TYPE_PLAYLIST_1 = 1
let SONG_TYPE_PLAYLIST_2 = 2
let SONG_TYPE_ANNOUNCEMENT = 3
let SONG_TYPE_SPEECHRATE = 4
let MYRIADPRO_SEMIBOLD = "MyriadPro-Semibold"
let MYRIADPRO_BOLD = "MyriadPro-Bold"
let MYRIADPRO_BOLDIT = "MyriadPro-BoldIt"
let MYRIADPRO_REGULAR = "MyriadPro-Regular"

// MARK: - TouchVisualizer
let kTouchVisualizer = "TouchVisualizer"

// MARK: - GIF Background
var gifBackground: UIImage?

// MARK: - Notifications
let kPlaylistChangedNotification = "PlaylistChangedNotification"
let kPlaylistGeneratedNotification = "PlaylistGeneratedNotification"
let kSelectSongsRenamedNotification = "SelectSongsRenamedNotification"
let kSelectFastForwardNotification = "SelectFastForwardNotification"
let kVolumeChangedNotification = "VolumeChangedNotification"
let kSystemVolumeChangedNotification = "AVSystemController_SystemVolumeDidChangeNotification"
let kPlaylistRemovedNotification = "PlaylistRemovedNotification"
let kSelectSongsChangedNotification = "SelectSongsChangedNotification"
let kProductPurchasedNotification = "ProductPurchasedNotification"
let kPurchaseFailedNotification = "PurchaseFailedNotification"
let kBrowserChangedNotification = "BrowserChangedNotification"

// MARK: - RTMP Connection
let kRTMPConnections = "RTMPConnections"
let kRTMPCurrentConnectionIndex = "RTMPCurrentConnectionIndex"
