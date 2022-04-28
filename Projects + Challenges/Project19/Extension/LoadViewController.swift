//
//  LoadViewController.swift
//  Extension
//
//  Created by Brian Coleman on 2022-04-28.
//

import UIKit

protocol LoadDelegate {
    func load(_ load: LoadViewController, didSelect script: String)
    func load(_ load: LoadViewController, didUpdate scripts: [UserScript])
}

class LoadViewController: UITableViewController {
    var delegate: LoadDelegate?
    
    var savedScriptsByName: [UserScript]!
    var savedScriptsByNameKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard savedScriptsByName != nil && savedScriptsByNameKey != nil else {
            navigationController?.popViewController(animated: true)
            return
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedScriptsByName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Script", for: indexPath)
        cell.textLabel?.text = savedScriptsByName[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.load(self, didSelect: savedScriptsByName[indexPath.row].script)
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedScriptsByName.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            delegate?.load(self, didUpdate: self.savedScriptsByName)
            performSelector(inBackground: #selector(saveScriptsByName), with: nil)
        }
    }
    
    @objc func saveScriptsByName() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(savedScriptsByName) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(savedData, forKey: savedScriptsByNameKey)
        }
    }
}
