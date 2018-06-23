//
//  VC_PlayView.swift
//  Aarti In Hindi
//
//  Created by Piyush Kachariya on 6/17/18.
//  Copyright © 2018 kachariyainfotech. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    @IBOutlet weak var mySwitch: UISwitch!
    
    @IBOutlet weak var label: UILabel!
    
    var is_switch_on : Bool = true
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "fe6dcf6c5f800b881af6edc70424173c"
    let APP_ID_TESt = "e72ca729af228beabd5d20e3b7749713"


    //TODO: Declare instance variables here
    
    var locatoinManager = CLLocationManager()
    
    var weatherDataModel = WeatherDataModel()
    
    
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locatoinManager.delegate = self
        locatoinManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locatoinManager.requestWhenInUseAuthorization()
        
        locatoinManager.startUpdatingLocation()
        
        
        
        
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, params: [String : String]) {
        
        
        
        Alamofire.request(url, method: .get, parameters: params)
            .responseJSON { response in
                
                if response.result.isSuccess {
                    
                    print("We got it")
                    
                    let weatherJSON : JSON = JSON(response.result.value!)
                    print(weatherJSON)
                    self.updateWeatherData(json: weatherJSON)
                }
                else {
                    print("Error \(String(describing: response.result.error))")
                    self.cityLabel.text = "Connection Problem"
                }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON)
    {
        if let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].int!
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
        }
        else{
            
            cityLabel.text = "Weather Unavailable"
        }
        
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:

    
    
    func updateUIWithWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        
        temperatureLabel.text = "\(String(weatherDataModel.temperature)) ℃"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        
        if (sender.isOn == false){
            print("on")
            mySwitch.isOn = false
            is_switch_on = false
            
            temperatureLabel.text = "\(String(convertToFahrenheit(celsius: weatherDataModel.temperature))) ℉"



        }
        else{
            
            print("off")
            mySwitch.isOn = true
            is_switch_on = true

            temperatureLabel.text = "\(String(weatherDataModel.temperature)) ℃"


        }
        
    }
    
    func convertToFahrenheit(celsius: Int) -> Int {
        return Int(Double(celsius) * 1.8) + 32
    }


    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
   
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        let location = locations[locations.count - 1]
        
        
        if location.horizontalAccuracy > 0 {
            
            locatoinManager.stopUpdatingLocation()
            locatoinManager.delegate = nil
            
            print("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
            
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            let obj : [String : String] = ["lat": String(lat), "lon": String(long), "appid" : APP_ID]
            
            
            getWeatherData(url: WEATHER_URL, params: obj)
            
            
        }
        
    }
    
    
 
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Location did not found" + error.localizedDescription)
        
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnterNewCityName(city: String) {
        
        print(city)
        
        let perams : [String: String] = ["q" : city, "appid" : APP_ID]

        getWeatherData(url: WEATHER_URL, params: perams)
    }
    
    //Write the PrepareForSegue Method here
    
    @IBAction func btn_city_clcked(_ sender: UIButton){
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangeCityViewController") as? ChangeCityViewController
        vc?.delegate = self
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.navigationController!.view.layer.add(transition, forKey: nil)
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "changeCityName" {
            let desinationVC = segue.destination as! ChangeCityViewController
            desinationVC.delegate = self
            
        }
        
    }
    
    
    
}


