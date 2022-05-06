//
//  ViewController.swift
//  Project2
//
//  Created by Brian Coleman on 2022-01-25.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var numberOfQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showScore))
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        manageNotifications()
        
        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "\(countries[correctAnswer].uppercased()) - \(score)"
        numberOfQuestions += 1
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        }
        else {
            title = "Wrong, it was \(countries[correctAnswer].uppercased())"
            score -= 1
        }
        
        if numberOfQuestions < 10 {
            let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        }
        else {
            let ac = UIAlertController(title: title, message: "Your FINAL score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: []) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { finished in
            sender.transform = .identity
        }
    }
    
    @objc func showScore() {
        let ac = UIAlertController(title: "Your score is \(score)", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    // Project 21 - Challenge 3
    
    func manageNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings {
            [weak self] (settings) in
            
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    let ac = UIAlertController(
                        title: "Daily reminder",
                        message: "Allow notifications to be reminded daily to play Guess the Flag",
                        preferredStyle: .alert
                    )
                    ac.addAction(
                        UIAlertAction(title: "Yes", style: .default) { _ in
                        self?.requestNotificationsAuthorization()
                    })
                    ac.addAction(
                        UIAlertAction(title: "No", style: .cancel) { _ in
                    })
                    self?.present(ac, animated: true)
                    return
                }

                if settings.authorizationStatus == .authorized {
                    self?.scheduleNotifications()
                }
            }
        }
    }
    
    func requestNotificationsAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.requestAuthorization(
            options: [.alert, .badge, .sound]
        ) {
            [weak self] granted, error in
            if granted {
                self?.scheduleNotifications()
            } else {
                let ac = UIAlertController(
                    title: "Notifications",
                    message: "Your choice has been saved.\nShould you change your mind, head to \"Settings -> Project2 -> Notifications\" to update your preferences.",
                    preferredStyle: .alert
                )
                ac.addAction(
                    UIAlertAction(title: "OK", style: .default)
                )
                self?.present(ac, animated: true)
            }
        }
    }
    
    func scheduleNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Daily reminder"
        notificationContent.body = "Play Guess the Flag today!"
        notificationContent.categoryIdentifier = "reminder"
        notificationContent.sound = .default
        
        let secondsPerDay: TimeInterval = 3600 * 24
        for day in 1...7 {
            let notificationTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: secondsPerDay * Double(day),
                repeats: false
            )
            let notificationRequest = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: notificationContent,
                trigger: notificationTrigger
            )
            notificationCenter.add(notificationRequest)
        }
    }
}
