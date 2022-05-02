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

struct Player{
    let peerID:MCPeerID
    var selectedAnswer:String = ""
    var points:Int = 0
}

class QuizViewController: UIViewController {
    var session:MCSession!
    var multi:Int!
    var curQuiz:Quiz!
    var curQ:Int = 0
    var timer:Timer!
    var d:Data!
    var curAnswer:String!
    var selectedAnswer:String = ""
    var players:[Player] = []
    var imagePlayers:[UIImageView] = []
    var quizNum:Int = 1
    
    
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
    
    @IBOutlet weak var player1:UIImageView!
    @IBOutlet weak var player2:UIImageView!
    @IBOutlet weak var player3:UIImageView!
    @IBOutlet weak var player4:UIImageView!
    
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var restartButton:UIButton!
    
    
    override func viewDidLoad() {
        imagePlayers.append(player1)
        
        if(multi == 1){
            imagePlayers.append(player2)
            imagePlayers.append(player3)
            imagePlayers.append(player4)
            
            session.delegate = self
            var i = 0
            while(i<session.connectedPeers.count){
                let id = session.connectedPeers[i]
                let p:Player = Player(peerID: id)
                players.append(p)
                i += 1
            }
            print(players)
        } else {
            let player = Player(peerID: session.myPeerID)
            players.append(player)
        }
        if let url = URL(string: "https://www.people.vcu.edu/~ebulut/jsonFiles/quiz" + String(quizNum) + ".json") {
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
    }
    
    @objc func getQuestion(){
        let q:Questions = curQuiz.questions[curQ]
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.lowerTime), userInfo: nil, repeats: true)
        
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
                calcPoints()
            }
        } else {
            time.text = String(Int(time.text!)! - 1)
        }
    }
    
    func endQuiz(){
        timer.invalidate()
        let q:Questions = curQuiz.questions[curQ - 1]
        var i = 0
        while(i<players.count){
            if(players[i].selectedAnswer == q.correctOption){
                players[i].points += 1
                players[i].selectedAnswer = ""
            }
            i += 1
        }
        print(q.correctOption)
        switch q.correctOption {
            case "A": answerA.backgroundColor = .green
            case "B": answerB.backgroundColor = .green
            case "C": answerC.backgroundColor = .green
            case "D": answerD.backgroundColor = .green
            default: print("")
        }
        quizNum += 1
        print("quiz ended")
    }
    
    func calcPoints(){
        timer.invalidate()
        let q:Questions = curQuiz.questions[curQ - 1]
        let time = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.getQuestion), userInfo: nil, repeats: false)
        var i = 0
        while(i<players.count){
            if(players[i].selectedAnswer == q.correctOption){
                players[i].points += 1
                players[i].selectedAnswer = ""
            }
            i += 1
        }
        print(q.correctOption)
        switch q.correctOption {
            case "A": answerA.backgroundColor = .green
            case "B": answerB.backgroundColor = .green
            case "C": answerC.backgroundColor = .green
            case "D": answerD.backgroundColor = .green
            default: print("")
        }
    }
    
    @IBAction func selectAnswer(_ sender: UIButton){
        if(sender.tag == 1){
            answerA.backgroundColor = .blue
            players[0].selectedAnswer = "A"
            answerB.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 2){
            answerB.backgroundColor = .blue
            players[0].selectedAnswer = "B"
            answerA.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 3){
            answerC.backgroundColor = .blue
            players[0].selectedAnswer = "C"
            answerA.backgroundColor = .lightGray
            answerB.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 4){
            answerD.backgroundColor = .blue
            players[0].selectedAnswer = "D"
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
