//
//  ViewController.swift
//  HaritaUygulamasi
//
//  Created by ertugrul on 29.07.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var isimTextField: UITextField!
    
    var locationManager = CLLocationManager()
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitel = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    var latitude = Double()
    var longitude = Double()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gesterRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        
        if secilenIsim != ""{
            // CORE DATA DAN VERİ GENDİ.
            
            filtrelemeIleVeriCekme()
            
          //  print("bura calıştı")
        }else{
            // YENİ VERİ EKLE
        //    print("burası çalıştı")
            
        }
    }
    
    @objc func konumSec(gesterRecognizer : UILongPressGestureRecognizer){
        if gesterRecognizer.state == .began{
            let dokunulanNokta = gesterRecognizer.location(in: mapView)
            let dokunulanKordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            secilenLatitude = dokunulanKordinat.latitude
            secilenLongitude = dokunulanKordinat.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKordinat
            annotation.title = isimTextField.text
            annotation.subtitle = notTextField.text
            mapView.addAnnotation(annotation)
        }
    }
    
    func filtrelemeIleVeriCekme(){
        if let gelenUudiString = secilenId?.uuidString {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fechRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            
            fechRequest.predicate = NSPredicate(format: "id = %@", gelenUudiString)
            fechRequest.returnsObjectsAsFaults = false
            
            
            do{
                let sonucler = try context.fetch(fechRequest)
                if sonucler.count > 0{
                    for sonuc in sonucler as! [NSManagedObject]{
                        if let isim = sonuc.value(forKey: "isim") as? String{
                            annotationTitle = isim
                            
                            if let not = sonuc.value(forKey: "not") as? String{
                                annotationSubtitel = not
                                
                                if let nlatitude = sonuc.value(forKey: "latitude") as? Double{
                                    annotationLatitude = nlatitude
                                    
                                    if let nlongitude = sonuc.value(forKey: "longitude") as? Double{
                                        annotationLongitude = nlongitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitel
                                        
                                        let cordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = cordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        isimTextField.text = annotationTitle
                                        notTextField.text = annotationSubtitel
                                        
                                        latitude = annotationLatitude
                                        longitude = annotationLongitude
                                        
                                        print("annotation eklendi")
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
              print("HATA VAR...")
            }
        }
    }
    
    
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isimTextField.text == ""{
        latitude = locations[0].coordinate.latitude
        longitude = locations[0].coordinate.longitude
        }
       // print(latitude)
        //print(longitude)
        
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)

    }
    
    
    @IBAction func kaydetTiklandi(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        
        do{
            try context.save()
            print("kayıt tamam")
        }catch{
            print("Hata var..")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    

}

