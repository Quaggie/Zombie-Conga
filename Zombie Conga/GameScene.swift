//
//  GameScene.swift
//  Zombie Conga
//
//  Created by Jonathan Bijos on 06/07/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let backgroundLayer = SKNode()
    
    let backgroundMovePointsPerSec: CGFloat = 200.0
    let zombie = ZombieSprite(imageNamed: "zombie1")
    var zombieIsInvincible = false
    let zombieAnimation: SKAction
    let playableRect: CGRect
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var lastTouchLocation: CGPoint?
    
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity: CGPoint = .zero
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    
    let catMovePointsPerSec: CGFloat = 480.0
    var lives = 2
    var gameOver = false
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCatLady.wav", waitForCompletion: false)
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.repeatForever(
            SKAction.animate(with: textures, timePerFrame: 0.1))
        
        super.init(size: size)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    override func didMove(to view: SKView) {
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        backgroundLayer.zPosition = -1
        addChild(backgroundLayer)
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = .zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.name = "background"
            backgroundLayer.addChild(background)
        }
        
        zombie.zPosition = 100
        zombie.position = CGPoint(x: 400, y: 400)
        backgroundLayer.addChild(zombie)
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(spawnEnemy),
                               SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(spawnCat),
                               SKAction.wait(forDuration: 1.0)])))
//        debugDrawPlayableArea()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: backgroundLayer)
            lastTouchLocation = touchLocation
            sceneTouched(touchLocation: touchLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: backgroundLayer)
            lastTouchLocation = touchLocation
            sceneTouched(touchLocation: touchLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: backgroundLayer)
            lastTouchLocation = touchLocation
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if let lastTouchLocation = lastTouchLocation {
//            let offset = lastTouchLocation - zombie.position
//            let distance = offset.length()
//            if distance <= (CGFloat(dt) * zombieMovePointsPerSec) {
//                zombie.position = lastTouchLocation
//                velocity = .zero
//                stopZombieAnimation()
//            } else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
//            }
        } else {
            moveSprite(zombie, velocity: velocity)
            rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
        boundsCheckZombie()
        moveTrain()
        moveBackground()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func moveSprite(_ sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position
        let length = offset.length()
        let direction = offset / length
        velocity = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation: CGPoint) {
        moveZombieToward(location: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = backgroundLayer.convert(CGPoint(x: 0, y: playableRect.minY), from: self)
        let topRight = backgroundLayer.convert(CGPoint(x: size.width, y: playableRect.maxY), from: self)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
            
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotateSprite(_ sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy() {
        let enemy = CrazyCatLadySprite(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.zPosition = 1
        let enemyScenePos = CGPoint(
            x: size.width + enemy.size.width / 2,
            y: CGFloat.random(
                min: playableRect.minY + enemy.size.height/2,
                max: playableRect.maxY - enemy.size.height/2
            )
        )
        enemy.position = backgroundLayer.convert(enemyScenePos, from: self)
        backgroundLayer.addChild(enemy)
        
        let actionMove = SKAction.moveBy(x: -size.width - enemy.size.width, y: 0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnCat() {
        let cat = CatSprite(imageNamed: "cat")
        cat.name = "cat"
        cat.zPosition = 1
        
        let catScenePos = CGPoint(
            x: CGFloat.random(min: playableRect.minX, max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY, max: playableRect.maxY)
        )
        cat.position = backgroundLayer.convert(catScenePos, from: self)
        cat.setScale(0)
        backgroundLayer.addChild(cat)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        
        let leftWiggle = SKAction.rotate(byAngle: π / 8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func zombieHitCat(cat: CatSprite) {
        if cat.wasTurned {
            return
        }
        cat.wasTurned = true
        cat.name = "train"
        
        run(catCollisionSound)
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        
        let turnGreenAction = SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.2)
        cat.run(turnGreenAction)
    }
    
    func zombieHitEnemy(enemy: CrazyCatLadySprite) {
        enemy.removeFromParent()
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
        
        zombieIsInvincible = true
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let hideAction = SKAction.run {
            self.zombie.isHidden = false
            self.zombieIsInvincible = false
        }
        zombie.run(SKAction.sequence([blinkAction, hideAction]))
    }
    
    func checkCollisions() {
        if zombieIsInvincible {
            return
        }
        
        var hitCats: [CatSprite] = []
        backgroundLayer.enumerateChildNodes(withName: "cat") { (node, _) in
            if let cat = node as? CatSprite {
                if cat.frame.intersects(self.zombie.frame) {
                    hitCats.append(cat)
                }
            }
        }
        for cat in hitCats {
            zombieHitCat(cat: cat)
        }
        
        var hitEnemies: [CrazyCatLadySprite] = []
        backgroundLayer.enumerateChildNodes(withName: "enemy") { (node, _) in
            if let enemy = node as? CrazyCatLadySprite {
                let enemyFrame = CGRect(origin: node.frame.origin, size: CGSize(width: 20, height: 20))
                if enemyFrame.intersects(self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy: enemy)
        }
    }
    
    func moveTrain() {
        var trainCount = 0
        var targetPosition = zombie.position
        
        backgroundLayer.enumerateChildNodes(withName: "train") { (node, _) in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 30 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func loseCats() {
        var loseCount = 0
        backgroundLayer.enumerateChildNodes(withName: "train") { (node, stop) in
            var randomSpot = node.position
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: π*4, duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                    ]),
                    SKAction.removeFromParent()
                ]))
            loseCount += 1
            if loseCount >= 2 {
                stop.pointee = true
            }
        }
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = .zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = .zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = .zero
        background2.position = CGPoint(x: background1.frame.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        
        return backgroundNode
    }
    
    func moveBackground() {
        let backgroundVelocity = CGPoint(x: -self.backgroundMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        backgroundLayer.position += amountToMove
        
        backgroundLayer.enumerateChildNodes(withName: "background") { (node, _) in
            if let background = node as? SKSpriteNode {
                let backgroundScreenPos = self.backgroundLayer.convert(background.position, to: self)
                if backgroundScreenPos.x <= -background.size.width {
                    background.position = CGPoint(
                        x: background.position.x + background.size.width * 2,
                        y: background.position.y)
                }
            }
        }
    }
}













