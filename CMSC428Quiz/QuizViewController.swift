//
//  QuizViewController.swift
//  CMSC428Quiz
//
//  Created by Hansin Dwivedi on 4/30/22.
//

import UIKit
import MultipeerConnectivity

struct Quiz:Decodable {
    let numberOfQuestions: Int
    let questions:[Questions]
    let topic: String
}

struct Questions:Decodable{
    let number: Int
    let questionSentence: String
    let options:Answers
    let correctOption: String
}

struct Answers:Decodable{
    let A: String
    let B: String
    let C: String
    let D: String
}

class QuizViewController: UIViewController {
    var session:MCSession!
    var multi:Int!
    var players:Int!
    var curQuiz:Quiz!
    var curQ:Int = 0
    var timer:Timer!
    var d:Data!
    var curAnswer:String!
    var selectedAnswer:String = ""
    
    
    @IBOutlet weak var answerA:UIButton!
    @IBOutlet weak var answerB:UIButton!
    @IBOutlet weak var answerC:UIButton!
    @IBOutlet weak var answerD:UIButton!
    
    @IBOutlet weak var question:UILabel!
    @IBOutlet weak var questionAmount:UILabel!
    
    @IBOutlet weak var points1:UILabel!
    @IBOutlet weak var points2:UILabel!
    @IBOutlet weak var points3:UILabel!
    @IBOutlet weak var points4:UILabel!
    
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var restartButton:UIButton!
    
    
    override func viewDidLoad() {
        if(multi == 1){
            session.delegate = self
            players = session.connectedPeers.count
        }
        if let url = URL(string: "https://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json") {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                 if let jsonString = String(data: data, encoding: .utf8) {
                     self.d = data
                     self.parseJson(data: data)
                     print(jsonString)
                 }
               }
           }.resume()
        }
        while(curQuiz == nil){
            
        }
        startQuiz()
    }
    
    func parseJson(data:Data){
        let quiz:Quiz = try! JSONDecoder().decode(Quiz.self, from: data)
        curQuiz = quiz
        curQ = 0
        print(quiz)
    }
    
    func startQuiz(){
        curQ = 0
        getQuestion()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.lowerTime), userInfo: nil, repeats: true)
    }
    
    func getQuestion(){
        let q:Questions = curQuiz.questions[curQ]
        
        selectedAnswer = ""
        
        answerA.backgroundColor = .lightGray
        answerB.backgroundColor = .lightGray
        answerC.backgroundColor = .lightGray
        answerD.backgroundColor = .lightGray
        
        answerA.setTitle("A. " + q.options.A, for: .normal)
        answerB.setTitle("B. " + q.options.B, for: .normal)
        answerC.setTitle("C. " + q.options.C, for: .normal)
        answerD.setTitle("D. " + q.options.D, for: .normal)
        time.text = "30"
        
        curAnswer = q.correctOption
        question.text = q.questionSentence
        questionAmount.text = String(q.number) + "/" + String(curQuiz.questions.count)
    }
    
    @objc func lowerTime(){
        if(Int(time.text!) == 0){
            curQ += 1
            if(curQ >= curQuiz.numberOfQuestions){
                endQuiz()
            } else {
                getQuestion()
            }
        } else {
            time.text = String(Int(time.text!)! - 1)
        }
    }
    
    func endQuiz(){
        print("quiz ended")
    }
    
    func nextQuestion(){
        
    }
    
    @IBAction func selectAnswer(_ sender: UIButton){
        if(sender.tag == 1){
            answerA.backgroundColor = .blue
            selectedAnswer = "A"
            answerB.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 2){
            answerB.backgroundColor = .blue
            selectedAnswer = "B"
            answerA.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 3){
            answerC.backgroundColor = .blue
            selectedAnswer = "C"
            answerA.backgroundColor = .lightGray
            answerB.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 4){
            answerD.backgroundColor = .blue
            selectedAnswer = "D"
            answerB.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerA.backgroundColor = .lightGray
        }
    }
}
extension QuizViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}
