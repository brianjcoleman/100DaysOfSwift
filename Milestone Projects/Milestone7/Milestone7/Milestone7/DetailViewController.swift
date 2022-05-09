//
//  DetailViewController.swift
//  Milestone7
//
//  Created by Brian Coleman on 2022-05-09.
//

import Foundation
import UIKit

protocol DetailDelegate {
    func detail(_ detail: DetailViewController, didUpdate notes: [Note])
}

class DetailViewController: UIViewController {
    var delegate: DetailDelegate?
    
    @IBOutlet var textView: UITextView!
    
    var notes: [Note]!
    var noteIndex: Int!
    var originalText: String!
    
    var shareButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped)
        )
        doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(doneButtonPressed)
        )
        navigationItem.rightBarButtonItems = [shareButton]
        Styles.setNavigationBarColors(for: navigationController)

        deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteTapped)
        )
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let new = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(newButtonPressed)
        )
        toolbarItems = [deleteButton, space, new]
        navigationController?.isToolbarHidden = false
        Styles.setToolbarColors(for: navigationController)

        textView.text = notes[noteIndex].text
        originalText = notes[noteIndex].text
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard noteIndex != nil else { return }

        saveNote()
    }

    func setNotes(notes: [Note], noteIndex: Int) {
        self.notes = notes
        self.noteIndex = noteIndex
    }
    
    // MARK: Actions
    
    @objc func shareTapped() {
        hideKeyboard()
        saveNote()
        
        let vc = UIActivityViewController(
            activityItems: [notes[noteIndex].text],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = shareButton
        present(vc, animated: true)
    }
    
    @objc func deleteTapped() {
        let ac = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        ac.popoverPresentationController?.barButtonItem = deleteButton
        ac.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive,
                handler: { [weak self] _ in
                    self?.deleteNote()
                })
        )
        ac.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        present(ac, animated: true)
    }
    
    @objc func newButtonPressed() {
        saveNote()
        
        notes.append(Note(text: "", modificationDate: Date()))
        delegate?.detail(self, didUpdate: notes)

        noteIndex = notes.count - 1
        textView.text = ""
        originalText = ""
        
        saveNote(newNote: true)
    }
    
    @objc func doneButtonPressed() {
        hideKeyboard()
    }
    
    // MARK: Delete
    
    func deleteNote() {
        notes.remove(at: noteIndex)
        delegate?.detail(self, didUpdate: notes)

        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Notes.save(notes: notes)
            }
            
            DispatchQueue.main.async {
                self?.refreshNotes()
            }
        }
    }
    
    func refreshNotes() {
        if noteIndex < notes.count {
            textView.text = notes[noteIndex].text
            return
        }
            
        if notes.count > 0 {
            noteIndex = notes.count - 1
            textView.text = notes[noteIndex].text
            return
        }
            
        noteIndex = nil
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Save
    
    func saveNote(newNote: Bool = false) {
        if textView.text != originalText || newNote {
            originalText = textView.text
            notes[noteIndex].text = textView.text
            notes[noteIndex].modificationDate = Date()
            
            DispatchQueue.global().async { [weak self] in
                if let notes = self?.notes {
                    Notes.save(notes: notes)
                }
            }
        }
    }

    // MARK: Keyboard
    
    func hideKeyboard() {
        textView.endEditing(true)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
            navigationItem.rightBarButtonItems = [shareButton]
            saveNote()
        } else {
            textView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: 0
            )
            navigationItem.rightBarButtonItems = [doneButton, shareButton]
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}
