//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate,CityChangeDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "0df2ee4eca3a793239534a5a145f74d3"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func createURL(param:[String:String]) -> URL? {
        let urlComponents = URLComponents(string: WEATHER_URL)
        var queryItems = [URLQueryItem]()
        for item in param{
            queryItems.append(URLQueryItem(name: item.key, value: item.value))
        }
        guard var components = urlComponents else { return nil }
        components.queryItems = queryItems
        return components.url
        
    }
    func getWeatherData(url:URL) {
        let request = Alamofire.request(url)
        request.responseJSON {
            response in
            if response.result.isSuccess{
                let weatherResult : JSON = JSON(response.result.value!)
                self.updateUIWithWeatherData(dataModel: self.updateWeatherData(json: weatherResult))
            }
            else{
                print("Error : \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection issue"
            }
        }
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON) -> WeatherDataModel? {
        let model = WeatherDataModel(json: json)
        if model.weatherIconName ==  ""{
            cityLabel.text = "Weather Unavailable"
            return nil
        }
        return model
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(dataModel : WeatherDataModel?){
        guard let model = dataModel else { return }
        cityLabel.text = model.city
        temperatureLabel.text = String(model.temperature)
        weatherIcon.image = UIImage(named: model.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("Latitude = \(location.coordinate.latitude) and Longitude = \(location.coordinate.longitude)")
            let params:[String:String] = ["lat" : String(location.coordinate.latitude), "lon" : String(location.coordinate.longitude), "appid" : APP_ID]
            if let weatherUrl = createURL(param: params){
                getWeatherData(url: weatherUrl)
            }
            else{
                print()
            }
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavilable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(_ cityName: String?) {
        let params:[String:String] = ["q":cityName!,"appid":APP_ID]
        guard let url = createURL(param: params) else { return  }
        getWeatherData(url:url)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let controller = segue.destination as! ChangeCityViewController
            controller.delegate = self
        }
    }
    
    
    
    
}


