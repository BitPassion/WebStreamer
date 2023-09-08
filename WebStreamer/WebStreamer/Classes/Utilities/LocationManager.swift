//
//  LocationManager.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 7/26/22.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var isRequestedWeather = false
    
    private(set) var latitude: Double = 0
    private(set) var longitude: Double = 0
    private(set) var currentTemp: String = ""
    private(set) var weathers: [String] = []
    private(set) var currentWeather: String = ""
    private(set) var weatherIndex: Int = 0
    
    fileprivate var weatherTimer: Timer? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (UIDevice.current.systemVersion as NSString).floatValue >= 8.0 {
            locationManager.requestAlwaysAuthorization()
        }
        
        startWeatherTimer()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func getWeatherData() {
        if latitude == 0.0, longitude == 0.0 {
            return
        }
        
        let requestString = "https://forecast.weather.gov/MapClick.php?lat=\(latitude)&lon=\(longitude)&FcstType=json"
        var request = URLRequest(url: URL(string: requestString)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                self.parseForecastJSON(data)
            }
        }
        
        task.resume()
        
        let currentTime = Date()
        UserDefaults.standard.set(currentTime, forKey: "WeatherUpdate")
    }

    func parseForecastJSON(_ jsonData: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: Any]
            if let currentObservationDict = json["currentobservation"] as? [String: Any] {
                currentTemp = currentObservationDict["Temp"] as! String
            } else {
                currentTemp = ""
            }
            
            if let periodDict = json["time"] as? [String: Any], let weatherDict = json["data"] as? [String: Any] {
                // weather
                let periodArray = periodDict["startPeriodName"] as! [String]
                let weatherArray = weatherDict["text"] as! [String]
                let weatherPropertyArray = weatherDict["weather"] as! [String]
                
                if periodArray.count > 0, weatherArray.count > 0, weatherPropertyArray.count > 0 {
                    weathers.removeAll()
                    
                    var nCount = 5
                    if periodArray.count > 5 {
                        nCount = 5
                    } else {
                        nCount = periodArray.count
                    }
                    
                    for i in 0 ..< nCount {
                        let periodName = periodArray[i]
                        let weather = weatherArray[i]
                        
                        let weatherString = "My Oh S Weather for \(periodName), look for \(weather)"
                        weathers.append(weatherString)
                    }
                    
                    nCount = weathers.count
                    
                    for i in stride(from: nCount - 1, to: 1, by: -1) {
                        let j = Int.random(in: 0 ..< i + 1)
                        weathers.swapAt(j, i)
                    }
                    
                    // current contitions
                    currentWeather = weatherPropertyArray[0]
                    if currentWeather.contains("Slight Chance") {
                        currentWeather = currentWeather.replacingOccurrences(of: "Slight Chance", with: "a Slight Chance of")
                    } else if currentWeather.contains("Chance") {
                        currentWeather = currentWeather.replacingOccurrences(of: "Chance", with: "a Chance of")
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
            weathers.removeAll()
            
            currentTemp = ""
            currentWeather = ""
            
            // exception processing for ME
            // latitude = 48.899408
            // longitude = -115.172115
            getWeatherData()
        }
    }

    func getWeatherString() -> String {
        var weahterString = ""

        if weathers.count > 0 {
            if weatherIndex >= weathers.count {
                weatherIndex = 0
            }
            
            weahterString = weathers[weatherIndex].lowercased()

            weatherIndex += 1
            if weatherIndex >= weathers.count {
                weatherIndex = 0
            }
        }

        return weahterString
    }
    
    fileprivate func startWeatherTimer() {
        stopWeatherTimer()
        weatherTimer = Timer.scheduledTimer(timeInterval: 60 * 10, target: self, selector: #selector(updateWeather(_:)), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopWeatherTimer() {
        if let timer = weatherTimer {
            timer.invalidate()
            weatherTimer = nil
        }
    }
    
    @objc fileprivate func updateWeather(_ timer: Timer) {
        getWeatherData()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        locationManager.stopUpdatingLocation()
        
        let lastUpdate = UserDefaults.standard.object(forKey: "WeatherUpdate") as? Date
        if !isRequestedWeather || (lastUpdate != nil && Date().timeIntervalSince(lastUpdate!) >= 60 * 10)
        {
            getWeatherData()
            
            isRequestedWeather = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentTemp = ""
        currentWeather = ""
        weathers.removeAll()
    }
}
