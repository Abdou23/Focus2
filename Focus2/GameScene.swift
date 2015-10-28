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
    static let HeroRightCategory: UInt32 =     0x1 << 1
    static let BlockCategory: UInt32 =         0x1 << 2
}



 class GameScene: SKScene, SKPhysicsContactDelegate{
    
    // iAds
    //var iAd = ADInterstitialAd()
    var adView = UIView()
    
    //MARK:- Variables
    let backLax = SKNode()  // Background Parallax
    let foreLax = SKNode()         // Foreground Parallax
    // Layers
    let blockLayer = SKNode()
    let bgLayer = SKNode()
    let pauseLayer = SKNode()
    
    // Nodes
    var parallaxAssets = SKSpriteNode()
    var bg = SKSpriteNode()
    var light = SKSpriteNode()
    var block = SKSpriteNode()
    var blockLeft = SKSpriteNode()
    var blockRight = SKSpriteNode()
    var hero = SKSpriteNode()
    var heroRight = SKSpriteNode()
    var blockParticle = SKEmitterNode()
    var pauseScreen = SKSpriteNode()
    
    // Labels
    var scoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var highScoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var startLabel = SKLabelNode(fontNamed: "STHeitiTC-Medium")
    var instructionsLabel = UILabel()
    var hsFrame = SKSpriteNode() // highscore label frame
    
    // Values
    var previous = UInt32()
    var previous2 = UInt32()
    var colorNumber = 1
    var colorNumberRight = 1
    var score = 0
    var highScore = 0
    var qWidth: CGFloat!
    var maxX: CGFloat!
    var maxY: CGFloat!
    
    // Colors
    let yellowColor = UIColor(red: 255 / 255, green: 218 / 255, blue: 69 / 255, alpha: 1)
    let cyanColor = UIColor(red: 76 / 255, green: 191 / 255, blue: 195 / 255, alpha: 1)
    let redColor = UIColor(red: 255 / 255, green: 98 / 255, blue: 82 / 255, alpha: 1)
    let blueColor = UIColor(red: 82 / 255, green: 127 / 255, blue: 255 / 255, alpha: 1)
    let pinkColor = UIColor(red: 250 / 255, green: 82 / 255, blue: 173 / 255, alpha: 1)
    
    // Timers

    var lastUpdate: NSTimeInterval = 0
    var deltaTime: CGFloat = 0.16
    
    // Actions
    
    var spawnBlockAction = SKAction()
    
    // Bools
    var isStarted = false
    var isFirstTime = true
    var isPhaseOne = true
    var isAd = false
    var isPause = false
    
    // Arrays
    var colors = [UIColor]()
    var names = [String]()
    var parallax = [[SKSpriteNode](), [SKSpriteNode]()]
    var parallaxSpeed: [CGFloat] = [60, 40]
    var parallaxAtlas = [SKTexture]()
    var foreSprites = [SKSpriteNode]() // used in randomizing parallax
    
    // Buttons
    
    var pauseButton: Button!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        //iAd.delegate = self
        
        
        anchorPoint = CGPointZero
        
        
        addChild(backLax)
        addChild(foreLax)
        addChild(blockLayer)
        addChild(bgLayer)
        addChild(pauseLayer)
        
        bgLayer.zPosition = -10
        backLax.zPosition = -5
        foreLax.zPosition = -4
        pauseLayer.zPosition = 10
        
        qWidth = size.width / 4
        maxX = frame.width
        maxY = frame.height
        
        if let storedHighScore: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("highScore") {
            
            highScore = storedHighScore as! Int
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("pauseGame"), name: "ShowPauseScreenNotification", object: nil)
    
        
        colors = [yellowColor, blueColor, pinkColor, redColor, blueColor]
        names = ["yellow","violet", "pink", "red", "blue"]
        
        createBackground("Night_Stars")
        createLabels()
        createPauseButton()
        
        
    }
    
    
    
//MARK:- iAds
    
    /*
     func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        
        adView.removeFromSuperview()
        isAd = false
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        
        if iAd.loaded && !isStarted {
            
            isAd = true
            adView.frame = (self.view?.bounds)!
            self.view!.addSubview(adView)

            iAd.presentInView(adView)
            UIViewController.prepareInterstitialAds()
            print("Ad Loaded")
        }
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        
        adView.removeFromSuperview()
        isAd = false
        print("Ad ended")
        
    }
    
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        
        return true
    }
    
     func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
        adView.removeFromSuperview()
        isAd = false
        print("Ad Error  + \(error)")
    }
*/

//MARK:- Pause
    
        
    func pauseGame() {
        if (!isFirstTime) {
            pauseScreen.hidden = false
            pauseButton.hidden = false
            // Un-pause the view so the screen and button appear
            if let customView = self.view as? MainView {
                customView.resume()
            }
            // Re-pause the view after returning to the main loop
            let pauseAction = SKAction.runBlock({
                [weak self] in
                if let customView = self?.view as? MainView {
                    customView.pause()
                    self!.isPause = true
                }
            })
            runAction(pauseAction)
        }
        isFirstTime = false
        
    }
    

    func pauseButtonToggle() {
        
        print("Clicked")
        if let customView = self.view as? MainView {
            customView.togglePause()
        }
        if isPause {
            
            pauseScreen.hidden = true
            pauseButton.hidden = true
            isPause = false
            
        } else {
            
            pauseScreen.hidden = false
            pauseButton.hidden = false
            isPause = true
        }
        
    }
    
//MARK:- Setup
    
    func randomRange(min: CGFloat, max: CGFloat) -> CGFloat {
        
        let min = UInt32(min)
        let max = UInt32(max)
        
        let random = arc4random_uniform(max - min) + min
        
        return CGFloat(random)
    }
    
    func randomNumber(max: UInt32) -> UInt32 {
        
        var random = arc4random_uniform(max)
        
        while previous == random {
            
            random = arc4random_uniform(max)
        }
        
        previous = random // Previous should be on the left
        
        return random
    }
    
    func randomNumber2(max: UInt32) -> UInt32 {
        
        var random = arc4random_uniform(max)
        
        while previous2 == random {
            
            random = arc4random_uniform(max)
        }
        
        previous2 = random // Previous should be on the left
        
        return random
    }
    
    
    func newGame() {
     
        score = 0
        /*
        spawnTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "createBlock", userInfo: nil, repeats: true)
        spawnTwoBlocks = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "createTwoBlocks", userInfo: nil, repeats: true)
        */
        spawnBlock()
        spawnTwoBlocks()

        scoreLabel.text = "\(score)"
        createHero()
        isStarted = true
        randomBGAndParallax()
        startLabel.hidden = true
        instructionsLabel.hidden = true
        hsFrame.hidden = true
        
        
        if scoreLabel.hidden == true {
            
            scoreLabel.hidden = false
        }
        
        if isFirstTime {

            isFirstTime = false
            
        } else {
            
            scoreLabel.runAction(SKAction.sequence([SKAction.moveToY(size.height - 40, duration: 0.5), SKAction.scaleTo(1, duration: 1)]))

        }
        
    }

    
    func gameOver() {
        
        if score > highScore {
         
            setHighScore()
            highScoreLabel.text = "Highscore: \(highScore)"
            
        }
        isStarted = false
        //interstitialAdDidLoad(iAd)
        
        blockLayer.removeAllChildren()
        backLax.removeAllChildren()
        foreLax.removeAllChildren()
        bgLayer.removeAllChildren()
        bgLayer.removeAllChildren()
        hero.removeFromParent()
        heroRight.removeFromParent()
        light.removeFromParent()
        foreSprites.removeAll()
        parallax[0].removeAll()
        parallax[1].removeAll()
        removeAllActions()
        
        score = 0
        
        isPhaseOne = true
        colorNumber = 0
        colorNumberRight = 0
        
        createBackground("Night_Stars")

        startLabel.hidden = false
        instructionsLabel.hidden = false
        hsFrame.hidden = false
        scoreLabel.runAction(SKAction.sequence([SKAction.moveToY(size.height / 2 + 100, duration: 0.5), SKAction.scaleTo(1.3, duration: 1)]))
        
    }
    
    
//MARK:- Creations
    
    func createParallaxAtlas() {
        
        
    }
    
    func randomBGAndParallax() {
    
        let random = arc4random_uniform(2)
        
        if random == 0 {
            
            createParallax(8, backMax: 15, foreS: "cloud_big", backS: "cloud_small")
            createBackground("Day_BG")
            createLight("Sun")
            
        } else {
            
            createParallax(32, backMax: 28, foreS: "star_mid", backS: "star_small")
            createBackground("Night_BG")
            createLight("Moon")
        }
    }
    
    func createParallax(foreMax: Int, backMax: Int, foreS: String, backS: String) {
    
        for index in 0...foreMax {
            
            let sprite = SKSpriteNode(imageNamed: foreS)
            parallax[0].append(sprite)
            foreLax.addChild(sprite)
        }
        
        for currentSprite in parallax[0]{
            
            var intersects = true

            while (intersects){
                
                let xPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxX
                let yPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxY
               
                currentSprite.position = CGPoint(x: xPos, y: yPos )
                
                intersects = false
                
                for sprite in foreSprites{
                    if currentSprite.intersectsNode(sprite){
                        
                        intersects = true
                        break
                    }
                }
            }
            
            foreSprites.append(currentSprite)
        }

        for index in 0...backMax {  //22
            
            let sprite = SKSpriteNode(imageNamed: backS)
            let xPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxX
            let yPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxY
            sprite.position = CGPoint(x: xPos, y: yPos)
            sprite.size = CGSize(width: sprite.size.width / 2, height: sprite.size.height / 2)
            sprite.alpha = 0.5
            
            parallax[1].append(sprite)
            backLax.addChild(sprite)
        }
    }
    
    func createBackground(name: String) {
        
        if bgLayer.children.count != 0 {
            
            bgLayer.removeAllChildren()
        }
            
        bg = SKSpriteNode(imageNamed: name)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgLayer.addChild(bg)
        
    }
    
    func createLight(name: String) {
        
        light = SKSpriteNode(imageNamed: name)
        light.position = CGPoint(x: light.size.width, y: size.height - light.size.height)
        light.zPosition = -1
        addChild(light)

    }
    
    func createPauseScreen() {
        
        pauseScreen = SKSpriteNode(color: UIColor.blackColor(), size: size)
        pauseScreen.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseScreen.alpha = 0.5
        pauseScreen.zPosition = 10
        pauseScreen.hidden = true
        pauseLayer.addChild(pauseScreen)
    }
    
    
    func createLabels() {
        
        // ScoreLabel
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.alpha = 0.55
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
        
        highScoreLabel.text = "Highscore: \(highScore)"
        highScoreLabel.position.y = highScoreLabel.position.y - 10
        highScoreLabel.fontSize = 30
        highScoreLabel.fontColor = UIColor.whiteColor()
        
        hsFrame.addChild(highScoreLabel)
        
        createPauseScreen()
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
        
        block.color = colors[randomColor]
        block.runAction(SKAction.moveTo(CGPoint(x: block.position.x, y: 0 - block.size.height), duration: 2.7))
        blockLayer.addChild(block)
    }
    
    func createTwoBlocks() {
        
        if !isPhaseOne {
            
            
            let randomColor = Int(randomNumber2(5))
            let randomColorRight = Int(randomNumber(5))
            
            blockLeft = SKSpriteNode(imageNamed: "\(names[randomColor])" + "_bar")
            blockLeft.size = CGSize(width: block.size.width / 1.5, height: block.size.height)
            blockLeft.position = CGPoint(x: 31 + blockLeft.size.width / 2, y: size.height )
            blockLeft.name = "\(names[randomColor])"
            
            blockLeft.physicsBody = SKPhysicsBody(rectangleOfSize: blockLeft.size)
            blockLeft.physicsBody?.affectedByGravity = false
            blockLeft.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
            blockLeft.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
            
            blockLeft.color = colors[randomColor]
            
            blockLeft.runAction(SKAction.moveTo(CGPoint(x: blockLeft.position.x, y: 0 - blockLeft.size.height), duration: 2.7))
            
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
            
            blockRight.color = colors[randomColorRight]
            
            blockRight.runAction(SKAction.moveTo(CGPoint(x: blockRight.position.x, y: 0 - blockRight.size.height), duration: 4.5))
            
            blockLayer.addChild(blockRight)
            
        }
        
    }

    
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
    }

    
    func createHeroRight() {
        
        heroRight = SKSpriteNode(imageNamed: "blue_ball")
        heroRight.position = CGPoint(x: (size.width - qWidth), y: 200)
        heroRight.size = CGSizeMake(hero.size.width / 2, hero.size.height / 2)
        heroRight.name = "blue"
        
        //heroRight.zRotation = CGFloat(M_PI / 1.5)
        
        heroRight.physicsBody = SKPhysicsBody(circleOfRadius: heroRight.size.width / 2)
        heroRight.physicsBody?.affectedByGravity = false
        heroRight.physicsBody?.dynamic = false
        heroRight.physicsBody?.categoryBitMask = PhysicsCategory.HeroRightCategory
        heroRight.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        
        
        addChild(heroRight)
        
        
        heroRight.runAction(SKAction.scaleTo(2, duration: 0.5))
    }
    
    
//MARK:- Effects
    
    func ballPressed(ball: SKSpriteNode) {
        
        let scaleDown = SKAction.scaleTo(1.9, duration: 0.05)
        let scaleUp = SKAction.scaleTo(2, duration: 0.05)
        
        ball.runAction(SKAction.sequence([scaleDown, scaleUp]))
    }
    
    func blockDestroyed(block: SKSpriteNode) {
        
        let particlePath = NSBundle.mainBundle().pathForResource("Destroyed", ofType: "sks")
        blockParticle = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePath!) as! SKEmitterNode
        blockParticle.zPosition = 10
        blockParticle.position = CGPoint(x: block.position.x, y: block.position.y + 4)
        blockParticle.particleColor = block.color
        
        blockLayer.addChild(blockParticle)
        
        
        let particlePathLeft = NSBundle.mainBundle().pathForResource("DestroyedLeft", ofType: "sks")
        let blockParticleLeft = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePathLeft!) as! SKEmitterNode
        blockParticleLeft.zPosition = 10
        blockParticleLeft.position = CGPoint(x: block.position.x, y: block.position.y + 4)
        blockParticleLeft.particleColor = block.color
        blockParticleLeft.particleColorBlendFactor = 1
        
        blockLayer.addChild(blockParticleLeft)
        
        
    }
    

    
    func spawnBlock() {
        
        let wait = SKAction.waitForDuration(2)
        
        let spawn = SKAction.runBlock({
            self.createBlock()
        })
        
        
        spawnBlockAction = SKAction.sequence([wait, spawn])
        runAction(SKAction.repeatActionForever(spawnBlockAction), withKey: "oneBlock")
        
    }
    
    func spawnTwoBlocks() {
        
        let wait = SKAction.waitForDuration(3)
        
        let spawn = SKAction.runBlock({
            self.createTwoBlocks()
        })
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([wait, spawn])))
    }
    
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
    
    func moveParallaxLayer(parallax: [SKSpriteNode], speed: CGFloat) {
        
        var sprite = SKSpriteNode()
        var newY: CGFloat = 0
        
        for index in 0...parallax.count-1 {
            
            sprite = parallax[index]
            newY = sprite.position.y - 1 * speed * deltaTime
            
            sprite.position.y = boundCheck(newY)
        }
        
    }
    
    func boundCheck(var yPos: CGFloat) -> CGFloat {
        
        if yPos < 0 {
            
            yPos += maxY + 100
        }
        
        return yPos
    }
    
    func checkInterception(sprite1: SKSpriteNode, sprite2: [SKSpriteNode]) {
        
        let xPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxX
        let yPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxY
        sprite1.position = CGPoint(x: xPos, y: yPos )
        
        for index in 0...sprite2.count-1 {
            
            if sprite1.intersectsNode(sprite2[index]) {
                
                
                let yPos = sprite1.position.y + sprite1.size.height
                sprite1.position = CGPoint(x: xPos, y: yPos )
                
            }

        }
        
    }
    
    func setHighScore() {
        
        highScore = score
        NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey: "highScore")
    }
    
//MARK:- Buttons
    
    func createPauseButton() {
        
        pauseButton = Button(defaultImage: "cyan_ball", activeImage: "red_ball", buttonAction: pauseButtonToggle)
        pauseButton.position = CGPoint(x: size.width / 2, y: self.size.height - 200)
        pauseButton.hidden = true
        pauseLayer.addChild(pauseButton)
    }
    
//MARK:- Touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            if isPause {
                
                if pauseButton.containsPoint(location) {
                    print("Clicked2")
                    pauseButtonToggle()
                }
            } else {
            
            if isStarted {
                
                if !isPhaseOne {
                    
                    if location.x < size.width / 2 {
                        
                        changeHeroColor(1, hero: hero)
                        ballPressed(hero)

                    } else {
                        
                        changeHeroColor(2, hero: heroRight)
                        ballPressed(heroRight)
                    }
                    
                } else  {
                    
                    changeHeroColor(1, hero: hero)
                    ballPressed(hero)
                }

            } else {
                
                if !isAd {
                    
                    newGame()
                }
            }
            
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
            
            if hero.name == hitBlock.name {
                
                blockDestroyed(hitBlock)
                hitBlock.removeFromParent()
                
                score++
                
                scoreLabel.text = "\(score)"
                
            }  else {
                
                gameOver()
            }
        }
        
        
        if firstBody.categoryBitMask == PhysicsCategory.HeroRightCategory && secondBody.categoryBitMask == PhysicsCategory.BlockCategory {
         
            let hitBlock = secondBody.node as! SKSpriteNode
            
            if heroRight.name == hitBlock.name {
                
                blockDestroyed(hitBlock)
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
        
        
        if score > 3 {
            
            if isPhaseOne {
                
                removeActionForKey("oneBlock")
                isPhaseOne = false
                
                hero.runAction(SKAction.moveToX(qWidth, duration: 0.7))
                createHeroRight()
            }
        }
        
        deltaTime = CGFloat(currentTime - lastUpdate)
        lastUpdate = currentTime
       
        if deltaTime > 1 {
            
            deltaTime = 0.16
        }
        
        
        if isStarted {
            
            for index in 0...1 {
                
                moveParallaxLayer(parallax[index], speed: parallaxSpeed[index])
            }
        }
    
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
