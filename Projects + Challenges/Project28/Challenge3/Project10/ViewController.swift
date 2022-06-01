//
//  ViewController.swift
//  Project10
//
//  Created by Brian Coleman on 2022-03-10.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    var hiddenPeople = [Person]()
    var addPersonButton: UIBarButtonItem!
    var unlockButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNNewPerson))
        
        setupUnlock()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue a PersonaCell.")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = .camera
//        }
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths  = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Do you want to rename the person or delete them?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: {
            [weak self] _ in
            self?.rename(person: person)
        }))
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
            [weak self] _ in
            self?.delete(person: person)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func rename(person: Person) {
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.collectionView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func delete(person: Person) {
        if let index = people.firstIndex(of: person) {
            people.remove(at: index)
            collectionView.reloadData()
        }
    }
    
    //MARK: Project 28 Challenge 3
    
    func setupUnlock() {
        unlockButton = UIBarButtonItem(title: "Unlock", style: .plain, target: self, action: #selector(unlockTapped))
        navigationItem.rightBarButtonItem = unlockButton
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                hiddenPeople = try jsonDecoder.decode([Person].self, from: savedPeople)
            }
            catch {
                print("Failed to load people")
            }
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(lock), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func unlockTapped() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            showAlert(
                title: "Unavailable",
                message: "Biometrics authentication is not available"
            )
            return
        }
        
        var reason = ""
        switch context.biometryType {
        case .none:
            showAlert(
                title: "Unavailable",
                message: "Biometrics authentication is not available"
            )
            return
        case .faceID:
            reason = "Use Face ID to access your pictures"
        case .touchID:
            reason = "Use Touch ID to access your pictures"
        @unknown default:
            reason = "Use biometrics to access your pictures"
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
            DispatchQueue.main.async {
                guard success else {
                    self?.showAlert(
                        title: "Failed",
                        message: "Biometrics authentication failed"
                    )
                    return
                }

                self?.unlock()
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func unlock() {
        navigationItem.leftBarButtonItem = addPersonButton
        navigationItem.rightBarButtonItem = nil
        people = hiddenPeople
        collectionView.reloadData()
    }
    
    @objc func lock() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = unlockButton
        people = [Person]()
        collectionView.reloadData()
    }
}

