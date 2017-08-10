//
//  ViewController.swift
//  ColorOmega
//
//  Created by  user on 7/18/17.
//  Copyright © 2017 Aman Meghrajani. All rights reserved.
//

import UIKit
import Firebase
import ReachabilitySwift
import SAMKeychain
import SkyFloatingLabelTextField
import LTMorphingLabel



class ViewController: UIViewController {

    var hideStatusBar = true
    public var score : Int = 0
    var ref : FIRDatabaseReference?
    var containerView = UIView()
    var pointsView = UILabel()
    var scoreBoardView = UIView()
    var scoreLabel = UILabel()
    var scoreBoardLabel = UILabel()
    var settingsButton : UIButton!
    var userDefault : UserDefaults! = UserDefaults()
    var scoreKey = "score"
    var usernameKey = "username"
    var anonymousKey = "anonymous"
   
    lazy var uuid : String = {
        return self.UUID()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let mainview = self.view!
        mainview.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        let welcomeLabel = UILabel()
        let playButton = UIButton(frame: CGRect(x: 125, y: 400, width: 100, height: 50))
        self.settingsButton = UIButton(frame: CGRect(x: 125, y: 600, width: 100, height: 50))

        mainview.addSubview(settingsButton)
        mainview.addSubview(playButton)
        mainview.addSubview(welcomeLabel)
        mainview.addSubview(containerView)
        mainview.addSubview(scoreBoardLabel)
        mainview.addSubview(scoreBoardView)
        
        containerView.addSubview(pointsView)
        containerView.addSubview(scoreLabel)
        
        self.ref = FIRDatabase.database().reference().child("users")
        
        checkIfUserIsRegistered()
        
        //lets add a container where the user can see the score
        containerView.translatesAutoresizingMaskIntoConstraints = false
        //containerView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        containerView.isOpaque = true
        
        pointsView.translatesAutoresizingMaskIntoConstraints = false
        //  pointsView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        pointsView.isOpaque = true
        pointsView.textColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        pointsView.textAlignment = .center
        pointsView.font = UIFont.italicSystemFont(ofSize: 20)
        pointsView.text = "0"
        updateScoreLabel()

        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        //scoreLabel.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        scoreLabel.isOpaque = true
        scoreLabel.textColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        scoreLabel.textAlignment = .center
        scoreLabel.text = "Score : "
        scoreLabel.font =  UIFont.italicSystemFont(ofSize: 20)
        
        
        
        playButton.backgroundColor = UIColor.brown
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchDown)
        
        settingsButton.backgroundColor = UIColor.brown
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchDown)
        
        welcomeLabel.text = "Color Omega"
        welcomeLabel.textColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        welcomeLabel.font = UIFont.italicSystemFont(ofSize: 30)
        welcomeLabel.textAlignment = .center
        
        scoreBoardView.isOpaque = false
        //scoreBoardView.backgroundColor = .black
        
        scoreBoardLabel.textColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        scoreBoardLabel.font = UIFont.italicSystemFont(ofSize: 18)
        scoreBoardLabel.textAlignment = .center
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        scoreBoardView.translatesAutoresizingMaskIntoConstraints = false
        scoreBoardLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
        containerView.leftAnchor.constraint(equalTo: mainview.leftAnchor),
        containerView.rightAnchor.constraint(equalTo: mainview.rightAnchor),
        containerView.topAnchor.constraint(equalTo: mainview.topAnchor),
        containerView.heightAnchor.constraint(equalToConstant: 50),
        
        scoreLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
        scoreLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5),
        scoreLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        
        pointsView.topAnchor.constraint(equalTo: containerView.topAnchor),
        pointsView.leftAnchor.constraint(equalTo: scoreLabel.rightAnchor),
        pointsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

        
        welcomeLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor),
        welcomeLabel.leftAnchor.constraint(equalTo: mainview.leftAnchor),
        welcomeLabel.rightAnchor.constraint(equalTo: mainview.rightAnchor),
        welcomeLabel.heightAnchor.constraint(equalToConstant: 200),
        
        
        playButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor),
        playButton.centerXAnchor.constraint(equalTo: mainview.centerXAnchor, constant: -75),
        playButton.widthAnchor.constraint(equalToConstant: 100),
        playButton.heightAnchor.constraint(equalToConstant: 50),
        
        settingsButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor),
        settingsButton.centerXAnchor.constraint(equalTo: mainview.centerXAnchor, constant: 75),
        settingsButton.widthAnchor.constraint(equalToConstant: 100),
        settingsButton.heightAnchor.constraint(equalToConstant: 50),
        
        scoreBoardLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 45),
        scoreBoardLabel.leftAnchor.constraint(equalTo: mainview.leftAnchor, constant: 25),
        scoreBoardLabel.rightAnchor.constraint(equalTo: mainview.rightAnchor, constant: -25),
        scoreBoardLabel.heightAnchor.constraint(equalToConstant: 20),
        
        scoreBoardView.topAnchor.constraint(equalTo: scoreBoardLabel.bottomAnchor, constant: 0),
        scoreBoardView.leftAnchor.constraint(equalTo: mainview.leftAnchor, constant: 35),
        scoreBoardView.rightAnchor.constraint(equalTo: mainview.rightAnchor, constant: -35),
        scoreBoardView.bottomAnchor.constraint(equalTo: mainview.bottomAnchor, constant: -5)
        
            ])

        //animateMainViewWithColors(10)
        setupTopPlayerScoreboard()
    }
    
    func playButtonTapped(){
        let gameController = GameController()
        gameController.modalTransitionStyle = .flipHorizontal
        self.present(gameController, animated: true, completion: nil)
    }
    
    func settingsButtonTapped(){
        
        let settingsController = SettingsViewController()
        settingsController.modalTransitionStyle = .flipHorizontal
        self.present(settingsController, animated: true, completion: {
            (_) in
          
        })
    }
    
    
    
    
    
    func saveScore(){
        UserDefaults.standard.set(self.score, forKey: self.scoreKey)
        verifyRegistrationInDatabase()
        updateScoreInDB()
    }
    
    func addPointsToScore(_ points : Int){
        self.score += points
    }
    
    func updateScoreLabel(){
        self.pointsView.text = formatNumber(self.score)
        self.pointsView.layoutIfNeeded()

    }
    
//    
//    func loadUsersScoreFromDB(){
//        ref?.child(self.uuid).child("score").observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.value != nil{
//                self.score = (snapshot.value as? Int) ?? 0
//                self.pointsView.text = self.formatNumber(self.score)
//            }
//        })
//    }
    
    func updateScoreInDB(){
        if ViewController.hasConnectivity(){
            self.ref?.child(self.uuid).child(self.scoreKey).setValue(self.score)
        }
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return self.hideStatusBar
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
    //goal, init user score and info if this is the first time
    func checkIfUserIsRegistered(){
        
        //load points if in local db, else create
        if UserDefaults.standard.object(forKey: self.scoreKey) != nil {
        self.score = UserDefaults.standard.integer(forKey: self.scoreKey)
        } else {
            UserDefaults.standard.set(self.score, forKey: self.scoreKey)
        }
        verifyRegistrationInDatabase()

    }
    
    
    
    

    func verifyRegistrationInDatabase(){
        if !ViewController.hasConnectivity(){
            return //no internet connected
        }
        
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            //if user already exists, do nothing, else create user
            if snapshot.hasChild(self.uuid){
                 //user already in db, lets check if db has the correct score
                let scoreInDB = snapshot.childSnapshot(forPath: self.uuid).childSnapshot(forPath: self.scoreKey).value as? Int
                //MARK
                //IF The user deletes The App and redownloads it, we want to provide the user with their accumulated score in the lifetime of their gameplay
                if scoreInDB != self.score {
                    if scoreInDB != nil{
                        if scoreInDB! > self.score{
                            //when the user redownloads and immediately loses internet and plays the game, the points will be only of that session, we will reward the user those points by adding it to the points accumulated on the server
                            self.score = self.score + scoreInDB!
                            self.updateScoreLabel()
                        }
                    }
                    self.updateScoreInDB()
                }
                return
            } else {
                //user not in db, lets set it up
                self.ref?.child(self.uuid).child(self.scoreKey).setValue(self.score)
                self.ref?.child(self.uuid).child(self.usernameKey).setValue(self.anonymousKey)
            }
        })
    }
    
    
    
    
    
    
    
    func formatNumber(_ num : Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        let formattedNumber = nf.string(from: NSNumber(integerLiteral: num))
        return formattedNumber!
    }
    
    
    //check internet connectivity
    class func hasConnectivity() -> Bool {
        
            let reachability: Reachability? = Reachability.init()
            let networkStatus = reachability?.currentReachabilityStatus
            
            if networkStatus == .notReachable {
                return false
            } else {
                return true
            }
    }
    
    func UUID() -> String {
        
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        let accountName = "incoding"
        
        var applicationUUID = SAMKeychain.password(forService: bundleName, account: accountName)
        
        if applicationUUID == nil {
            
            applicationUUID = UIDevice.current.identifierForVendor!.uuidString
            
            // Save applicationUUID in keychain without synchronization
            let query = SAMKeychainQuery()
            query.service = bundleName
            query.account = accountName
            query.password = applicationUUID
            query.synchronizationMode = SAMKeychainQuerySynchronizationMode.no
            
            do {
                try query.save()
            } catch let error as NSError {
                print("SAMKeychainQuery Exception: \(error)")
            }
        }
        
        return applicationUUID!
    }
    
    
    
    
    
    func setupTopPlayerScoreboard(){
        if !ViewController.hasConnectivity(){
            return // no internet
        }
        self.scoreBoardLabel.text = "Worlds Top 5"
        
        let query = ref?.queryOrdered(byChild: "score").queryLimited(toLast: 5)
        query?.observe(.value, with: { (snapshot) in
          var ranks : [Int: [String]] = [:]
            
            var index = Int(exactly: snapshot.childrenCount)!
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                if (index <= 0){
                    return
                }
                var values : [String] = []
                let username = rest.childSnapshot(forPath: "username").value
                let score = rest.childSnapshot(forPath: "score").value
                
                if let uname = username, let s = score {
                    values.append((uname as? String)!)
                    values.append(self.abbreviateNumber(num: (s as? Int)!))
                    ranks[index] = values
                    index -= 1
                    
                }
               
                
                if ranks.count == Int(exactly: snapshot.childrenCount)! {
                    self.createScoreBoardView(ranks)
                }
            }
        })
    }
    
    
    var labels : [LTMorphingLabel]!
    
    func createScoreBoardView(_ ranks : [Int: [String]]){
        
        if labels != nil {
            //scoreboardview already there, just needs update
            updateScoreBoardView(ranks)
            return
        }
        
        let sbHeaderLine = SkyFloatingLabelTextField()
        sbHeaderLine.translatesAutoresizingMaskIntoConstraints = false
        sbHeaderLine.isUserInteractionEnabled = false
        //sbHeaderLabel.placeholder
        sbHeaderLine.placeholderColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        //sbHeaderLabel.font = UIFont.italicSystemFont(ofSize: 15)
        
        scoreBoardView.addSubview(sbHeaderLine)
        
        NSLayoutConstraint.activate([
            sbHeaderLine.leftAnchor.constraint(equalTo: scoreBoardView.leftAnchor),
            sbHeaderLine.rightAnchor.constraint(equalTo: scoreBoardView.rightAnchor),
            sbHeaderLine.topAnchor.constraint(equalTo: scoreBoardView.topAnchor),
            sbHeaderLine.heightAnchor.constraint(equalToConstant: 10)
            ])
        
        self.labels = getLabels(howmany: (ranks.count + 1)*3)
        
        let heightOfRows : CGFloat = scoreBoardView.bounds.height / CGFloat((ranks.count + 1) * 2)
        
        let usernameIndex = 0
        let scoreIndex = 1
        var previousLine = SkyFloatingLabelTextField()
        var i = 0
        
        for index in 0...ranks.count{
            
            //line
            let line = SkyFloatingLabelTextField()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.isUserInteractionEnabled = false
            line.placeholderColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
            scoreBoardView.addSubview(line)
            
            
            if index == 0{
                
                let rankLabel = self.labels[i] ; i+=1
                rankLabel.text = "Rank"
                
                let usernameLabel = self.labels[i]  ; i+=1
                usernameLabel.text = "Username"
                
                let scoreLabel = self.labels [i] ; i+=1
                scoreLabel.text = "Score"
                
                previousLine = line
                NSLayoutConstraint.activate([
                    rankLabel.topAnchor.constraint(equalTo: sbHeaderLine.bottomAnchor, constant: 0),
                    rankLabel.leftAnchor.constraint(equalTo: scoreBoardView.leftAnchor, constant: 0),
                    rankLabel.widthAnchor.constraint(equalToConstant: scoreBoardView.bounds.width / 3),
                    rankLabel.heightAnchor.constraint(equalToConstant: heightOfRows),
                    
                    
                    usernameLabel.leftAnchor.constraint(equalTo: rankLabel.rightAnchor, constant: 0),
                    usernameLabel.widthAnchor.constraint(equalToConstant: scoreBoardView.bounds.width / 3),
                    usernameLabel.topAnchor.constraint(equalTo: sbHeaderLine.bottomAnchor, constant: 0),
                    usernameLabel.heightAnchor.constraint(equalToConstant: heightOfRows),
                    
                    
                    scoreLabel.topAnchor.constraint(equalTo: sbHeaderLine.bottomAnchor, constant: 0),
                    scoreLabel.leftAnchor.constraint(equalTo: usernameLabel.rightAnchor),
                    scoreLabel.heightAnchor.constraint(equalToConstant: heightOfRows),
                    scoreLabel.rightAnchor.constraint(equalTo: scoreBoardView.rightAnchor),
                    
                    line.leftAnchor.constraint(equalTo: scoreBoardView.leftAnchor),
                    line.rightAnchor.constraint(equalTo: scoreBoardView.rightAnchor),
                    line.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
                    line.heightAnchor.constraint(equalToConstant: 5)

                    ])
                continue
            }
               else {
      
                
                let rankLabel = self.labels[i] ; i+=1
                rankLabel.text = String(index)
                
                let usernameLabel = self.labels[i] ; i+=1
                usernameLabel.text = ranks[index]?[usernameIndex]
                
                let scoreLabel = self.labels[i] ; i+=1
                scoreLabel.text = ranks[index]?[scoreIndex]
                
                NSLayoutConstraint.activate([
                    rankLabel.topAnchor.constraint(equalTo: previousLine.bottomAnchor, constant: 0),
                    rankLabel.leftAnchor.constraint(equalTo: scoreBoardView.leftAnchor, constant: 0),
                    rankLabel.widthAnchor.constraint(equalToConstant: scoreBoardView.bounds.width / 3),
                    rankLabel.heightAnchor.constraint(equalToConstant: heightOfRows),
                    
                    
                    usernameLabel.leftAnchor.constraint(equalTo: rankLabel.rightAnchor, constant: 0),
                    usernameLabel.widthAnchor.constraint(equalToConstant: scoreBoardView.bounds.width / 3),
                    usernameLabel.topAnchor.constraint(equalTo: previousLine.bottomAnchor, constant: 0),
                    usernameLabel.heightAnchor.constraint(equalToConstant: heightOfRows),
                    
                    
                    scoreLabel.topAnchor.constraint(equalTo: previousLine.bottomAnchor, constant: 0),
                    scoreLabel.leftAnchor.constraint(equalTo: usernameLabel.rightAnchor),
                    scoreLabel.heightAnchor.constraint(equalToConstant: heightOfRows),
                    scoreLabel.rightAnchor.constraint(equalTo: scoreBoardView.rightAnchor),
                    
                    line.leftAnchor.constraint(equalTo: scoreBoardView.leftAnchor),
                    line.rightAnchor.constraint(equalTo: scoreBoardView.rightAnchor),
                    line.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
                    line.heightAnchor.constraint(equalToConstant: 5)

                    ])
                
                previousLine = line
            }
            

        }
    }
    
    
    func updateScoreBoardView(_ ranks : [Int: [String]]){
        //all constraints and everything is setup, just update
        //first three indexes are just labels
        let usernameIndex = 0
        let scoreIndex = 1
        var i = 0
        
        for index in 0...ranks.count{
            if index == 0 {
                i = i + 3 // skip first three indexes
            }
            else{
                
                let rankLabel = self.labels[i] ; i+=1
                rankLabel.text = String(index)
                
                let usernameLabel = self.labels[i] ; i+=1
                usernameLabel.text = ranks[index]?[usernameIndex]
                
                let scoreLabel = self.labels[i] ; i+=1
                scoreLabel.text = ranks[index]?[scoreIndex]
        }
    }
    }
    

    
    func abbreviateNumber(num: Int) -> String {
        // less than 1000, no abbreviation
        if num < 1000 {
            return "\(num)"
        }
        
        // less than 1 million, abbreviate to thousands
        if num < 1000000 {
            var n = Double(num);
            n = Double( floor(n/100)/10 )
            return "\(n.description)k"
        }
        
        // more than 1 million, abbreviate to millions
        var n = Double(num)
        n = Double( floor(n/100000)/10 )
        return "\(n.description)m"
    }
    
    
    func getLabels (howmany n : Int) -> [LTMorphingLabel] {
        var returnDict : [Int: LTMorphingLabel] = [:]
        var returnArray : [LTMorphingLabel] = []
        for index in 1...n {
            let label = LTMorphingLabel()
            label.textColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
            label.font = UIFont.italicSystemFont(ofSize: 13)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            self.scoreBoardView.addSubview(label)
            returnArray.append(label)
            returnDict[index] = label
        }
        return returnArray
    }

    

   
    


            }



