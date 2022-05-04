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
    var points:[UILabel] = []
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
        imagePlayers.append(player2)
        imagePlayers.append(player3)
        imagePlayers.append(player4)
        
        player1.backgroundColor = .blue
        player2.backgroundColor = .lightGray
        player3.backgroundColor = .lightGray
        player4.backgroundColor = .lightGray
        //if multi add other players and stuff
        points.append(points1)
        points1.text = "0"
        points.append(points2)
        points2.text = "0"
        points.append(points3)
        points3.text = "0"
        points.append(points4)
        points4.text = "0"
        
        if(multi == 1){
            session.delegate = self
            let player = Player(peerID: session.myPeerID)
            players.append(player)
            var i = 0
            while(i<session.connectedPeers.count){
                print(session.connectedPeers.count)
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
        //gets the json from url
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
        //waits for function to get json
        while(curQuiz == nil){
            
        }
        //starts the quiz
        startQuiz()
    }
    //parses the json
    func parseJson(data:Data){
        let quiz:Quiz = try! JSONDecoder().decode(Quiz.self, from: data)
        curQuiz = quiz
        curQ = 0
        print(quiz)
    }
    
    //starts the quiz 
    func startQuiz(){
        curQ = 0
        getQuestion()
    }
    
    //gets the current question and displays it also adds the timer
    @objc func getQuestion(){
        let q:Questions = curQuiz.questions[curQ]
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.lowerTime), userInfo: nil, repeats: true)
        
        selectedAnswer = ""
        
        var i = 0
        while(i<players.count){
            imagePlayers[i].backgroundColor = .blue
            i += 1
        }
        
        answerA.isEnabled = true
        answerB.isEnabled = true
        answerC.isEnabled = true
        answerD.isEnabled = true
        
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
    //timer function
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
    //the end of quiz function
    func endQuiz(){
        timer.invalidate()
        
        answerA.isEnabled = false
        answerB.isEnabled = false
        answerC.isEnabled = false
        answerD.isEnabled = false
        
        let q:Questions = curQuiz.questions[curQ - 1]
        var i = 0
        while(i<players.count){
            if(players[i].selectedAnswer == q.correctOption){
                imagePlayers[i].backgroundColor = .green
                players[i].points += 1
                players[i].selectedAnswer = ""
            } else {
                imagePlayers[i].backgroundColor = .red
            }
            i += 1
        }
        print(q.correctOption)
        switch q.correctOption {
            case "A":
                answerA.backgroundColor = .green
            case "B": answerB.backgroundColor = .green
            case "C": answerC.backgroundColor = .green
            case "D": answerD.backgroundColor = .green
            default: print("")
        }
        quizNum += 1
        print(quizNum)
        restartButton.isEnabled = true
        restartButton.isHidden = false
        print("quiz ended")
    }
    //point calculation function
    func calcPoints(){
        timer.invalidate()
       
        answerA.isEnabled = false
        answerB.isEnabled = false
        answerC.isEnabled = false
        answerD.isEnabled = false
        
        let q:Questions = curQuiz.questions[curQ - 1]
        let time = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.getQuestion), userInfo: nil, repeats: false)
        var i = 0
        while(i<players.count){
            if(players[i].selectedAnswer == q.correctOption){
                players[i].points += 1
                points[i].text = String(players[i].points)
                imagePlayers[i].backgroundColor = .green
                players[i].selectedAnswer = ""
            } else {
                imagePlayers[i].backgroundColor = .red
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
    //button action
    @IBAction func selectAnswer(_ sender: UIButton){
        if(sender.tag == 1){
            answerA.backgroundColor = .blue
            players[0].selectedAnswer = "A"
            do {
                let d = "A"
                try session.send(d.data(using: String.Encoding.ascii, allowLossyConversion: true)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                print("error")
            }
            answerB.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 2){
            answerB.backgroundColor = .blue
            players[0].selectedAnswer = "B"
            do {
                let d = "B"
                try session.send(d.data(using: String.Encoding.ascii, allowLossyConversion: true)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                print("error")
            }
            answerA.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 3){
            answerC.backgroundColor = .blue
            players[0].selectedAnswer = "C"
            do {
                let d = "C"
                try session.send(d.data(using: String.Encoding.ascii, allowLossyConversion: true)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                print("error")
            }
            answerA.backgroundColor = .lightGray
            answerB.backgroundColor = .lightGray
            answerD.backgroundColor = .lightGray
        } else if(sender.tag == 4){
            answerD.backgroundColor = .blue
            players[0].selectedAnswer = "D"
            do {
                let d = "D"
                try session.send(d.data(using: String.Encoding.ascii, allowLossyConversion: true)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                print("error")
            }
            answerB.backgroundColor = .lightGray
            answerC.backgroundColor = .lightGray
            answerA.backgroundColor = .lightGray
        }
    }
    @IBAction func restart(){
        do {
            let d = "restart"
            try session.send(d.data(using: String.Encoding.ascii, allowLossyConversion: true)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {
            print("error")
        }
        restartButton.isEnabled = false
        restartButton.isHidden = true
        curQuiz = nil
        players = []
        points = []
        imagePlayers = []
        viewDidLoad()
    }
}
//session delegate need to handle recieving data ie receiving selected answer
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
        if let string = String(data: data, encoding: String.Encoding.ascii){
            print(string)
            if(string == "restart"){
                DispatchQueue.main.async {
                    self.restartButton.isEnabled = false
                    self.restartButton.isHidden = true
                    self.players = []
                    self.points = []
                    self.imagePlayers = []
                    self.curQuiz = nil
                    self.viewDidLoad()
                }
            } else {
                var i = 0
                while(i<players.count){
                    if(players[i].peerID == peerID){
                        players[i].selectedAnswer = string
                    }
                    i += 1
                }
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}
