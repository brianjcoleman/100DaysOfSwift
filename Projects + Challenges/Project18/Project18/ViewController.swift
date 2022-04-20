//
//  ViewController.swift
//  Project18
//
//  Created by Brian Coleman on 2022-04-20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("I'm inside the viewDidLoad() method.")
        print(1, 2, 3, 4, 5, separator: "-")
        print("Some message", terminator: "")
        
        assert(1 == 1, "Math failure!")
        //assert(1 == 2, "Math failure!")
        //assert(myReallySlowMethod() == true, "The slow method returned false, which is a bad thing.")
        
        for i in 1...100 {
            print ("Got number \(i).")
        }
    }


}

