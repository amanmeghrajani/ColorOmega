//
//  GameController.swift
//  ColorOmega
//
//  Created by  user on 7/18/17.
//  Copyright © 2017 Aman Meghrajani. All rights reserved.
//

import UIKit
import LTMorphingLabel


class GameController: UIViewController {
    
    var hideStatusBar = true
    var levels : [Int : Int] = HelperFunctionsController.levels()
    var stages : [String] = ["Bronze", "Silver", "Golden"]
    var currentStage = "Bronze"
    var points = 0
    var currentLevel : Int = 1
    var tiles = [String:UIView]()
    var winningColor : String = ""
    var winningView = UIView()
    var box = UIView()
    var viewsPerRow : Int?
    var rowsPerColumn : Int?
    var vc : ViewController?
    
    var timeLabel        = SACountingLabel()
    var textLabel        = LTMorphingLabel()
    var pointsLabel      = LTMorphingLabel()
    var congratsLabel    = LTMorphingLabel()
    var stageImageView   = UIImageView()
    
    var containerView = UIView()
    let containerHeight : CGFloat = 50
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        box.backgroundColor = .black
        box.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.textColor = .white
        timeLabel.backgroundColor = .black
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.textColor = .white
        textLabel.backgroundColor = .black
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pointsLabel.textColor = .white
        pointsLabel.backgroundColor = .black
        pointsLabel.textAlignment = .center
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.morphingDuration = 1
        pointsLabel.morphingEffect = .burn
        pointsLabel.text = "0"
        
        stageImageView.backgroundColor = .black
        stageImageView.sizeToFit()
        stageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .black
        containerView.addSubview(timeLabel)
        containerView.addSubview(textLabel)
        containerView.addSubview(pointsLabel)
        containerView.addSubview(stageImageView)
        
        //hide the timeLabel for level Bronze
        timeLabel.alpha = 0
        
        view.addSubview(box)
        view.addSubview(containerView)
        
        //the contraints run on a different thread, so by the time the game starts for the first time, the view isnt laid out, cheap hack:
        box.frame = CGRect(x: 0, y: 50, width: self.view.bounds.width, height: self.view.bounds.height - self.containerHeight)
        
        NSLayoutConstraint.activate([

            
            containerView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.heightAnchor.constraint(equalToConstant: self.containerHeight),
            
            box.topAnchor.constraint(equalTo: containerView.bottomAnchor),
            box.leftAnchor.constraint(equalTo: view.leftAnchor),
            box.rightAnchor.constraint(equalTo: view.rightAnchor),
            box.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textLabel.widthAnchor.constraint(equalToConstant: 170),

            pointsLabel.leftAnchor.constraint(equalTo: textLabel.rightAnchor, constant: 5),
            pointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            pointsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pointsLabel.widthAnchor.constraint(equalToConstant: 35),
            
            
            timeLabel.rightAnchor.constraint(equalTo: textLabel.leftAnchor),
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 35),
            
            
            stageImageView.rightAnchor.constraint(equalTo: timeLabel.leftAnchor),
            stageImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stageImageView.heightAnchor.constraint(equalToConstant: 30),
            stageImageView.widthAnchor.constraint(equalToConstant: 30)
            ])
        
        //coz level 1 shows only one tile, level 2 is technically level 1, we go to 11 levels before promoting the user to stage 2 and stage 3
        startGame(level: 2)
        
    }
    
    
    
    
    
    

    
    
    
    
    
    
    
    // To start a new level in the game, this method will be called and the level will be passed
    func startGame(level l : Int) {
        
        //if level 10, user won the game, dismiss GameViewController and congratulate User
        
        //sart fresh
        box.subviews.forEach { $0.removeFromSuperview()}
        self.tiles = [:]
        
        if l >= 9 {
            //change stage
            var index = self.stages.index(of: self.currentStage)!
            if index < 2 {
                index = index + 1
            } else {
                //player won
                self.showCongratulationsAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    self.gameOver(true)
                })
            }
            self.currentStage = stages[index]
            self.currentLevel = 2
            setupStageImage()
            arrangeTiles(howMany: levels[2]!)
        }
        else{
            setupStageImage()
            self.currentLevel = l
            arrangeTiles(howMany: self.levels[l]!)
        }
        //else
        //setLevel as a global object
        //arrangeTile()
    }
    
    
    
    
    
    
    
    
    
    
    //Once the game is started and the level received, the decision would have been made about the amount of views to be placed on the screen and the time allowed for the user to pick the correct color
    var colorChangeTimer : Timer?
    
    func arrangeTiles(howMany number : Int){
        
        let sroot = Int(sqrt(Double(number)))
        let rowsPerColumn = sroot
        let viewsPerRow = sroot
        
        self.rowsPerColumn = rowsPerColumn
        self.viewsPerRow = viewsPerRow
        
        
      
        let height = box.frame.height / CGFloat(rowsPerColumn)
        let width = box.frame.width / CGFloat(viewsPerRow)
        
        for j in 0..<rowsPerColumn{
            for i in 0..<viewsPerRow{
                
                //get color and colorname, and make sure that the string is small enough to fix into the box
                let tileView = UIView()
                let color = HelperFunctionsController.randomColor()
                
                tileView.backgroundColor = color
                
                //quick check before setting colorName
                let checkedColorName = color.closestColorName
                tileView.layer.setValue(checkedColorName, forKey: "color")
                tileView.frame = CGRect(x: CGFloat(i) * width, y: CGFloat(j) * height, width: width, height: height)
                tileView.layer.borderWidth = 0.5
                tileView.layer.borderColor = UIColor.black.cgColor
                box.addSubview(tileView)
                let key = "\(i)|\(j)"
                tiles[key] = tileView
                  box.layoutIfNeeded()
            }
        }
        
        
        //add gesture recognizers for teh views
        let tileSelectGesture    = UITapGestureRecognizer(target: self, action: #selector(tileSelected))
        //      let moveContainergesture = UIPanGestureRecognizer(target: self, action: #selector(moveContainerView))
        let zoomTileGesture      = UIPanGestureRecognizer(target: self, action: #selector(zoomIfNecessary))
        
        tileSelectGesture.numberOfTapsRequired = 2
        box.addGestureRecognizer(tileSelectGesture)
        box.addGestureRecognizer(zoomTileGesture)
        //      containerView.addGestureRecognizer(moveContainergesture)
        
        //SETUP Label with color
        //view.addSubview(containerView)
        //view.bringSubview(toFront: containerView)
        
        //choose a random color and set it as the color to be picked by the player to win
        //choose a totally random view between the index of 0 and n number of views
        
        setupWinningTile()
        
        //start timer if stage is silver or gold
        if self.currentStage == "Silver"{
        startTimer(forSeconds: 20)
        }
        
        if self.currentStage == "Golden" {
            //every 3 seconds, change colors
            startTimer(forSeconds: 30)
            self.colorChangeTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeColors), userInfo: nil, repeats: true)
        }
    }
    
    
    
    func changeColors(){
        
        UIView.animate(withDuration: 2, delay: 0, options: [], animations: {
            for (tile) in self.tiles.values.enumerated() {
                let color = HelperFunctionsController.randomColor()
                let colorName = color.closestColorName
                
                tile.element.backgroundColor = color
                tile.element.layer.setValue(colorName, forKey: "color")
            }
            self.setupWinningTile()
            
        }, completion: nil)
        
    }
    
    
    func setupWinningTile(){
        var randInt = Int(arc4random_uniform(UInt32(tiles.count)))
        winningView = tiles[Array(tiles.keys)[randInt]]!
        winningColor = winningView.layer.value(forKey: "color") as! String
        
        
        //replace winning view to be one with a shorter name
        if winningColor.characters.count > 18 {
            randInt = Int(arc4random_uniform(UInt32(tiles.count)))
            winningView = tiles[Array(tiles.keys)[randInt]]!
        }
        //dangerous way to cast, but will work
        winningColor = winningView.layer.value(forKey: "color") as! String
        textLabel.text = winningColor

    }
    
    
    
    
    //helper func
    var selectedCell : UIView?
    
    func zoomIfNecessary(gesture: UIPanGestureRecognizer){
        if box.subviews.count > 25 {
            let location = gesture.location(in: box)
            
            let width = box.frame.width / CGFloat(viewsPerRow!)
            let height = box.frame.height / CGFloat(rowsPerColumn!)
            
            let i = Int(location.x / width)
            let j = Int(location.y / height)
            
            let key = "\(i)|\(j)"
            guard let tileView = tiles[key] else { return }
            
            if selectedCell != tileView{
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.selectedCell?.layer.transform = CATransform3DIdentity
                }, completion: nil)
            }
            
            selectedCell = tileView
            
            box.bringSubview(toFront: tileView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                tileView.layer.transform = CATransform3DMakeScale(3, 3, 3)
            }, completion: nil)
            
            if gesture.state == .ended {
                UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    tileView.layer.transform = CATransform3DIdentity
                }, completion: {
                    (_) in
                    self.box.bringSubview(toFront: self.containerView)
                })
            }
        }
    }
    
    
    
    
    
    
    
    
    
    //This will lead to two method calls, one to the timer to start ticking and one to the handler that will detect the touch/guess the user makes, lets start with the touch handler
    
    func tileSelected(gesture : UITapGestureRecognizer){
        
        //invalidate Timers
        invalidateTimers()
        
        let location = gesture.location(in: box)
        let width = box.frame.width / CGFloat(viewsPerRow!)
        let height = box.frame.height / CGFloat(rowsPerColumn!)
        
        let i = Int(location.x / width)
        let j = Int(location.y / height)
        
        let key = "\(i)|\(j)"
        let tileView = tiles[key]
         if tileView?.layer.value(forKey: "color") as! String == winningColor {
            takeWinnerToTheNextLevel()
        } else {
            //show which view was the correct one
            self.showWinningTileAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.gameOver(false)
            })
        }
        //stop TimerX
        //if correct, takeWinnerToNextLevel()
        //else , GameOver
    }
    
    
    //next start the timer
    
    var timer : Timer?
    
    func startTimer(forSeconds sec : Int){
        //set Timer as a global object so it can be stopped
        timer = nil
        textLabel.morphingDuration = 2
        textLabel.morphingEffect = .scale
        
        let seconds = Float(sec)
        let dseconds = Double(sec)
        
        timeLabel.alpha = 1
        timeLabel.countFrom(fromValue: seconds + 1 , to: 0, withDuration: dseconds, andAnimationType: .EaseIn, andCountingType: .Int)
        timer = Timer.scheduledTimer(timeInterval: dseconds, target: self, selector: #selector(timeFinished), userInfo: ["time" : timeLabel.currentValue], repeats: false)
   
    }
    
    
    
    
    func timeFinished(timer: Timer){
        //invalidate Timers
        invalidateTimers()
        self.showWinningTileAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.gameOver(false)
        })
    }
    
    
    //if wrong tile selected or time elapased, GameOver()
    
    func gameOver(_ won: Bool){
        invalidateTimers()
        self.vc = self.presentingViewController as? ViewController
        self.dismiss(animated: true, completion: {
            self.vc?.setupTopPlayerScoreboard()
            self.vc?.saveScore()
            self.removeAllSubviews(ofView : self.view, flag: 1)
        })
    }
    
    
    //if won, takeWinnerToNextLevel()
    
    
    func takeWinnerToTheNextLevel(){
        //increase points
        if self.currentStage == "Golden" {
            addPoints(points: 50)
        } else if self.currentStage == "Silver"{
            addPoints(points: 30)
        } else {
            addPoints(points: 10)
        }
        pointsLabel.text = String(points)
        currentLevel = currentLevel + 1
        startGame(level: currentLevel)
        //call startGame again, increase the level global object and pass is to the startGame()
    }
    
    
    

    
    
    override var prefersStatusBarHidden: Bool {
        return self.hideStatusBar
    }
    
    
    
    func showWinningTileAnimation(){
        self.winningView.shakeAndCenter()
        UIView.animate(withDuration: 2, delay: 0, options: [], animations: {
            for tile in self.tiles.values {
                if tile != self.winningView{
                tile.alpha = 0
                }
            }
        }, completion: nil)
        //dismiss other views

    }
    
    func checkColorName(unchecked : String) -> String {
        if unchecked.characters.count > 18 {
            //logic to reduce string length to a maximum of 18 characters
            return unchecked
        }
        return unchecked
    }
    
    
    
    func setupStageImage(){
        let stage = self.currentStage
        
        switch (stage){
        case "Bronze":
        self.stageImageView.image = #imageLiteral(resourceName: "bronze")
        self.pointsLabel.textColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        break
        case "Silver":
        self.stageImageView.image = #imageLiteral(resourceName: "silver")
        self.pointsLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        break
        case "Golden" :
        self.stageImageView.image = #imageLiteral(resourceName: "gold")
        self.pointsLabel.textColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
        
        break
        default:
        self.stageImageView.image = #imageLiteral(resourceName: "bronze")
        break
        }
    }
    
    func invalidateTimers(){
        self.timer?.invalidate()
        self.timer = nil
        
        self.colorChangeTimer?.invalidate()
        self.colorChangeTimer = nil
    }
    
    
    func showCongratulationsAnimation(){

        
        for subview in self.view.subviews {
            subview.alpha = 0
        }
        congratsLabel.alpha = 0
        congratsLabel.morphingEffect = .fall
        congratsLabel.textColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        congratsLabel.textAlignment = .center
        congratsLabel.frame = self.view.frame
        
        self.view.addSubview(self.congratsLabel)

        UIView.animate(withDuration: 3) {
            self.congratsLabel.text = "You Win \(self.points) points!"
            self.congratsLabel.alpha = 1
            self.congratsLabel.font = UIFont.boldSystemFont(ofSize: 30)
            self.congratsLabel.alpha = 0
        }
    }
    
    func addPoints(points : Int){
        self.vc = self.presentingViewController as? ViewController
        self.points += points
        self.vc?.addPointsToScore(points)
        self.vc?.updateScoreLabel()
        self.vc?.saveScore()
    }
    
    
    func removeAllSubviews(ofView v : UIView, flag : Int){
        //base case 
        if view.subviews.count == 0 {
            v.removeFromSuperview()
            return
        }  else {
            for subv in v.subviews {
                removeAllSubviews(ofView: subv, flag: 0)
            }
            if flag == 1 {
                return
            } else {
                v.removeFromSuperview()
                return
            }
        }
    }
    

    

    
}

extension UIView {
    func shakeAndCenter(){
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 1
        animation.values = [-20, 30, -30, 20, -10, 10, -5, 5, 0]
        layer.borderWidth = 0.9
        layer.borderColor = UIColor.white.cgColor
        layer.add(animation, forKey: "shake")
        self.superview?.bringSubview(toFront: self)
        UIView.animate(withDuration: 2, delay: 1, options: [], animations: {
            self.center.x = (self.superview?.superview?.center.x)!
            self.center.y = (self.superview?.superview?.center.y)!
        }, completion: nil)
    }

}
