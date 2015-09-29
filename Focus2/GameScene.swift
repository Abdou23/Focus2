//
//  GameScene.swift
//  Focus2
//
//  Created by AbdelGhafour on 8/17/15.
//  Copyright (c) 2015 Abdou23. All rights reserved.
//

import SpriteKit
import iAd

//MARK:- Physics
struct PhysicsCategory {
    
    static let HeroCategory: UInt32 =          0x1 << 0
    static let BlockCategory: UInt32 =         0x1 << 1
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK:- Variables

    // Layers
    let blockLayer = SKNode()
    let bgLayer = SKNode()
    
    // Nodes
    var block = SKSpriteNode()
    var blockLeft = SKSpriteNode()
    var blockRight = SKSpriteNode()
    //var hero = SKShapeNode()
    var hero = SKSpriteNode()
    //var heroRight = SKShapeNode()
    var heroRight = SKSpriteNode()
    
    // Labels
    var scoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold ")
    var highScoreLabel = SKLabelNode(fontNamed: "STHeitiTC-Medium")
    var startLabel = SKLabelNode(fontNamed: "STHeitiTC-Medium")
    var instructionsLabel = UILabel()
    var hsFrame = SKSpriteNode() // highscore label frame
    
    // Values
    var previous = UInt32()
    var colorNumber = 1
    var colorNumberRight = 1
    var score = 0
    var highScore = 0
    var qWidth: CGFloat!
    
    // Colors
    let redColor = UIColor(red: 255 / 255, green: 47 / 255, blue: 47 / 255, alpha: 1)
    let tealColor = UIColor(red: 36 / 255, green: 198 / 255, blue: 198 / 255, alpha: 1)
    let orangeColor = UIColor(red: 255 / 255, green: 141 / 255, blue: 47 / 255, alpha: 1)
    let blueColor = UIColor(red: 58 / 255, green: 93 / 255, blue: 209 / 255, alpha: 1)
    let purpleColor = UIColor(red: 151 / 255, green: 47 / 255, blue: 208 / 255, alpha: 1)
    
    // Timers
    var spawnTimer = NSTimer()
    var spawnTwoBlocks = NSTimer()
    
    // Bools
    var isStarted = false
    var isFirstTime = true
    var isPhaseOne = true
    
    // Arrays
    var colors = [UIColor]()
    var names = [String]()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self

        anchorPoint = CGPointZero
        addChild(blockLayer)
        addChild(bgLayer)
        //blockLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        //backgroundColor = UIColor(red: 0.94, green: 0.97, blue: 1, alpha: 1)

        qWidth = size.width / 4
        
        createBackground()
        print(size.height)
        print(qWidth)
        
        if let storedHighScore: AnyObject  = NSUserDefaults.standardUserDefaults().objectForKey("highScore") {
            
            highScore = storedHighScore as! Int
        }
        
        colors = [blueColor, redColor, tealColor, orangeColor, purpleColor]
        names = ["blue", "yellow","cyan", "pink", "red"]
        createLabels()


    }
    
//MARK:- Setup
    
    func randomNumber(max: UInt32) -> UInt32 {
        
        var random = arc4random_uniform(max)
        
        while previous == random {
            
            random = arc4random_uniform(max)
        }
        
        previous = random // Previous should be on the left
        
        return random
    }
    
    
    func newGame() {
     
        score = 0
        
        //runAction(SKAction.waitForDuration(5))
        spawnTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "createBlock", userInfo: nil, repeats: true)
        spawnTwoBlocks = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "createTwoBlocks", userInfo: nil, repeats: true)
        scoreLabel.text = "0"
        createHero()
        isStarted = true
        startLabel.hidden = true
        instructionsLabel.hidden = true
        hsFrame.hidden = true

        if scoreLabel.hidden == true {
            
            scoreLabel.hidden = false
        }
        
        if isFirstTime {

            isFirstTime = false
            
        } else {
            
            scoreLabel.runAction(SKAction.sequence([SKAction.moveByX(0, y: 200, duration: 0.5), SKAction.scaleTo(1, duration: 1)]))

        }

    }

    
    func gameOver() {
        
        if score > highScore {
         
            setHighScore()
            highScoreLabel.text = "Highscore: \(highScore)"
            
        }
        blockLayer.removeAllChildren()
        score = 0
        isStarted = false
        isPhaseOne = true
        colorNumber = 0
        colorNumberRight = 0
        
        hero.removeFromParent()
        heroRight.removeFromParent()
        removeAllActions()
        spawnTimer.invalidate()
        spawnTwoBlocks.invalidate()
        startLabel.hidden = false
        instructionsLabel.hidden = false
        hsFrame.hidden = false
        scoreLabel.runAction(SKAction.sequence([SKAction.moveByX(0, y:  -200, duration: 0.5), SKAction.scaleTo(1.5, duration: 1)]))
        

        
    }
    
//MARK:- Creations
    
    func createBackground() {
        
        let BG = SKSpriteNode(imageNamed: "Night-BG")
        BG.position = CGPoint(x: size.width / 2, y: size.height / 2)
        //BG.size = CGSizeMake(size.width, size.height)
        BG.zPosition = -10
        bgLayer.addChild(BG)
        print(BG.size)
    }
    
    func createLabels() {
        
        // ScoreLabel
        scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = UIColor.brownColor()
        scoreLabel.hidden = true
        
        addChild(scoreLabel)
        
        
        // StartGame Label
        startLabel.text = "Tap to start"
        startLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startLabel.fontSize = 60
        startLabel.fontColor = UIColor.grayColor()
        
        addChild(startLabel)
        
        startLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeInWithDuration(1.5), SKAction.fadeOutWithDuration(1)])))
        
        // Instructions Label <- UILabel
        instructionsLabel = UILabel(frame: CGRectMake(30 , 500 , size.width, 40))
        instructionsLabel.text = "Tap to match ball color with block color"
        instructionsLabel.font = UIFont(name: "STHeitiTC-Medium", size: 20)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        instructionsLabel.sizeToFit()
        instructionsLabel.textAlignment = NSTextAlignment.Center
        instructionsLabel.textColor = UIColor.yellowColor()
        
        view?.addSubview(instructionsLabel) // <- View not self
        
        hsFrame = SKSpriteNode(color: SKColor.grayColor(), size: CGSizeMake(300, 50))
        hsFrame.position = CGPoint(x: size.width / 2, y: size.height / 2 - 70)
        addChild(hsFrame)
        
        highScoreLabel = SKLabelNode(text: "Highscore: \(highScore)")
        highScoreLabel.position.y = highScoreLabel.position.y - 10
        highScoreLabel.fontSize = 30
        highScoreLabel.fontColor = UIColor.whiteColor()
        
        hsFrame.addChild(highScoreLabel)
    }
    

    
    func createBlock() {
        
        let randomColor = Int(randomNumber(5))
        
        block = SKSpriteNode(imageNamed: "\(names[randomColor])" + "_bar")
        block.position = CGPoint(x: size.width / 2, y: size.height )
        block.name = "\(names[randomColor])"
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
        block.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
        
        block.runAction(SKAction.moveTo(CGPoint(x: block.position.x, y: 0 - block.size.height), duration: 3))
        blockLayer.addChild(block)
    }
    
    func createTwoBlocks() {
        
        if !isPhaseOne {
            
            
            let randomColor = Int(randomNumber(5))
            let randomColorRight = Int(randomNumber(5))
            
            blockLeft = SKSpriteNode(imageNamed: "\(names[randomColor])" + "_bar")
            blockLeft.size = CGSize(width: block.size.width / 1.5, height: block.size.height)
            blockLeft.position = CGPoint(x: 31 + blockLeft.size.width / 2, y: size.height )
            print("block:  \(blockLeft.size.width)")
            blockLeft.name = "\(names[randomColor])"
            
            blockLeft.physicsBody = SKPhysicsBody(rectangleOfSize: blockLeft.size)
            blockLeft.physicsBody?.affectedByGravity = false
            blockLeft.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
            blockLeft.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
            
            blockLeft.runAction(SKAction.moveTo(CGPoint(x: blockLeft.position.x, y: 0 - blockLeft.size.height), duration: 3))
            
            blockLayer.addChild(blockLeft)
            
            // Right
            blockRight = SKSpriteNode(imageNamed: "\(names[randomColorRight])" + "_bar")
            blockRight.size = CGSize(width: block.size.width / 1.5, height: blockRight.size.height)
            blockRight.position = CGPoint(x: size.width / 2 + 31 + blockRight.size.width / 2, y: size.height )
           
            blockRight.name = "\(names[randomColorRight])"

            blockRight.physicsBody = SKPhysicsBody(rectangleOfSize: blockRight.size)
            blockRight.physicsBody?.affectedByGravity = false
            blockRight.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
            blockRight.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
            
            blockRight.runAction(SKAction.moveTo(CGPoint(x: blockRight.position.x, y: 0 - blockRight.size.height), duration: 5.5))
            
            blockLayer.addChild(blockRight)
            
        }
        
    }
    /*
    func createHero() {
        
        hero = SKShapeNode(circleOfRadius: 10)
        hero.fillColor = colors[0]
        hero.position = CGPoint(x: size.width / 2, y: 200)
        hero.antialiased = true
     
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.frame.size.width / 2)
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.dynamic = false
        hero.physicsBody?.categoryBitMask = PhysicsCategory.HeroCategory
        hero.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        

        
        addChild(hero)
        
        hero.runAction(SKAction.scaleTo(3, duration: 0.5))
    }
    */
    
    
    func createHero() {
        
        hero = SKSpriteNode(imageNamed: "blue_ball")
        hero.position = CGPoint(x: size.width / 2, y: 200)
        hero.size = CGSizeMake(hero.size.width / 2, hero.size.height / 2)
        hero.name =  "blue"
        
        
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.width / 2)
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.dynamic = false
        hero.physicsBody?.categoryBitMask = PhysicsCategory.HeroCategory
        hero.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory

        addChild(hero)
        
        hero.runAction(SKAction.scaleTo(2, duration: 0.5))
        
        // Rotation
        /*
        let rotation = SKAction.sequence([SKAction.rotateByAngle(CGFloat(M_PI / 1.5), duration: 0.4), SKAction.rotateByAngle(CGFloat(-M_PI / 1.5), duration: 0.4)])
        hero.runAction(SKAction.repeatActionForever(rotation))
        */
        
        

    }
    
    /*
    func createHeroRight() {
        
        heroRight = SKShapeNode(circleOfRadius: 10)
        heroRight.fillColor = colors[0]
        heroRight.position = CGPoint(x: (size.width - qWidth), y: 200)
        heroRight.antialiased = true
        
        heroRight.physicsBody = SKPhysicsBody(circleOfRadius: heroRight.frame.size.width / 2)
        heroRight.physicsBody?.affectedByGravity = false
        heroRight.physicsBody?.dynamic = false
        heroRight.physicsBody?.categoryBitMask = PhysicsCategory.HeroCategory
        heroRight.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        
        addChild(heroRight)
        
        heroRight.runAction(SKAction.scaleTo(3, duration: 0.5))

    }
    */
    
    func createHeroRight() {
        
        heroRight = SKSpriteNode(imageNamed: "blue_ball")
        heroRight.position = CGPoint(x: (size.width - qWidth), y: 200)
        heroRight.size = CGSizeMake(hero.size.width / 2, hero.size.height / 2)
        heroRight.name = "blue"
        
        //heroRight.zRotation = CGFloat(M_PI / 1.5)
        
        heroRight.physicsBody = SKPhysicsBody(circleOfRadius: heroRight.size.width / 2)
        heroRight.physicsBody?.affectedByGravity = false
        heroRight.physicsBody?.dynamic = false
        heroRight.physicsBody?.categoryBitMask = PhysicsCategory.HeroCategory
        heroRight.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        
        
        addChild(heroRight)
        
        
        heroRight.runAction(SKAction.scaleTo(2, duration: 0.5))
        
        // Rotation
        /*
        let rotation = SKAction.sequence([SKAction.rotateByAngle(CGFloat(-M_PI / 1.5), duration: 0.4), SKAction.rotateByAngle(CGFloat(M_PI / 1.5), duration: 0.4)])
        heroRight.runAction(SKAction.repeatActionForever(rotation))*/
    }
    
//MARK:- Gameplay Actions
    /*
    func changeHeroColor(heroNum: Int, hero: SKSpriteNode) {
        
        if heroNum == 1 {
            
            if colorNumber >= colors.count {
                
                colorNumber = 0
            }
            
            hero.color = colors[colorNumber]
            colorNumber++
            
        } else {
            
            if colorNumberRight >= colors.count {
                
                colorNumberRight = 0
            }
            
            hero.color = colors[colorNumberRight]
            colorNumberRight++
        }
        


    }*/
    
    func changeHeroColor(heroNum: Int, hero: SKSpriteNode) {
        
        if heroNum == 1 {
            
            if colorNumber >= colors.count {
                
                colorNumber = 0
            }
            
            
            hero.texture = SKTexture(imageNamed: "\(names[colorNumber])" + "_ball")
            hero.name = names[colorNumber]
            colorNumber++
            
        } else {
            
            if colorNumberRight >= colors.count {
                
                colorNumberRight = 0
            }
            
            hero.texture = SKTexture(imageNamed: "\(names[colorNumberRight])" + "_ball")
            hero.name = names[colorNumberRight]
            colorNumberRight++
        }

    }
    
    func setHighScore() {
        
        highScore = score
        NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey: "highScore")
    }
    
//MARK:- Touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            if isStarted {
                
                if !isPhaseOne {
                    
                    if location.x < size.width / 2 {
                        
                        changeHeroColor(1, hero: hero)

                    } else {
                        
                        changeHeroColor(2, hero: heroRight)
                    }
                    
                } else  {
                    
                    changeHeroColor(1, hero: hero)
                }

            } else {
                
                newGame()
            }
            
        }
    }
   
//MARK:- Contact
    func didBeginContact(contact: SKPhysicsContact) {
        
        // Setup
        let firstBody: SKPhysicsBody!
        let secondBody: SKPhysicsBody!
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Collisions
        
        if firstBody.categoryBitMask == PhysicsCategory.HeroCategory && secondBody.categoryBitMask == PhysicsCategory.BlockCategory {
            
            let hitBlock = secondBody.node as! SKSpriteNode
            
            if hero.name == hitBlock.name || heroRight.name == hitBlock.name{
                
                hitBlock.removeFromParent()
                score++
                
                scoreLabel.text = "\(score)"
                
            } else {
                
                gameOver()
            }
        }
        
    }
   
//MARK:- Update    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if score > 0 {
            
            if isPhaseOne {
                
                spawnTimer.invalidate()
                isPhaseOne = false
                
                hero.runAction(SKAction.moveToX(qWidth, duration: 0.7))
                createHeroRight()
            }

        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
