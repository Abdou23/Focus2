//
//  Button.swift
//  Focus2
//
//  Created by AbdelGhafour on 10/5/15.
//  Copyright © 2015 Abdou23. All rights reserved.
//

import SpriteKit

class Button: SKNode {
    
    
    var defaultButton: SKSpriteNode
    var activeButton: SKSpriteNode
    var action: () -> Void
    
    init(defaultImage: String, activeImage: String, buttonAction: () -> Void) {
        
        defaultButton = SKSpriteNode(imageNamed: defaultImage)
        activeButton = SKSpriteNode(imageNamed: activeImage)
        action = buttonAction
        
        activeButton.hidden = true
        
        super.init()
        
        userInteractionEnabled = true
        
        addChild(defaultButton)
        addChild(activeButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            activeButton.hidden = false
            defaultButton.hidden = true
            
            
        }
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if defaultButton.containsPoint(location) {
                action()
            }
            
            activeButton.hidden = true
            defaultButton.hidden = false
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
