//
//  ViewController.swift
//  Project9Challenge
//
//  Created by Brian Coleman on 2022-02-28.
//

import UIKit

class ViewController: UIViewController {

    var word = "RYTHUM"
    var promptWord = ""
    var promptLabel: UILabel!
    var cluesLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var usedLetters = [String]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    var wrongAnswers = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.textAlignment = .center
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
        
        promptLabel = UILabel()
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.font = UIFont.systemFont(ofSize: 24)
        promptLabel.text = ""
        promptLabel.textAlignment = .center
        promptLabel.numberOfLines = 0
        promptLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(promptLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Enter a letter to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = true
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            cluesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cluesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            
            promptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            promptLabel.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            promptLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 20),
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44)
        ])
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLevel()
    }

    @objc func submitTapped(_ sender: UIButton) {
        guard let answerLetter = currentAnswer.text else { return }
        if answerLetter.count > 1 {
            let ac = UIAlertController(title: "Too many letters", message: "Only guess 1 letter at a time.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true)
        } else if usedLetters.contains(answerLetter) {
            let ac = UIAlertController(title: "Already used letter", message: "You already used that letter, try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.clearTapped(UIButton())
            }))
            present(ac, animated: true)
        } else {
            usedLetters.append(answerLetter)
            
            promptWord = ""
            for letter in word {
                let strLetter = String(letter)

                if usedLetters.contains(strLetter) {
                    promptWord += strLetter
                } else {
                    promptWord += "?"
                }
            }
            promptLabel.text = promptWord
            print(promptWord)
            
            if word.contains(answerLetter) {
                currentAnswer.text = ""
                score += 1
                
                if !promptWord.contains("?") {
                    let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next word?", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                    present(ac, animated: true)
                }
            }
            else {
                if wrongAnswers == 7 {
                    let ac = UIAlertController(title: "Game Over", message: "You got 7 answers wrong. Try again.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.loadLevel()
                    }))
                    present(ac, animated: true)
                } else {
                    let ac = UIAlertController(title: "Incorrect", message: "That's not a match, try again.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.wrongAnswers += 1
                        self.clearTapped(UIButton())
                    }))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        currentAnswer.becomeFirstResponder()
    }

    func loadLevel() {
        DispatchQueue.global(qos: .background).async {
            if let levelFileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
                if let levelContents = try? String(contentsOf: levelFileURL) {
                    var lines = levelContents.components(separatedBy: "\n")
                    lines.shuffle()
                    
                    let line = lines[self.level]
                    let parts = line.components(separatedBy: ": ")
                    self.word = parts[0]
                    
                    DispatchQueue.main.async {
                        self.wrongAnswers = 0
                        self.promptWord = ""
                        self.usedLetters.removeAll()
                        self.cluesLabel.text = ""
                        self.promptLabel.text = ""
                        
                        for letter in self.word {
                            let strLetter = String(letter)

                            if self.usedLetters.contains(strLetter) {
                                self.promptWord += strLetter
                            } else {
                                self.promptWord += "?"
                            }
                        }
                        
                        self.promptLabel.text = self.promptWord
                        self.cluesLabel.text = parts[1]
                        
                        self.currentAnswer.becomeFirstResponder()
                    }
                }
            }
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        loadLevel()
    }
}
