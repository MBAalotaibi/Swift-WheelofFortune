//
//  MainController.swift
//  Homework1
//
//  Created by Mohammed al-otaibi  
//

import UIKit

class MainController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var noMatchCountLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var multiplierLabel: UILabel!
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    
    var multiplier:Int = 0;
    var noMatchCount:Int = 0;
    var score:Int = 0;
    var guessingPhrase:String = "";
    var genre:String = "";
    var guessedAlreadyRight:[String] = [];
    var phrases:[String] = [];
    let multiplierOptions = [1, 2, 5, 10, 20]
    let numOfTries = 10

    @IBOutlet weak var collectionView: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return length of the guessingPhrase
        return guessingPhrase.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let theSize = CGSize(width: 10.0, height: 15.0)
        return theSize
    }
    
    @IBAction func exitButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! CustomCollectionViewCell
        
        let letter = Array(guessingPhrase)[indexPath.row]

        if (guessedAlreadyRight.contains(String(letter))) {
            cell.theImage.image = UIImage(named: String(letter))
            cell.theLabel.text = ""
            // Set the label to be hidden
            cell.theLabel.isHidden = true
        }
        else if (String(letter) == " ") {
            cell.theImage.image = nil
            cell.theLabel.text = ""
            // Set the label to be hidden
            cell.theLabel.isHidden = true
        }
        else{
            cell.theImage.image = nil
            // set the label background to light gray
            cell.theLabel.backgroundColor = UIColor.lightGray
            cell.theLabel.isHidden = false
        }
        return cell
    }
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout

        // Get the list of phrases and the genre name from the json file
        let phrasesAndGenre:([String],String) = getJSONDataIntoArray()

        phrases = phrasesAndGenre.0
        
        genre = phrasesAndGenre.1


        guessingPhrase = phrases.randomElement()!
        guessingPhrase = guessingPhrase.uppercased()
        print(guessingPhrase)

        redraw()

        collectionView.dataSource = self
	
    }

    func reloadGame(){
        multiplier = multiplierOptions.randomElement()!
        noMatchCount = 0
        score = 0
        guessingPhrase = phrases.randomElement()!
        guessingPhrase = guessingPhrase.uppercased()
        guessedAlreadyRight = []
        print(guessingPhrase)
        redraw()
    }
    
    @IBAction func check(_ sender: Any) {
        // Get the guess from the text field
        let guess = guessTextField.text!
        guessTextField.text = ""
        if (guess == "") {
            return
        }
        if (guess.count > 1) {
            return
        }
        let guessCapitalized = guess.uppercased()
        
        if (guessedAlreadyRight.contains(guessCapitalized)){
            return
        }
        else{
            print(guessingPhrase)

            if guessingPhrase.contains(guessCapitalized) {

                let numOfOccurrances = guessingPhrase.filter { $0 == guessCapitalized.first! }.count

                score += multiplier * numOfOccurrances
                guessedAlreadyRight.append(guessCapitalized)

                checkIfGameWon()
            }
            else {
                noMatchCount += 1
                if (noMatchCount == numOfTries){

                    // Game over alert
                    let alert = UIAlertController(title: "You lose", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            self.reloadGame()
                        @unknown default:
                            break
                        }}))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            redraw()

        }
        
    }

    func checkIfGameWon(){
        // Check if the user has won the game
        var gameWon = true
        for letter in guessingPhrase {
            if (letter != " " && !guessedAlreadyRight.contains(String(letter)) ) {
                gameWon = false
            }
        }

        if (gameWon == true) {
            // Game won alert
            let alert = UIAlertController(title: "You Win!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go Again", style: .default, handler: { action in
                switch action.style{
                case .default:
                    self.reloadGame()
                @unknown default:
                    break
                }}))
            self.present(alert, animated: true, completion: nil)

            saveHighScore(score: score)
        }
    }

    func saveHighScore(score:Int){
        // Save the score to file system, if the file does not exist, create it
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

        // Append the score to the file
        fileContents += "\(score)\n"
        do {
            try fileContents.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            print("Error writing file")
        }
    }

    func redraw() {
        genreLabel.text = "Genre: \(genre)"
        multiplier = multiplierOptions.randomElement()!
        multiplierLabel.text = "Multiplier: " + String(multiplier) + "x"
        noMatchCountLabel.text = "No-match Count: " + String(noMatchCount)
        scoreLabel.text = "Total Score: " + String(score)
        collectionView.reloadData()
    }


    func getFilesInBundleFolder(named fileOrFolderName:String, withExt: String) -> [URL] {
        var fileURLs = [URL]() //the retrieved file-based URLs will be placed here
        let path = Bundle.main.url(forResource: fileOrFolderName, withExtension: withExt)
        //get the URL of the item from the Bundle (in this case a folder
        //whose name was passed as an argument to this function)
        do {// Get the directory contents urls (including subfolders urls)
            fileURLs = try FileManager.default.contentsOfDirectory(at: path!, includingPropertiesForKeys: nil, options: [])
        } catch {
            print(error.localizedDescription)
        }
        return fileURLs
    }
    
    func getJSONDataIntoArray() -> ([String],String) {
        var theGamePhrases = [String]() //empty array which will evenutally hold our phrases
        //and which we will use to return as part of the result of this function.
        var theGameGenre = ""
        //get the URL of one of the JSON files from the JSONdatafiles folder, at random
        let aDataFile = getFilesInBundleFolder(named: "JSONdatafiles",withExt: "").randomElement()
        do {
            let theData = try Data(contentsOf: aDataFile!) //get the contents of that file as data
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: theData,options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                let theTopicData = (jsonResult as? NSDictionary)
                let gameGenre = theTopicData!["genre"] as! String
                theGameGenre = gameGenre //copied so we can see the var outside of this block
                let tempArray = theTopicData!["list"]
                let gamePhrases = tempArray as! [String]
                //compiler complains if we just try to assign this String array to a standard Swift one
                //so instead, we extract individual strings and add them to our larger scope var
                for aPhrase in gamePhrases { //done so we can see the var outside of this block
                    theGamePhrases.append(aPhrase)
                }
            } catch {
                print("couldn't decode JSON data")
            }
        } catch {
            print("couldn't retrieve data from JSON file")
        }
        return (theGamePhrases,theGameGenre) //tuple composed of Array of guessingPhrase Strings and genre
    }
}
