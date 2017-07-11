//
//  ViewController.swift
//  ZombieCongaMac
//
//  Created by Jonathan Bijos on 11/07/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        scene.scaleMode = .aspectFill
        
        if let skView = skView {
            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        
    }
}

