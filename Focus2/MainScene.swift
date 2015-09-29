//
//  MainScene.swift
//  Focus2
//
//  Created by AbdelGhafour on 9/29/15.
//  Copyright © 2015 Abdou23. All rights reserved.
//

import SpriteKit

class MainScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        
        let BG = SKSpriteNode(imageNamed: "Day-BG")
        BG.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(BG)
        
    }
    
    
    
    
    
    
    
    
}