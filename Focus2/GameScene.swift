//
//  GameScene.swift
//  Focus2
//
//  Created by AbdelGhafour on 8/17/15.
//  Copyright (c) 2015 Abdou23. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    
    static let HeroCategory: UInt32 =          0x1 << 0
    static let BlockCategory: UInt32 =         0x1 << 1
}

// Nodes
var block = SKSpriteNode()
var blockLeft = SKSpriteNode()
var blockRight = SKSpriteNode()
var hero = SKShapeNode()
var heroRight = SKShapeNode()

// Labels
var scoreLabel = SKLabelNode(fontNamed: "STHeitiTC-Medium")
var highScoreLabel = SKLabelNode(fontNamed: "STHeitiTC-Medium")
var startLabel = SKLabelNode(fontNamed: "STHeitiTC-Medium")
var instructionsLabel = UILabel()

// Values
var previous = UInt32()
var colorNumber = 1
var colorNumberRight = 1
var score = 0
var highScore = 0

// Timers
var spawnTimer = NSTimer()
var spawnTwoBlocks = NSTimer()

// Bools
var isStarted = false
var isFirstTime = true
var isPhaseOne = true

// Arrays
var colors = [UIColor]()

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPointZero

        backgroundColor = UIColor(red: 0.94, green: 0.97, blue: 1, alpha: 1)
        
        if var storedHighScore: AnyObject  = NSUserDefaults.standardUserDefaults().objectForKey("highScore") {
            
            highScore = storedHighScore as! Int
        }
        
        colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.purpleColor()]
        
        createLabels()


    }
    
    
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
        
        runAction(SKAction.waitForDuration(5))
        spawnTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "createBlock", userInfo: nil, repeats: true)
        spawnTwoBlocks = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "createTwoBlocks", userInfo: nil, repeats: true)

        scoreLabel.text = "0"
        createHero()
        isStarted = true
        startLabel.hidden = true
        instructionsLabel.hidden = true
        highScoreLabel.hidden = true

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
        score = 0
        isStarted = false
        isPhaseOne = true
        enumerateChildNodesWithName("block") {
         node, stop in
            
            node.removeFromParent()
        }
        hero.removeFromParent()
        heroRight.removeFromParent()
        removeAllActions()
        spawnTimer.invalidate()
        spawnTwoBlocks.invalidate()
        startLabel.hidden = false
        instructionsLabel.hidden = false
        highScoreLabel.hidden = false
        scoreLabel.runAction(SKAction.sequence([SKAction.moveByX(0, y:  -200, duration: 0.5), SKAction.scaleTo(1.5, duration: 1)]))

        
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
        startLabel.fontColor = UIColor.blackColor()
        
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
        instructionsLabel.textColor = UIColor.brownColor()
        
        view?.addSubview(instructionsLabel) // <- View not self
        
        highScoreLabel = SKLabelNode(text: "Highscore: \(highScore)")
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 70)
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = UIColor.blueColor()
        
        addChild(highScoreLabel)
    }
    

    
    func createBlock() {
        
        var randomColor = Int(randomNumber(5))
        
        block = SKSpriteNode(color: colors[randomColor], size: CGSizeMake(250, 20))
        block.position = CGPoint(x: size.width / 2, y: size.height )
        block.name = "block"
        
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
        block.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
        
        block.runAction(SKAction.moveTo(CGPoint(x: block.position.x, y: 0 - block.size.height), duration: 3))
        
        addChild(block)
    }
    
    func createTwoBlocks() {
        
        if !isPhaseOne {
            
            
            var randomColor = Int(randomNumber(5))
            var randomColorRight = Int(randomNumber(5))
            
            blockLeft = SKSpriteNode(color: colors[randomColor], size: CGSizeMake(180, 20))
            blockLeft.position = CGPoint(x: 2 + blockLeft.size.width / 2, y: size.height )
            blockLeft.name = "block"
            
            blockLeft.physicsBody = SKPhysicsBody(rectangleOfSize: blockLeft.size)
            blockLeft.physicsBody?.affectedByGravity = false
            blockLeft.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
            blockLeft.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
            
            blockLeft.runAction(SKAction.moveTo(CGPoint(x: blockLeft.position.x, y: 0 - blockLeft.size.height), duration: 3))
            
            addChild(blockLeft)
            
            blockRight = SKSpriteNode(color: colors[randomColorRight], size: CGSizeMake(180, 20))
            blockRight.position = CGPoint(x: 187.5 + blockRight.size.width / 2, y: size.height )
            blockRight.name = "block"

            blockRight.physicsBody = SKPhysicsBody(rectangleOfSize: blockRight.size)
            blockRight.physicsBody?.affectedByGravity = false
            blockRight.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
            blockRight.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
            
            blockRight.runAction(SKAction.moveTo(CGPoint(x: blockRight.position.x, y: 0 - blockRight.size.height), duration: 6))
            
            addChild(blockRight)
            
        }
        
    }
    
    func createHero() {
        
        hero = SKShapeNode(circleOfRadius: 10)
        hero.fillColor = colors[0]
        hero.position = CGPoint(x: size.width / 2, y: 200)
        hero.lineWidth = 1
        hero.antialiased = true
     
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.frame.size.width / 2)
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.dynamic = false
        hero.physicsBody?.categoryBitMask = PhysicsCategory.HeroCategory
        hero.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        
        
        addChild(hero)
        
        hero.runAction(SKAction.scaleTo(3, duration: 0.5))
    }
    
    func createHeroRight() {
        
        heroRight = SKShapeNode(circleOfRadius: 10)
        heroRight.fillColor = colors[0]
        heroRight.position = CGPoint(x: 285, y: 200)
        heroRight.lineWidth = 1
        heroRight.antialiased = true
        
        heroRight.physicsBody = SKPhysicsBody(circleOfRadius: heroRight.frame.size.width / 2)
        heroRight.physicsBody?.affectedByGravity = false
        heroRight.physicsBody?.dynamic = false
        heroRight.physicsBody?.categoryBitMask = PhysicsCategory.HeroCategory
        heroRight.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        
        
        addChild(heroRight)
        
        heroRight.runAction(SKAction.scaleTo(3, duration: 0.5))

    }
    
    
    func changeHeroColor(heroNum: Int, hero: SKShapeNode) {
        
        if heroNum == 1 {
            
            if colorNumber >= colors.count {
                
                colorNumber = 0
            }
            
            hero.fillColor = colors[colorNumber]
            colorNumber++
            
        } else {
            
            if colorNumberRight >= colors.count {
                
                colorNumberRight = 0
            }
            
            heroRight.fillColor = colors[colorNumberRight]
            colorNumberRight++
        }
        


    }
    
    func setHighScore() {
        
        highScore = score
        NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey: "highScore")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
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
            
            var hitBlock = secondBody.node as! SKSpriteNode
            
            if hero.fillColor == hitBlock.color || heroRight.fillColor == hitBlock.color{
                
                hitBlock.removeFromParent()
                score++
                scoreLabel.text = "\(score)"
                
            } else {
                
                gameOver()
            }
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if score > 2 {
            
            if isPhaseOne {
                
                isPhaseOne = false
                spawnTimer.invalidate()
                hero.runAction(SKAction.moveToX(95, duration: 1))
                createHeroRight()
            }

        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
