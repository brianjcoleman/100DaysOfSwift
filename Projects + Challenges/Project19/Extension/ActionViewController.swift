//
//  ActionViewController.swift
//  Extension
//
//  Created by Brian Coleman on 2022-04-25.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    var savedScriptsByURL = [String: String]()
    var savedScriptsByURLKey = "SavedScriptsByURL"

    var savedScriptsByName = [UserScript]()
    var savedScriptsByNameKey = "SavedScriptsByName"
    
    var scriptToLoad: String?

    let scriptExamples = [
        (title: "Display an alert",
         example: """
            alert("Page title: " + document.title + "\\nPage url: " + document.URL);
            """
        ),
        (title: "Source Code",
         example: """
            var markup = document.documentElement.innerHTML;\nalert(markup);
            """
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(bookmarksTapped))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    self?.loadData()
                    
                    DispatchQueue.main.async {
                        self?.updateUI()
                    }
                }
            }
        }
    }
    
    func loadData() {
        let userDefaults = UserDefaults.standard
        savedScriptsByURL = userDefaults.object(forKey: savedScriptsByURLKey) as? [String: String] ?? [String: String]()
        
        if let savedScriptsByNameData = userDefaults.object(forKey: savedScriptsByNameKey) as? Data {
            let jsonDecoder = JSONDecoder()
            savedScriptsByName = (try? jsonDecoder.decode([UserScript].self, from: savedScriptsByNameData)) ?? [UserScript]()
        }
    }
    
    func updateUI() {
        title = "Script injection"
        
        if let url = URL(string: pageURL) {
            if let host = url.host {
                script.text = savedScriptsByURL[host]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let scriptToLoad = scriptToLoad {
            script.text = scriptToLoad
        }
        
        scriptToLoad = nil
    }

    @objc func done() {
        DispatchQueue.main.async() { [weak self] in
            self?.saveScriptForCurrentURL()
            
            let item = NSExtensionItem()
            let argument: NSDictionary = ["customJavaScript": self?.script.text as Any]
            let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
            let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
            item.attachments = [customJavaScript]
            
            DispatchQueue.main.async {
                self?.extensionContext?.completeRequest(returningItems: [item])
            }
        }
    }
    
    func saveScriptForCurrentURL() {
        if let url = URL(string: pageURL) {
            if let host = url.host {
                savedScriptsByURL[host] = script.text
                let userDefaults = UserDefaults.standard
                userDefaults.set(savedScriptsByURL, forKey: savedScriptsByURLKey)
            }
        }
    }
    
    @objc func bookmarksTapped() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Examples", style: .default) { [weak self] _ in
            self?.examplesTapped()
        })
        ac.addAction(UIAlertAction(title: "Load Script", style: .default) { [weak self] _ in
            self?.loadTapped()
        })
        ac.addAction(UIAlertAction(title: "Save Script", style: .default) { [weak self] _ in
            self?.saveTapped()
        })
        ac.addAction(UIAlertAction(title: "Clear Script", style: .default) { [weak self] _ in
            self?.clearTapped()
        })

        present(ac, animated: false)
    }

    func examplesTapped() {
        let ac = UIAlertController(title: "Examples", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        for (title, example) in scriptExamples {
            ac.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.script.text = example
            })
        }
        
        present(ac, animated: false)
    }
    
    func saveTapped() {
        let ac = UIAlertController(title: "Script Name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let name = ac?.textFields?[0].text else { return }
            self?.savedScriptsByName.append(UserScript(name: name, script: self?.script.text ?? ""))
            self?.performSelector(inBackground: #selector(self?.saveScriptsByName), with: nil)
        })
        present(ac, animated: false)
    }
    
    func loadTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LoadViewController") as? LoadViewController {
            vc.savedScriptsByName = savedScriptsByName
            vc.savedScriptsByNameKey = savedScriptsByNameKey
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func clearTapped() {
        script.text = ""
    }

    @objc func saveScriptsByName() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(savedScriptsByName) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(savedData, forKey: savedScriptsByNameKey)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
}

extension ActionViewController: LoadDelegate {
    func load(_ load: LoadViewController, didSelect script: String) {
        scriptToLoad = script
    }
    
    func load(_ load: LoadViewController, didUpdate scripts: [UserScript]) {
        savedScriptsByName = scripts
    }
}
