//
//  ViewController.swift
//  GeoMarker
//
//  Created by Игорь Ущин on 16.07.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
   
    private var mapView: MKMapView = {
      let map = MKMapView()
      map.showsUserLocation = true
      map.userTrackingMode = .follow
      map.translatesAutoresizingMaskIntoConstraints = false
      return map
      }()
    
    lazy private var pinButton: UIButton = {
      let button = UIButton()
      button.setImage(UIImage(named: "gps-icon"), for: .normal)
    
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addTarget(self, action: #selector(showMyLocations), for: .touchUpInside)
      return button
  }()
    
    lazy private var addLocationButton: UIButton = {
      let button = UIButton()
      button.setImage(UIImage(named: "globe-icon"), for: .normal)
      button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(addAdressButtonTaped), for: .touchUpInside)
      return button
      }()
    
    lazy private var resetButton: UIButton = {
      let button = UIButton()
      button.setImage(UIImage(named: "denied-icon"), for: .normal)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
      button.isHidden =  true
      return button
  }()
    
    lazy private var routeButton: UIButton = {
      let button = UIButton()
      button.setImage(UIImage(named: "windy-icon"), for: .normal)
      button.isHidden =  true
      button.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
      button.translatesAutoresizingMaskIntoConstraints = false
      return button
  }()
    
    var locationManager: CLLocationManager!
    var annotationArray =  [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        setCon()
        configuration()
        
    }
   
    //MARK: - Configurations
    func setView(){
        view.addSubview(mapView)
        mapView.addSubview(addLocationButton)
        mapView.addSubview(pinButton)
        mapView.addSubview(resetButton)
        mapView.addSubview(routeButton)
    }
    func configuration(){
        locationManager =  CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
    }
    
    //MARK: - Selectors
    @objc func addAdressButtonTaped(){
        alertAddAdress(title: "Добавить адрес", placeholder: "Введите адрес") { [self] (text) in
            setupPlacemark(adressPlace: text)
        }
    }
    
    @objc func showMyLocations(){
        setMapOnUser()
    }
    
    @objc func routeButtonTapped(){
        for index in 0...annotationArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationArray[index].coordinate, destinationCoordinate: annotationArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationArray, animated: true)
    }
   
    @objc func resetButtonTapped(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    //MARK: - Methods
    private func setupPlacemark(adressPlace: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
            if let error =  error {
                print(error)
                alertError(title: "Ошибка", message: "Попробуйте добавить адрес еще раз")
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationArray.append(annotation)
            
            if annotationArray.count > 1 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            mapView.showAnnotations(annotationArray, animated: true)
        }
    }
    //Setup route loc.
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (responce, error) in
            if let error =  error {
                print(error)
                return
            }
            guard let responce =  responce else {
                self.alertError(title: "Ошибка", message: "Маршрут недоступен")
                return
            }
            
            var minRoute = responce.routes[0]
            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
// Setup User location
  private func setMapOnUser() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region =  MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - Delegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            print("unknown error")
        }
    }
}

//MARK: - Setup Constraints
extension MapViewController {
    func setCon(){
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
                                    ])
        
        NSLayoutConstraint.activate([
            addLocationButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor,constant: -55),
            addLocationButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 30),
            addLocationButton.widthAnchor.constraint(equalToConstant: 64),
            addLocationButton.heightAnchor.constraint(equalToConstant: 64)
                                    ])
        NSLayoutConstraint.activate([
            pinButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor,constant: -55),
            pinButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            pinButton.widthAnchor.constraint(equalToConstant: 64),
            pinButton.heightAnchor.constraint(equalToConstant: 64)
                                    ])
        
        NSLayoutConstraint.activate([
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor,constant: -55),
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 100),
            routeButton.widthAnchor.constraint(equalToConstant: 64),
            routeButton.heightAnchor.constraint(equalToConstant: 64)
                                    ])
        
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: mapView.topAnchor,constant: 50),
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            resetButton.widthAnchor.constraint(equalToConstant: 55),
            resetButton.heightAnchor.constraint(equalToConstant: 55)
                                    ])
    }
}
//MARK: - Extension
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
}
