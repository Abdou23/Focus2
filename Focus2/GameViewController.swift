//
//  GameViewController.swift
//  Focus2
//
//  Created by AbdelGhafour on 8/17/15.
//  Copyright (c) 2015 Abdou23. All rights reserved.
//

import UIKit
import SpriteKit



class GameViewController: UIViewController  {
    

  
    override func viewDidLoad() {
        super.viewDidLoad()

         let scene  = GameScene()
        // Configure the view.
        let skView =  self.view as! MainView
        skView.showsFPS = true
        skView.showsNodeCount = false
        skView.showsPhysics = false
        
        NSNotificationCenter.defaultCenter().addObserver(skView, selector:Selector("pause"), name: "PauseViewNotification", object: nil)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        scene.size = skView.bounds.size
            
        skView.presentScene(scene)

        
    }
    

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        print("Memory issues")
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
