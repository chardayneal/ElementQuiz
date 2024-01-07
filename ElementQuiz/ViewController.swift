//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Charday Neal on 1/7/24.
//

import UIKit

enum Mode {
    case flashcard, quiz
}

enum State {
    case question, answer, score
}

class ViewController: UIViewController {

    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // set default enums
    public var mode: Mode = .flashcard {
        didSet {
            switch mode {
            case .flashcard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            
            updateUI()
        }
    }
    public var state: State = .question
    
    // element - relative index
    private let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    private var elementList: [String] = []
    private var currentElementIndex = 0
    
    
    //quiz - specific state
    private var answerIsCorrect = false
    private var correctAnswerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mode = .flashcard
        updateUI()
    }
    
    @IBAction func showAnswer(_ sender: UIButton) {
        //sets state to display answer
        state = .answer
        showAnswerButton.isEnabled = false
        
        updateUI()
    }
    
    @IBAction func next(_ sender: UIButton) {
        //reset next card
        showAnswerButton.isEnabled = true
        
        
        //increases value of elements index
        currentElementIndex += 1
        if currentElementIndex >= elementList.count{
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        
        //sets state to question
        state = .question
        updateUI()
    }
    
    @IBAction func segementedControlPressed(_ sender: UISegmentedControl) {
        
        //changing the mode based on selected Index of segmented control
        if sender.selectedSegmentIndex == 0 {
            mode = .flashcard
          }
        else {
            mode = .quiz
        }
        
        state = .question
        
        //update UI accordingly
        updateUI()
    }
    
    
    public func updateFlashCardUI(_ elementName: String) {
        //segmented control
        modeSelector.selectedSegmentIndex = 0
        
        //configure label and textfield
        answerLabel.isHidden = false
        textField.isHidden = true
        textField.resignFirstResponder()
        
        //displays proper image
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        answerLabel.text = "?"
        
        //displays answer to answer label depending on state
        if state == .answer {
            answerLabel.text = elementName
        }
        
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
    }
    
    public func updateQuizUI(_ elementName: String) {
        //segmented control
        modeSelector.selectedSegmentIndex = 1
        
        
        //configure textField and label
        answerLabel.isHidden = true
        textField.isHidden = false
        
        //displays proper image
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        //displays respective label and textfield based on state value
        switch state {
        case .answer:
            answerLabel.isHidden = false
            if answerIsCorrect {
                answerLabel.text = "Correct"
            } else {
                answerLabel.text = "❌\nCorrect Answer: \(elementName)"
            }
            textField.isEnabled = false
        case .question:
            textField.text = ""
            textField.isEnabled = true
            textField.becomeFirstResponder()
            nextButton.isEnabled = false
            
        case .score:
            answerLabel.text = ""
            textField.isHidden = true
            textField.resignFirstResponder()
            
        }
        
        //display score
        if state == .score {
            displayScoreAlert()
        }
        

    }
    
    //updates UI based on which mode the user wants has chosen
    public func updateUI() {
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        textField.becomeFirstResponder()
        
        switch mode {
        case .flashcard:
            showAnswerButton.isEnabled = true
            updateFlashCardUI(elementName)
        case .quiz:
            showAnswerButton.isEnabled = false
            updateQuizUI(elementName)
        }
    }
    
    //show alert at end of quiz with user score
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        
        alert.addAction(dismissAction)
        
        present(alert, animated: true)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashcard
    }
    
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
    
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        
        elementList = fixedElementList.shuffled()
    }
}


extension ViewController: UITextFieldDelegate {
    
    // after user hits return key on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //store users input from textfield
        let userAnswer = textField.text!
        
        //determines whether user answered correctly and updates respectively
        if userAnswer == elementList[currentElementIndex] {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        
        
        state = .answer
        updateUI()
        
        textField.resignFirstResponder()
        nextButton.isEnabled = true

        return true
    }
    
}

