//
//  ViewController.swift
//  Project16
//
//  Created by Brian Coleman on 2022-04-06.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the city of light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washinton DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himeself.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(selectMapType))
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        
        let identifier = "Capital"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.pinTintColor = .yellow
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        let vc = WebViewController()
        vc.countryName = capital.title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectMapType() {
        let ac = UIAlertController(title: "Select Map Type", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: {_ in
            self.mapView.mapType = .standard
        }))
        ac.addAction(UIAlertAction(title: "Muted Standard", style: .default, handler: {_ in
            self.mapView.mapType = .mutedStandard
        }))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: {_ in
            self.mapView.mapType = .satellite
        }))
        ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default, handler: {_ in
            self.mapView.mapType = .satelliteFlyover
        }))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: {_ in
            self.mapView.mapType = .hybrid
        }))
        ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: {_ in
            self.mapView.mapType = .hybridFlyover
        }))
        present(ac, animated: true)
    }
}
