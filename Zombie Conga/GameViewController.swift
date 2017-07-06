//
//  GameViewController.swift
//  Zombie Conga
//
//  Created by Jonathan Bijos on 06/07/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {
            let scene = GameScene(size: CGSize(width: 2048, height: 1536))
            scene.scaleMode = .aspectFill
            
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.presentScene(scene)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
