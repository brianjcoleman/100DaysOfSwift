//
//  ViewController.swift
//  Project1
//
//  Created by Brian Coleman on 2022-01-20.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func loadImages() {
        DispatchQueue.global(qos: .background).async {
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)
            
            for item in items {
                if item.hasPrefix("nssl") {
                    // this is a picture to load!
                    self.pictures.append(item)
                }
            }
            
            self.pictures = self.pictures.sorted()
            
            print(self.pictures)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath) as? StormCell else {
            fatalError("Unable to dequeue a StormCell.")
        }
        
        let picture = pictures[indexPath.row]
        cell.titleLabel.text = picture
        
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: picture)
        cell.subTitleLabel.text = "Views: \(count)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let picture = pictures[indexPath.row]
            vc.selectedImage = picture
            vc.selectedPictureNumber = indexPath.row+1
            vc.totalPictures = pictures.count
            navigationController?.pushViewController(vc, animated: true)
            
            let defaults = UserDefaults.standard
            let count = defaults.integer(forKey: picture)
            save(picture: picture, count: count)
        }
    }
    
    func save(picture: String, count: Int = 0) {
        let defaults = UserDefaults.standard
        defaults.set(count+1, forKey: picture)
    }
}

