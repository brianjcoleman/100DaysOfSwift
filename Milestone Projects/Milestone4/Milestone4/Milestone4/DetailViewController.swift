//
//  DetailViewController.swift
//  Milestone4
//
//  Created by Brian Coleman on 2022-03-23.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: Picture?
    var imageContents: String?
    var path: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedImage != nil {
            imageView.image = UIImage(contentsOfFile: path!.path)
        }
    }
}
