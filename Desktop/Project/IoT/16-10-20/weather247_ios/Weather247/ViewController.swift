//
//  ViewController.swift
//  Weather247
//
//  Created by jogja247 on 9/29/16.
//  Copyright © 2016 Solusi247. All rights reserved.
//

import UIKit
import SwiftMQTT
import SwiftyJSON
import Alamofire
import Social

class ViewController:UIViewController, MQTTSessionDelegate, UITableViewDataSource {

    var mqttSession: MQTTSession!

    var TableData:Array< lastFive > = Array < lastFive >()
    
    enum ErrorHandler:Error
    {
        case ErrorFetchingResults
    }
    
    struct lastFive
    {
        var date:String
        var temp:String
        var hum:String
        var dewp:String
        var airp:String
        
        init(date1: String, temp1: String, hum1: String, dewp1: String, airp1: String)
        {
            date = date1
            temp = temp1
            hum = hum1
            dewp = dewp1
            airp = airp1
        }
    }
    
    var thmString = String()
    
    @IBOutlet weak var dateTime: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var dpLabel: UILabel!
    @IBOutlet weak var apLabel: UILabel!
    
    @IBOutlet weak var upTemp: UILabel!
    @IBOutlet weak var downTemp: UILabel!
    
    @IBOutlet weak var loadingImage: UIActivityIndicatorView!
    @IBOutlet weak var imagePrakiraan: UIImageView!
    @IBOutlet weak var labelPrakiraan: UILabel!
    
    
    @IBOutlet weak var fiveLast: UITableView!
    
    open func mqttDidReceive(message data: Data, in topic: String, from session: MQTTSession) {
        let string = String(data: data, encoding: .utf8)!
        
        if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            //print("JSON = \(json)")
            let x = json["thm"].double, xFormat = ".1"
            let x1 = json["thm"].double, x1Format = "."
            let xx = json["hum"].double, xxFormat = ".1"
            let xxx = json["dp"].double, xxxFormat = ".1"
            let xxxx = json["ap"].double! / 100000, xxxxFormat = ".1"
            tempLabel.text = (x?.format(xFormat))!
            humLabel.text = (xx?.format(xxFormat))! + " %"
            dpLabel.text = (xxx?.format(xxxFormat))! + " °C"
            apLabel.text = (xxxx.format(xxxxFormat)) + " Bar"
            thmString = (xxx?.format(xFormat))! + " °C"
            
            let defaults = UserDefaults.standard
            
            if let tmin = defaults.string(forKey: "mintemp") {
                print("minimal toogle \(tmin)")
                let minimal = defaults.double(forKey: "mintemp")
                if Double((x1?.format(x1Format))!)! < minimal {
                    defaults.set(Double((x1?.format(x1Format))!)!, forKey: "mintemp")
                }
            }
            else {
                defaults.set(Double((x1?.format(x1Format))!)!, forKey: "mintemp")
                
            }
            
            if let tmax = defaults.string(forKey: "maxtemp") {
                print("maximal toogle \(tmax)")
                let maximal = defaults.double(forKey: "maxtemp")
                if Double((x1?.format(x1Format))!)! > maximal {
                    defaults.set(Double((x1?.format(x1Format))!)!, forKey: "maxtemp")
                }
            }
            else {
                defaults.set(Double((x1?.format(x1Format))!)!, forKey: "maxtemp")
            }
            
            let min: String = defaults.string(forKey: "mintemp")!
            print("suhu min \(min)")
            downTemp.text = min + " °C"
            
            let max: String = defaults.string(forKey: "maxtemp")!
            print("suhu max \(max)")
            upTemp.text = max + " °C"

            
            
            
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let min = defaults.string(forKey: "mintemp") {
            downTemp.text = min + " °C"
            print("suhu min awal \(min)")
        }
        if let max = defaults.string(forKey: "maxtemp") {
            upTemp.text = max + " °C"
            print("suhu max awal \(max)")

        }

        loadingImage.hidesWhenStopped = true
//        getbmkg()
        get_last5()

        self.fiveLast.estimatedRowHeight = 44
        self.fiveLast.rowHeight = UITableViewAutomaticDimension
        self.fiveLast.dataSource = self

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.title = "Yogyakarta"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        
        establishConnection()
        
        let datetime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy"
        let result = formatter.string(from: datetime as Date)
        dateTime.text = result
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBackground()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func shareButton(_ sender: AnyObject) {
        print("Share")
        fb()
    }
    
    func fb() {
        let screen = UIScreen.main
        
        if let window = UIApplication.shared.keyWindow {
            UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            share(shareText: "#weather247", shareImage: image)
        }
    }
    
    
    func share(shareText:String?,shareImage:UIImage?){
        var objectsToShare = [AnyObject]()
        
        if let shareTextObj = shareText{
            objectsToShare.append(shareTextObj as AnyObject)
        }
        
        if let shareImageObj = shareImage{
            objectsToShare.append(shareImageObj)
        }
        if shareText != nil || shareImage !=  nil {
            print("object to share \(objectsToShare)")
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            present(activityViewController, animated: true, completion: nil)
        }else{
            print("There is nothing to share")
        }
    }
    
    func setBackground(){
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        let imageView = UIImageView(frame: self.view.bounds)
        
        if hour < 6 {
            get_detail_cuaca_diy(idx: 0)
            imageView.image = UIImage(named: "bg_1")//if its in images.xcassets
        }else if hour >= 6 && hour < 15{
            get_detail_cuaca_diy(idx: 1)
            imageView.image = UIImage(named: "bg_2")//if its in images.xcassets
        }else if hour >= 15 && hour < 18{
            get_detail_cuaca_diy(idx: 2)
            imageView.image = UIImage(named: "bg_3")//if its in images.xcassets
        }else if hour >= 18{
            get_detail_cuaca_diy(idx: 3)
            imageView.image = UIImage(named: "bg_4")//if its in images.xcassets
        }
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    func getbmkg(){
        print("get_bmkg")
        loadingImage.startAnimating()
        Alamofire.request("http://192.168.1.144/mqttwebsocket/bmkg/api.php").validate().responseJSON { response in
            switch response.result {
            case .success:
                let data = JSON(response.result.value)
                self.loadingImage.stopAnimating()
                if data["status"].string != "error"{
                    let datax = data["data"]
                    let data35 = datax[35]
                    let prakiraan = data35["prakiraan"]["sekarang"]["cuaca"].string
                    
                    //print("data cuaca: \(data["data"])")
                    print("data ke 35: \(data35)")
                    print("prakiraan: \(prakiraan!)")
                    
                    let value = prakiraan!
                    
                    switch (value)
                    {
                    case "Cerah":
                        print("Cerah")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_cerah")
                        self.labelPrakiraan.text = value
                        
                    case "Cerah Berawan":
                        print("Cerah Berawan")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_cerahberawan")
                        self.labelPrakiraan.text = value
                        
                    case "Berawan":
                        print("Berawan")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_berawan")
                        self.labelPrakiraan.text = value
                        
                    case "Berawan Tebal":
                        print("Berawan Tebal")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_berawantebal")
                        self.labelPrakiraan.text = value
                        
                    case "Hujan Ringan":
                        print("Hujan Ringan")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_hujanringan")
                        self.labelPrakiraan.text = value
                        
                    case "Hujan Sedang":
                        print("Hujan Sedang")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_hujansedang")
                        self.labelPrakiraan.text = value
                        
                    case "Hujan Lokal":
                        print("Hujan Lokal")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_hujanlokal")
                        self.labelPrakiraan.text = value
                        
                    case "Hujan Lebat":
                        print("Hujan Lebat")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_hujanlebat")
                        self.labelPrakiraan.text = value
                        
                    case "Hujan Petir":
                        print("Hujan Petir")
                        self.loadingImage.stopAnimating()
                        self.imagePrakiraan.image = UIImage(named: "icon_hujanpetir")
                        self.labelPrakiraan.text = value
                        
                    default:
                        print("Integer out of range")
                    }
                }else{
                    print("Status Offline")
                    self.imagePrakiraan.image = UIImage(named: "icon_berawan")
                    self.labelPrakiraan.text = "BMKG offline"
                }
                
            case .failure(let error):
                print(error)
                print("Validation Failed")
            }
        }
    }
    
    
    func get_detail_cuaca_diy(idx: Int){
        print("get_detail_cuaca_diy")
        loadingImage.startAnimating()
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
       
        print("\(year)-\(month)-\(day)T\(hour):00:00Z")

//        let detailcuacabmkg = "http://192.168.1.144/mqttwebsocket/bmkg/detail_cuaca_diy.php"
        
//        Alamofire.request(detailcuacabmkg).responseJSON { response in

        Alamofire.request("http://192.168.1.144/mqttwebsocket/bmkg/detail_cuaca_diy.php").validate().responseJSON { response in
            switch response.result {
            case .success:
            print(response.result)
            print("Alamofire")
            let data = JSON(response.result.value)
                if data["status"].string != "error"{
                let datax = data["data"]
                let datai = datax[idx]
                let prakiraan = datai["status"].string
                
                print("data ke 35: \(datai)")
                print("prakiraan: \(prakiraan!)")
                
                let value = prakiraan!
                
                switch (value)
                {
                case "Cerah":
                    print("Cerah")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_cerah")
                    self.labelPrakiraan.text = value
                    
                case "Cerah Berawan":
                    print("Cerah Berawan")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_cerahberawan")
                    self.labelPrakiraan.text = value
                    
                case "Berawan":
                    print("Berawan")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_berawan")
                    self.labelPrakiraan.text = value
                    
                case "Berawan Tebal":
                    print("Berawan Tebal")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_berawantebal")
                    self.labelPrakiraan.text = value
                    
                case "Hujan Ringan":
                    print("Hujan Ringan")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_hujanringan")
                    self.labelPrakiraan.text = value
                    
                case "Hujan Sedang":
                    print("Hujan Sedang")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_hujansedang")
                    self.labelPrakiraan.text = value
                
                case "Hujan Lokal":
                    print("Hujan Lokal")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_hujanlokal")
                    self.labelPrakiraan.text = value
                    
                case "Hujan Lebat":
                    print("Hujan Lebat")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_hujanlebat")
                    self.labelPrakiraan.text = value
                    
                case "Hujan Petir":
                    print("Hujan Petir")
                    self.loadingImage.stopAnimating()
                    self.imagePrakiraan.image = UIImage(named: "icon_hujanpetir")
                    self.labelPrakiraan.text = value
                    
                default:
                    print("Integer out of range")
                }
                }else{
                    print("Status Offline")
                    self.loadingImage.stopAnimating()
                }
                
            case .failure(let error):
                print(error)
                print("Validation Failed")
            }
            
        }
    }

    func get_last5(){
        print("get_last5")
        let last5 = "http://192.168.1.144/mqttwebsocket/getlastsolr.php"
        Alamofire.request(last5).responseJSON { response in
            if let x = response.result.value {
                
                let data = JSON(x)
                print("JSON: \(data)")
                for (index,subJson):(String, JSON) in data["data"] {
                    
                    let dateJSON = subJson["date"]
                    let thmJSON = subJson["thm"]
                    let humJSON = subJson["hum"]
                    let dewpJSON = subJson["dp"]
                    let airpJSON = subJson["ap"]
                    
                    self.TableData.append(lastFive(date1: "\(dateJSON)", temp1: "\(thmJSON)", hum1: "\(humJSON)", dewp1: "\(dewpJSON)", airp1: "\(airpJSON)"))
                    
                    print(self.TableData)
                    self.do_table_refresh()
                }
            }
        }
    }
    
 
    func do_table_refresh(){
        //        dispatch_get_main_queue() {
        self.fiveLast.reloadData()
        return
        //        }
    }
    
    func establishConnection() {
        let host = "192.168.1.144"
        let port: UInt16 = 1883
        let clientID = self.clientID()
        
        mqttSession = MQTTSession(host: host, port: port, clientID: clientID, cleanSession: true, keepAlive: 15, useSSL: false)
        mqttSession.delegate = self
        appendStringToTextView("Trying to connect to \(host) on port \(port) for clientID \(clientID)")
        
        mqttSession.connect {
            if !$0 {
                self.appendStringToTextView("Error Occurred During connection \($1)")
                return
            }
            self.appendStringToTextView("Connected.")
            self.subscribeToChannel()
        }
    }
    
    func subscribeToChannel() {
        let subChannel = "topik"
        mqttSession.subscribe(to: subChannel, delivering: .atMostOnce) {
            if !$0 {
                self.appendStringToTextView("Error Occurred During subscription \($1)")
                return
            }
            self.appendStringToTextView("Subscribed to \(subChannel)")
        }
    }
    
    func appendStringToTextView(_ string: String) {
        /*textView.text = "\(textView.text ?? "")\n\(string)"
         let range = NSMakeRange(textView.text.characters.count - 1, 1)
         textView.scrollRangeToVisible(range)*/
        print(string)
    }
    
    // MARK: - MQTTSessionDelegates
    
    func mqttSession(_ session: MQTTSession, received message: Data, in topic: String) {
        let string = String(data: message, encoding: .utf8)!
        print(string)
        //appendStringToTextView("data received on topic \(topic) message \(string)")
    }
    
    func mqttSocketErrorOccurred(session: MQTTSession) {
        //appendStringToTextView
        print("Socket Error")
    }
    
    func mqttDidDisconnect(session: MQTTSession) {
        //appendStringToTextView
        print("Session Disconnected.")
    }
    
    // MARK: - Utilities
    
    func clientID() -> String {
        
        let userDefaults = UserDefaults.standard
        let clientIDPersistenceKey = "clientID"
        let clientID: String
        
        if let savedClientID = userDefaults.object(forKey: clientIDPersistenceKey) as? String {
            clientID = savedClientID
        } else {
            clientID = randomStringWithLength(5)
            userDefaults.set(clientID, forKey: clientIDPersistenceKey)
            userDefaults.synchronize()
        }
        
        return clientID
    }
    
    // http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    func randomStringWithLength(_ len: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters)
        
        var randomString = String()
        for _ in 0..<len {
            let length = UInt32(letters.count)
            let rand = arc4random_uniform(length)
            randomString += String(letters[Int(rand)])
        }
        return String(randomString)
    }
    
    //Tableview
    internal func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.TableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FiveLastTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! FiveLastTableViewCell
        
        let data = self.TableData[indexPath.row]
        let x = data.date
        let dateString = x
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        let dateObj = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "HH:mm"
        print("Dateobj: \(dateFormatter.string(from: dateObj!))")
        
        let xx = Float(data.temp)!
        let xxx = Float(data.hum)!
        let xxxx = Float(data.dewp)!
        let xxxxx = Float(data.airp)!/100000
        
        cell.backgroundColor = UIColor(white: 1, alpha: 0.4)
        cell.timeLabel!.text = dateFormatter.string(from: dateObj!)
        cell.tempLabel!.text = String(format: "%.1f", xx) + " °C"
        cell.humLabel!.text = String(format: "%.1f", xxx) + " %"//data.hum//xxx.description
        cell.dpLabel!.text = String(format: "%.1f", xxxx) + " °C"//data.dewp//xxxx.description
        cell.apLabel!.text = String(format: "%.1f", xxxxx) + " Bar"//data.airp//xxxxx.description
        //cell.dynamicLabel.font  = UIFont.preferredFont(forTextStyle: UIFontTextStyleBody)
        
        return cell
    }
    
    
}


