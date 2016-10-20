//
//  ViewGempa.swift
//  Weather247
//
//  Created by jogja247 on 10/10/16.
//  Copyright © 2016 Solusi247. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import MapKit
//import Nuke

class ViewGempa: UIViewController, UITableViewDataSource {
    @IBOutlet weak var mapGempa: MKMapView!
    
    @IBOutlet weak var labelWaktu: UILabel!
    @IBOutlet weak var labelTanggal: UILabel!
    
    @IBOutlet weak var labelMagnitudo: UILabel!
    @IBOutlet weak var labelKedalaman: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    @IBOutlet weak var labelDetail1: UILabel!
    @IBOutlet weak var tabelGempa: UITableView!

    //Loading
    @IBOutlet weak var loadWaktu: UIActivityIndicatorView!
    @IBOutlet weak var loadMagnitudo: UIActivityIndicatorView!
    @IBOutlet weak var loadKedalaman: UIActivityIndicatorView!
    
    var TableData:Array< gempadirasakan > = Array < gempadirasakan >()
    var TableData1:Array< gempaterkini > = Array < gempaterkini >()
    
    enum ErrorHandler:Error
    {
        case ErrorFetchingResults
    }
    
    struct gempadirasakan
    {
        var lokasi:String
        var dirasakan:String
        var img:String
        var kedalaman:String
        var tgl:String
        var waktu:String
        var magnitudo:String
        var latlong:String
        
        init(lokasi1: String, dirasakan1: String, img1: String, kedalaman1: String, tgl1: String, waktu1: String, magnitudo1: String, latlong1: String)
        {
            lokasi = lokasi1
            dirasakan = dirasakan1
            img = img1
            kedalaman = kedalaman1
            tgl = tgl1
            waktu = waktu1
            magnitudo = magnitudo1
            latlong = latlong1
        }
    }
    
    struct gempaterkini
    {
        var date:String
        var lat:String
        var lon:String
        var kedalaman:String
        var magnitudo:String
        var wilayah:String
        
        init(date1: String, lat1: String, lon1: String, kedalaman1: String, magnitudo1: String, wilayah1: String)
        {
            date = date1
            lat = lat1
            lon = lon1
            kedalaman = kedalaman1
            magnitudo = magnitudo1
            wilayah = wilayah1
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWaktu.hidesWhenStopped = true
        loadMagnitudo.hidesWhenStopped = true
        loadKedalaman.hidesWhenStopped = true
        
        self.tabelGempa.estimatedRowHeight = 80
        self.tabelGempa.rowHeight = UITableViewAutomaticDimension
        self.tabelGempa.dataSource = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
//        self.navigationController?.navigationBar.backgroundColor = UIColor(white: 1, alpha: 0.1)
      
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        
        setBackground()
        
//        get_gempa_bmkg()
        get_gempa_terkini_bmkg()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func zoomToRegion(lat: Double, lon: Double, title: String, subtitle: String) {
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        // Drop a pin
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = title
        dropPin.subtitle = subtitle
        mapGempa.addAnnotation(dropPin)
    }
    
    
    
    func get_gempa_bmkg(){
        loadWaktu.startAnimating()
        loadMagnitudo.startAnimating()
        loadKedalaman.startAnimating()
        
        Alamofire.request("http://192.168.1.144/mqttwebsocket/bmkg/gempa.php").validate().responseJSON { response in
            switch response.result {
            case .success:
                let data = JSON(response.result.value)
                print(data)
                self.loadWaktu.stopAnimating()
                self.loadMagnitudo.stopAnimating()
                self.loadKedalaman.stopAnimating()
                
                
                let url = URL(string: data["data"][0]["img"].string!)
                print(url!)
                
                let string =  data["data"][0]["lintang_bujur"].string!
                let stringLokasi =  data["data"][0]["lokasi"].string!
                
                let index1 = stringLokasi.index(stringLokasi.startIndex, offsetBy: 18)..<stringLokasi.endIndex
                let result = stringLokasi[index1]
                
                let characters = Array(string.components(separatedBy: " "))
                
                var ltg = Double()
                if characters[1] == "LU"{
                    ltg = Double(characters[0])!
                }else{
                    ltg = Double(characters[0])!.negated()
                    print(ltg)
                }
                
                let bjr = Double(characters[2])
                
                let title = "Gempa \(data["data"][0]["magnitudo"].string!)"
                let subtitle = "\(result)"
                self.zoomToRegion(lat: ltg, lon: bjr! , title: title, subtitle: subtitle)
                
                
                
                
//                let wordLokasi = Array(stringLokasi.components(separatedBy: " "))
                
                self.labelWaktu.text = "\(data["data"][0]["waktu"])"
                self.labelTanggal.text = "\(data["data"][0]["tgl"])"
                self.labelDetail.text = "Lokasi: \(result)"/* \(wordLokasi[4]) \(wordLokasi[5]) \(wordLokasi[6])*/
                self.labelDetail1.text = "\(string)"
                self.labelMagnitudo.text = "\(data["data"][0]["magnitudo"])"
                self.labelKedalaman.text = "\(data["data"][0]["kedalaman"])"
                
                for (index,subJson):(String, JSON) in data["data"] {
                    print(index)
                    let lokasiJSON = subJson["lokasi"]
                    let dirasakanJSON = subJson["dirasakan"]
                    let imageJSON = subJson["img"]
                    let kedalamanJSON = subJson["kedalaman"]
                    let tglJSON = subJson["tgl"]
                    let waktuJSON = subJson["waktu"]
                    let magnitudoJSON = subJson["magnitudo"]
                    let latlongJSON = subJson["lintang_bujur"]
                    
                    self.TableData.append(gempadirasakan(lokasi1: "\(lokasiJSON)", dirasakan1: "\(dirasakanJSON)", img1: "\(imageJSON)", kedalaman1: "\(kedalamanJSON)", tgl1: "\(tglJSON)", waktu1: "\(waktuJSON)", magnitudo1: "\(magnitudoJSON)", latlong1: "\(latlongJSON)"))
                    
                    print(self.TableData)
                                        self.do_table_refresh()
                }
                //                self.loadingImage.stopAnimating()
                //                if data["status"].string != "error"{
                //                    let datax = data["data"]
                //                    let data35 = datax[35]
                //                    let prakiraan = data35["prakiraan"]["sekarang"]["cuaca"].string
                //
                //                    //print("data cuaca: \(data["data"])")
                //                    print("data ke 35: \(data35)")
                //                    print("prakiraan: \(prakiraan!)")
                //
                //                    let value = prakiraan!
                //
                //                    switch (value)
                //                    {
                //                    case "Cerah":
                //                        print("Cerah")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_cerah")
                //                        self.labelPrakiraan.text = value
                //
                //                    case "Cerah Berawan":
                //                        print("Cerah Berawan")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_cerahberawan")
                //                        self.labelPrakiraan.text = value
                //
                //                    case "Berawan":
                //                        print("Berawan")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_berawan")
                //                        self.labelPrakiraan.text = value
                //
                //                    case "Berawan Tebal":
                //                        print("Berawan Tebal")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_berawantebal")
                //                        self.labelPrakiraan.text = value
                //
                //                    case "Hujan Ringan":
                //                        print("Hujan Ringan")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_hujanringan")
                //                        self.labelPrakiraan.text = value
                //
                //                    case "Hujan Sedang":
                //                        print("Hujan Sedang")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_hujansedang")
                //                        self.labelPrakiraan.text = value
                //
                //                    case "Hujan Lokal":
                //                        print("Hujan Lokal")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_hujanlokal")
                //                        self.labelPrakiraan.text = value
                //
                //                    case "Hujan Lebat":
                //                        print("Hujan Lebat")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_hujanlebat")
                //                        self.labelPrakiraan.text = value
                //                        
                //                    case "Hujan Petir":
                //                        print("Hujan Petir")
                //                        self.loadingImage.stopAnimating()
                //                        self.imagePrakiraan.image = UIImage(named: "icon_hujanpetir")
                //                        self.labelPrakiraan.text = value
                //                        
                //                    default:
                //                        print("Integer out of range")
                //                    }
                //                }else{
                //                    print("Status Offline")
                //                    self.imagePrakiraan.image = UIImage(named: "icon_berawan")
                //                    self.labelPrakiraan.text = "BMKG offline"
                //                }
                
            case .failure(let error):
                print(error)
                print("Validation Failed")
                self.loadWaktu.stopAnimating()
                self.loadMagnitudo.stopAnimating()
                self.loadKedalaman.stopAnimating()
            }
        }
    }
    
    func get_gempa_terkini_bmkg(){
        loadWaktu.startAnimating()
        loadMagnitudo.startAnimating()
        loadKedalaman.startAnimating()
        
        let gempa_terkini = "http://192.168.1.144/mqttwebsocket/bmkg/gempa_terkini.php"
        //"http://192.168.1.144/mqttwebsocket/bmkg/gempa.php"
        
        Alamofire.request(gempa_terkini).validate().responseJSON { response in
            switch response.result {
            case .success:
                let data = JSON(response.result.value)
                print(data)
                self.loadWaktu.stopAnimating()
                self.loadMagnitudo.stopAnimating()
                self.loadKedalaman.stopAnimating()
                
                
                //                let url = URL(string: data["data"][0]["img"].string!)
                //                print(url!)
                
                let lat =  Double(data["data"][0]["lat"].description)
                let lon =  Double(data["data"][0]["lon"].description)
                let stringWilayah =  data["data"][0]["wilayah"].string!
                //
                //                let index1 = stringLokasi.index(stringLokasi.startIndex, offsetBy: 18)..<stringLokasi.endIndex
                //                let result = stringLokasi[index1]
                
                //                let characters = Array(string.components(separatedBy: " "))
                
                //                var ltg = Double()
                //                if characters[1] == "LU"{
                //                    ltg = Double(characters[0])!
                //                }else{
                //                    ltg = Double(characters[0])!.negated()
                //                    print(ltg)
                //                }
                //
                //                let bjr = Double(characters[2])
                
                let title = "Gempa \(data["data"][0]["magnitudo"].string!) SR"
                let subtitle = "\(stringWilayah)"
                self.zoomToRegion(lat: lat!, lon: lon! , title: title, subtitle: subtitle)
                
                
                
                
                //                let wordLokasi = Array(stringLokasi.components(separatedBy: " "))
                
                self.labelWaktu.text = "\(data["data"][0]["date"])"
                self.labelTanggal.text = "\(data["data"][0]["date"])"
                self.labelDetail.text = "Lokasi: \(stringWilayah)"/* \(wordLokasi[4]) \(wordLokasi[5]) \(wordLokasi[6])*/
                self.labelDetail1.text = "\(stringWilayah)"
                self.labelMagnitudo.text = "\(data["data"][0]["magnitudo"])"
                self.labelKedalaman.text = "\(data["data"][0]["kedalaman"])"
                
                for (index,subJson):(String, JSON) in data["data"] {
                    print(index)
                    let wilayahJSON = subJson["wilayah"]
                    let kedalamanJSON = subJson["kedalaman"]
                    let dateJSON = subJson["date"]
                    let latJSON = subJson["lat"]
                    let magnitudoJSON = subJson["magnitudo"]
                    let lonJSON = subJson["lon"]
                    
                    self.TableData1.append(gempaterkini(date1: "\(dateJSON)", lat1: "\(latJSON)", lon1: "\(lonJSON)", kedalaman1: "\(kedalamanJSON)", magnitudo1: "\(magnitudoJSON)", wilayah1: "\(wilayahJSON)"))
                    
                    print(self.TableData1)
                    self.do_table_refresh()
                }
                
            case .failure(let error):
                print(error)
                print("Validation Failed")
                self.loadWaktu.stopAnimating()
                self.loadMagnitudo.stopAnimating()
                self.loadKedalaman.stopAnimating()
            }
        }
    }
    
    func setBackground(){
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(named: "bg_2")//if its in images.xcassets
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    func do_table_refresh(){
        //        dispatch_get_main_queue() {
        self.tabelGempa.reloadData()
        return
        //        }
    }
    
    @IBAction func shareButton(_ sender: AnyObject) {
        fb()
    }
//    @IBAction func shareButton(_ sender: AnyObject) {
//
//    }
    
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
    
    internal func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    /*func tableView(tableView: UITableView, nu section: Int) -> Int
     {
     //make sure you use the relevant array sizes
     return 5
     }*/
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.TableData1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GempaTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! GempaTableViewCell
        
        let data = self.TableData1[indexPath.row]
        //        let x = data.date
        //        let dateString = x
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        //        let dateObj = dateFormatter.date(from: dateString)
        
        //        dateFormatter.dateFormat = "HH:mm"
        //        print("Dateobj: \(dateFormatter.string(from: dateObj!))")
        
        //        let xx = Float(data.temp)!
        //        let xxx = Float(data.hum)!
        //        let xxxx = Float(data.dewp)!
        //        let xxxxx = Float(data.airp)!/100000
        
        cell.backgroundColor = UIColor(white: 1, alpha: 0.2)
        cell.labelMagnitudo!.text = data.magnitudo
        cell.labelWaktu!.text = data.date //+ " " + data.tgl
        cell.labelLokasi!.text = data.wilayah //+ "/" + data.dirasakan
        
        return cell
    }

   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


