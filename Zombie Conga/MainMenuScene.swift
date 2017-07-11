//
//  MainMenuScene.swift
//  Zombie Conga
//
//  Created by Jonathan Bijos on 11/07/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    let background = SKSpriteNode(imageNamed: "MainMenu")
    
    override func didMove(to view: SKView) {
        background.zPosition = -1
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneTapped()
    }
    
    func sceneTapped() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        let transition = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(gameScene, transition: transition)
    }
}
