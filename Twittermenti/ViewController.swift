//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let classifier = sentimentClassifier()
    let maxTweetCount = 100
    
    let swifter = Swifter(consumerKey: "*******", consumerSecret: "*******")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        self.newSearch()
    }
    
    func newSearch() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: maxTweetCount, tweetMode: .extended, success: { (results, metaData) in
                
                var tweets = [sentimentClassifierInput]()
                for i in 0..<self.maxTweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = sentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.predictSentiment(input: tweets)
                
            }) { (error) in
                print("Error while searching Tweets. \(error)")
            }
        }
    }
    
    func predictSentiment(input:[sentimentClassifierInput]) {
        
        do {
            let predictions = try self.classifier.predictions(inputs: input)
            var score = 0
            
            for pred in predictions {
                switch pred.label {
                case "Pos":
                    score += 1
                case "Neg":
                    score -= 1
                default:
                    break
                }
            }
            self.updateUI(score: score)
        } catch {
            print("Error while getting predition. \(error)")
        }
    }
    
    func updateUI(score: Int) {
        if score > 20 {
            self.sentimentLabel.text = "🥰"
        } else if score > 10 {
            self.sentimentLabel.text = "😄"
        } else if score > 0 {
            self.sentimentLabel.text = "😊"
        } else if score == 0 {
            self.sentimentLabel.text = "😐"
        } else if score > -10 {
            self.sentimentLabel.text = "🙁"
        } else if score > -20 {
            self.sentimentLabel.text = "😧"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
    
}

