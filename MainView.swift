//
//  MainView.swift
//  Focus2
//
//  Created by AbdelGhafour on 10/19/15.
//  Copyright © 2015 Abdou23. All rights reserved.
//

import SpriteKit


class MainView: SKView {
    
    override var paused: Bool {
        get {
            return super.paused
        }
        set {
            
        }
    }
    
    func pause() {
        super.paused = true
    }
    
    func resume() {
        super.paused = false
    }
    
    func togglePause() {
        super.paused = !super.paused
    }
    
}