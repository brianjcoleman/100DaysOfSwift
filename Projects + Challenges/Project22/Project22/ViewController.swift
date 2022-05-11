//
//  ViewController.swift
//  Project22
//
//  Created by Brian Coleman on 2022-05-10.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var circleView: UIView!
    
    var locationManager: CLLocationManager?
    var firstDetection: Bool = true
    var currentBeaconUuid: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        nameLabel.text = "Unknown"
        
        circleView.layer.cornerRadius = 128
        circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways,
           CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
               CLLocationManager.isRangingAvailable() {
                startScanning()
        }
    }
    
    func startScanning() {
        addBeaconRegion(
            uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5",
            major: 123,
            minor: 456,
            identifier: "Apple AirLocate"
        )
        addBeaconRegion(
            uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6",
            major: 123,
            minor: 456,
            identifier: "Radius Networks"
        )
        addBeaconRegion(
            uuidString: "92AB49BE-4127-42F4-B532-90fAF1E26491",
            major: 123,
            minor: 456,
            identifier: "TwoCanoes"
        )
    }
    
    func addBeaconRegion(uuidString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) {
        guard let uuid = UUID(uuidString: uuidString) else { return }
        let beaconRegion = CLBeaconRegion(
            proximityUUID: uuid,
            major: major,
            minor: minor,
            identifier: identifier
        )
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    func update(distance: CLProximity, name: String) {
        UIView.animate(withDuration: 1) { [weak self] in
            self?.nameLabel.text = name
            
            switch distance {
            case .far:
                self?.view.backgroundColor = UIColor.blue
                self?.distanceReading.text = "FAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)

            case .near:
                self?.view.backgroundColor = UIColor.orange
                self?.distanceReading.text = "NEAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            case .immediate:
                self?.view.backgroundColor = UIColor.red
                self?.distanceReading.text = "RIGHT HERE"
                self?.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
            default:
                self?.view.backgroundColor = UIColor.gray
                self?.distanceReading.text = "UNKNOWN"
                self?.nameLabel.text = "Unknown"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            if currentBeaconUuid == nil {
                currentBeaconUuid = region.proximityUUID
            }
            guard currentBeaconUuid == region.proximityUUID else { return }

            update(distance: beacon.proximity, name: region.identifier)
            
            showFirstDetection()
        } else {
            guard currentBeaconUuid == region.proximityUUID else { return }
            currentBeaconUuid = nil
            
            update(distance: .unknown, name: "Unknown")
        }
    }
    
    func showFirstDetection() {
        if firstDetection {
            firstDetection = false
            let ac = UIAlertController(
                title: "Beacon detected",
                message: nil,
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
