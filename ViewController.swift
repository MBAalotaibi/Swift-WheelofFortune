//
//  ViewController.swift
//  Homework1
//
//  Created by Mohammed al-otaibi  
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var highScore1: UILabel!
    @IBOutlet weak var highScore2: UILabel!
    @IBOutlet weak var highScore3: UILabel!
    @IBOutlet weak var highScore4: UILabel!
    @IBOutlet weak var highScore5: UILabel!
    var scores:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        print(storyBoard)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainController") as! MainController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Get high scores from file
        scores = loadHighScores()
        
        // Sort high scores and keep only the top five scores
        scores.sort(by: >)
        if scores.count > 5 {
            scores = Array(scores[0...4])
        }
        
        // Update the screen with the scores
        setScores()
    }

    func loadHighScores() -> [Int] {
        // Load the scores from the file system
        let fileManager = FileManager.default
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsUrl.appendingPathComponent("highscores.txt")

        // If the file does not exist, create it
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }

        // Read the file
        var fileContents = ""
        do {
            fileContents = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        }
        catch {
            print("Error reading file")
        }

        // Split the file contents into an array of strings by new line
        let scoresStringArray = fileContents.components(separatedBy: .newlines)
        return scoresStringArray.compactMap { Int($0) }
    }

    func setScores() {
        highScore1.text = scores.count > 0 ? String(scores[0]) : ""
        highScore2.text = scores.count > 1 ? String(scores[1]) : ""
        highScore3.text = scores.count > 2 ? String(scores[2]) : ""
        highScore4.text = scores.count > 3 ? String(scores[3]) : ""
        highScore5.text = scores.count > 4 ? String(scores[4]) : ""
    }

}

