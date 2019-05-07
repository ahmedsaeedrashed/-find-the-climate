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


class WeatherViewController: UIViewController ,CLLocationManagerDelegate,ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "https://samples.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    
    

    //TODO: Declare instance variables here
    
    let locationManeger = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        
        locationManeger.delegate = self
        locationManeger.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManeger.requestWhenInUseAuthorization() // to take permision to use gps and is used by given to thing the first that using privecy : use location desctibtion to use locaiton
        locationManeger.startUpdatingLocation()  // this function used to start updating location and it will be by using longtitude lnd latitiude
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
   
    
    func getWeatherData(url:String ,parameter: [String: String])
    {
        Alamofire.request(url , method: .get, parameters: parameter).responseJSON { (response) in
            if response.result.isSuccess{
                print("Sucess")
                let JsonWeatherData:JSON = JSON(response.result.value!)
                print(JsonWeatherData)
                
                self.updateWeatherData(json: JsonWeatherData)
                
            }
            else{
                print(response.result.error!)
                self.cityLabel.text = "Connection Issue"
                
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON)
    {
        if let tempResult = json["main"]["temp"].double
        {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            weatherDataModel.city = json["name"].stringValue
            
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Weather Unavalible"
        }
        
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData()
    {
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        if location.horizontalAccuracy > 0
        {
            locationManeger.stopUpdatingLocation()
            locationManeger.delegate = nil
            print("latitude : \(location.coordinate.latitude)" , "longitude : \(location.coordinate.longitude)")
            
            let latitude = String (location.coordinate.latitude)
            let longitude = String (location.coordinate.longitude)
            
            let params : [String:String] = ["lat" : latitude , "lon" : longitude ,"appid" : APP_ID ]
            
            getWeatherData(url: WEATHER_URL ,parameter: params)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("this from didfailwitherror func \(error.localizedDescription)")
        cityLabel.text = "Location Unavialble"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnterANewCityName(city: String)
    {
        let parameter : [String:String] = ["q":city ,"appid": APP_ID]
        getWeatherData(url: WEATHER_URL , parameter: parameter)
    }
    
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "changeCityName"
        {
            let destination = segue.destination as! ChangeCityViewController
            destination.delegate = self
        }
    }
    
    
    
}


