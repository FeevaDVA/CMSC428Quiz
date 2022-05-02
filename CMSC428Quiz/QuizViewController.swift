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
    
    @IBOutlet weak var timer:UILabel!
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
        let q:Questions = curQuiz.questions[curQ]
        
        answerA.setTitle("A. " + q.options.A, for: .normal)
        answerB.setTitle("B. " + q.options.B, for: .normal)
        answerC.setTitle("C. " + q.options.C, for: .normal)
        answerD.setTitle("D. " + q.options.D, for: .normal)
        
        question.text = q.questionSentence
        questionAmount.text = String(q.number) + "/" + String(curQuiz.questions.count)
        
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
