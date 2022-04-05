//
//  DetailViewController.swift
//  Milestone5
//
//  Created by Brian Coleman on 2022-04-05.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var detailItem: Country?
    var countryName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = countryName
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareFacts))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "country")
        let cell = tableView.dequeueReusableCell(withIdentifier: "country", for: indexPath)
        
        if let detailItem = detailItem {
            switch indexPath.row {
            case 0:
                if let capital = detailItem.capital {
                    cell.textLabel?.text = "Capital: \(capital)"
                }
            case 1:
                if let firstLanguage = detailItem.languages[0]["official"] {
                    cell.textLabel?.text = "Official Language: \(firstLanguage)"
                }
            case 2:
                if let secondLanguage = detailItem.languages[0]["second"] {
                    cell.textLabel?.text = "Secondary Language: \(secondLanguage)"
                }
            case 3:
                cell.textLabel?.text = "Area (sq mi): \(detailItem.area)"
            case 4:
                cell.textLabel?.text = "Population: \(detailItem.population)"
            case 5:
                cell.textLabel?.text = "Currency: \(detailItem.currency)"
            default:
                cell.textLabel?.text = nil
            }
            cell.textLabel?.numberOfLines = 0
        }
        
        return cell
    }
    
    @objc func shareFacts() {
        var facts: String = ""
        
        if let name = detailItem?.name {
            facts += "Check out \(name)!\n"
        }
        if let population = detailItem?.population {
            facts += "It has a population of \(population).\n"
        }
        if let officialLanguage = detailItem?.languages[0]["official"] {
            facts += "The offical language is \(officialLanguage).\n"
        }
        if let secondaryLanguage = detailItem?.languages[0]["second"] {
            facts += "\(secondaryLanguage) is the second most common language.\n"
        }
        if let area = detailItem?.area {
            facts += "The total amount of land covers \(area) square miles.\n"
        }
        if let capital = detailItem?.capital {
            facts += "The capital of this beautiful country is \(capital).\n"
        }
        if let currency = detailItem?.currency {
            facts += "The currency they use is the \(currency)."
        }
        
        let objToShare = [facts]
        let vc = UIActivityViewController(activityItems: objToShare as [Any], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
           vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(vc, animated: true)
    }
}
