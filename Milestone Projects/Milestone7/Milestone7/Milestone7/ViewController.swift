//
//  ViewController.swift
//  Milestone7
//
//  Created by Brian Coleman on 2022-05-09.
//

import UIKit

class ViewController: UITableViewController {
    var notes = [Note]()
   
    var selectedCellView: UIView!

    var editButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    var spacerButton: UIBarButtonItem!
    var notesCountButton: UIBarButtonItem!
    var newNoteButton: UIBarButtonItem!
    var deleteAllButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.backgroundColor = .systemBackground
        
        editButton = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(enterEditingMode)
        )
        cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelEditingMode)
        )
        navigationItem.rightBarButtonItems = [editButton]
        Styles.setNavigationBarColors(for: navigationController)

        newNoteButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(createNote)
        )
        spacerButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        notesCountButton = UIBarButtonItem(
            title: "\(notes.count) Notes",
            style: .plain,
            target: nil,
            action: nil
        )
        notesCountButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11),
            NSAttributedString.Key.foregroundColor : UIColor.label
            ], for: .normal)
        
        toolbarItems = [spacerButton, notesCountButton, spacerButton, newNoteButton]
        navigationController?.isToolbarHidden = false
        Styles.setToolbarColors(for: navigationController)
        
        deleteAllButton = UIBarButtonItem(
            title: "Delete All",
            style: .plain,
            target: self,
            action: #selector(deleteAllTapped))
        deleteButton = UIBarButtonItem(
            title: "Delete",
            style: .plain,
            target: self,
            action: #selector(deleteTapped)
        )
        selectedCellView = UIView()
        selectedCellView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }

    override func viewWillAppear(_ animated: Bool) {
        sortNotes()
        reloadData()
    }

    // MARK: Reload Data
    
    func reloadData() {
        DispatchQueue.global().async { [weak self] in
            self?.notes = Notes.load()
            self?.sortNotes()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateNotesCount()
            }
        }
    }
    
    func sortNotes() {
        notes.sort(by: { $0.modificationDate >= $1.modificationDate })
    }
    
    func updateNotesCount() {
        notesCountButton.title = "\(notes.count) Notes"
    }

    // MARK: UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)

        if let cell = cell as? NoteCell {
            let note = notes[indexPath.row]
            let split = note.text.split(
                separator: "\n",
                maxSplits: 2,
                omittingEmptySubsequences: true
            )
            
            cell.titleLabel.text = getTitleText(split: split)
            cell.subtitleLabel.text = getSubtitleText(split: split)
            cell.dateLabel.text = formatDate(from: note.modificationDate)

            setCellColors(for: cell)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            
            DispatchQueue.global().async { [weak self] in
                if let notes = self?.notes {
                    Notes.save(notes: notes)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.updateNotesCount()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            toolbarItems = [spacerButton, deleteButton]
        }  else {
            openDetailViewController(noteIndex: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing,
            tableView.indexPathsForSelectedRows == nil ||
                tableView.indexPathsForSelectedRows!.isEmpty {
                toolbarItems = [spacerButton, deleteAllButton]
        }
    }
    
    // MARK: Cell Text
    
    func getTitleText(split: [Substring]) -> String {
        if split.count >= 1 {
            return String(split[0])
        }
        
        return "New Note"
    }
    
    func getSubtitleText(split: [Substring]) -> String {
        if split.count >= 2 {
            return String(split[1])
        }
        
        return "No additional text"
    }
    
    func formatDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        }
        
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    func setCellColors(for cell: UITableViewCell) {
        cell.selectedBackgroundView = selectedCellView
        
        let multipleSelectedCellView = UIView()
        multipleSelectedCellView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
        cell.multipleSelectionBackgroundView = multipleSelectedCellView
        
        cell.tintColor = .orange
    }
    
    // MARK: Actions
    
    func openDetailViewController(noteIndex: Int) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            vc.setNotes(notes: notes, noteIndex: noteIndex)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func createNote() {
        notes.append(Note(text: "", modificationDate: Date()))
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Notes.save(notes: notes)
                
                DispatchQueue.main.async {
                    self?.openDetailViewController(noteIndex: notes.count - 1)
                }
            }
        }
    }
    
    // MARK: UITableView Editing

    @objc func enterEditingMode() {
        navigationItem.rightBarButtonItems = [cancelButton]
        toolbarItems = [spacerButton, deleteAllButton]
        setEditing(true, animated: true)
    }
    
    @objc func cancelEditingMode() {
        navigationItem.rightBarButtonItems = [editButton]
        toolbarItems = [spacerButton, notesCountButton, spacerButton, newNoteButton]
        setEditing(false, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
    @objc func deleteAllTapped() {
        let ac = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        ac.popoverPresentationController?.barButtonItem = deleteAllButton
        ac.addAction(
            UIAlertAction(
                title: "Delete All",
                style: .destructive,
                handler: { [weak self] _ in
                    self?.deleteAll()
                })
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func deleteAll() {
        notes = [Note]()
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Notes.save(notes: notes)
            }
            
            DispatchQueue.main.async {
                self?.reloadData()
                self?.cancelEditingMode()
            }
        }
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
                    if let selectedRows = self?.tableView.indexPathsForSelectedRows {
                        self?.deleteNotes(rows: selectedRows)
                    }
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
    
    func deleteNotes(rows: [IndexPath]) {
        for path in rows {
            notes.remove(at: path.row)
        }
        
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Notes.save(notes: notes)
            }
            
            DispatchQueue.main.async {
                self?.reloadData()
                self?.cancelEditingMode()
            }
        }
    }
}

extension ViewController: DetailDelegate {
    func detail(_ detail: DetailViewController, didUpdate notes: [Note]) {
        self.notes = notes
    }
}
