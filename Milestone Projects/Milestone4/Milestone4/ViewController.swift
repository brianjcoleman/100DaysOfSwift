//
//  ViewController.swift
//  Milestone4
//
//  Created by Brian Coleman on 2022-03-23.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var pictures = [Picture]()
    var imageToDisplay: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewImage))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPhoto))
        
        let defaults = UserDefaults.standard
        if let savedImages = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                pictures = try jsonDecoder.decode([Picture].self, from: savedImages)
            } catch {
                print("Failed to load pictures")
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Caption", for: indexPath)
        let photo = pictures[indexPath.row]
        let path = getDocumentsDirectory().appendingPathComponent(photo.image)
        
        cell.textLabel?.text = photo.caption
        cell.imageView?.image = UIImage(contentsOfFile: path.path)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let photo = pictures[indexPath.row]
        let path = getDocumentsDirectory().appendingPathComponent(photo.image)
        
        let ac = UIAlertController(title: "Add Caption", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Add Caption", style: .default, handler: {
            [weak self, weak ac] _ in
            guard let caption = ac?.textFields?[0].text else { return }
            photo.caption = caption
            self?.save()
            self?.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "View Picture", style: .default, handler: {
            [weak self] _ in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                vc.selectedImage = photo
                vc.path = path
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        } ))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func addNewImage() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func addNewPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let photo = Picture(image: imageName, caption: "")
        pictures.append(photo)
        save()
        tableView.reloadData()
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        } else {
            print("Failed to save pictures")
        }
    }

}
