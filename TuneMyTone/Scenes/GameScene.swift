//
//  GameScene.swift
//  TuneMyTone
//
//  Created by Fernando N. Frassia on 11/27/18.
//  Copyright © 2018 Fernando N. Frassia. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameSceneDelegate {
    func estimatedFrequency() -> Double?
}

class GameScene: SKScene {
    
    private var tuneBall: SKSpriteNode?
    private var scoreNode: ScoreNode!
    var tunerDelegate: GameSceneDelegate?
    
    lazy var gameStarted: Bool = {
        return false
    }()
    
    var ballPositions = [CGPoint]()
    
    var score = 0
    
    // MARK: - DidMove
    override func didMove(to view: SKView) {
        layoutScene()
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        moveBackground()
        if gameStarted {
            moveTuneBall()
            drawTrail()
        }
    }
    
    // MARK: - DidSimulatePhysics
    override func didSimulatePhysics() {
        if let tuneBall = tuneBall {
            ballPositions.insert(tuneBall.position, at: 0)
            if ballPositions.count > 15 {ballPositions.removeLast()}
        }
    }
    
    // MARK: - Trail
    func createTrailPath() -> CGPath? {
        guard ballPositions.count >= 2 else {return nil}
        
        let trail = CGMutablePath()
        trail.move(to: ballPositions.first!)
        var deltaX = CGFloat(10)
        for position in ballPositions {
            trail.addLine(to: CGPoint(x: position.x-deltaX, y: position.y))
            deltaX += 10
        }
        
        return trail
    }
    
    func drawTrail() {
        removeTrail()
        
        if let trail = self.createTrailPath() {
            let shapeNode = SKShapeNode()
            shapeNode.path = trail
            shapeNode.name = "Trail"
            shapeNode.strokeColor = .red
            shapeNode.lineWidth = 1.5
            shapeNode.zPosition = 1
            
            self.addChild(shapeNode)
        }
    }
    
    func removeTrail() {
        enumerateChildNodes(withName: "Trail") { (node, stop) in
            node.removeFromParent()
        }
    }
    
    // MARK: - Start
    func startGame() {
        tuneBall?.isHidden = false
        gameStarted = true
        addTuneBlocks()
        removeScore()
    }
    
    func stopGame() {
        tuneBall?.isHidden = true
        gameStarted = false
        removeTrail()
        removeTuneBlocks()
        addScore()
    }
    
    //MARK: - Score
    func addScore() {
        scoreNode = ScoreNode()
        scoreNode.position = CGPoint(x: 0, y: frame.size.height/2)
        scoreNode.name = "Score"
        scoreNode.score = score
        
        addChild(scoreNode)
        scoreNode.run(SKAction.moveTo(y: 0, duration: 5))
    }
    
    func removeScore() {
        enumerateChildNodes(withName: "Score") { (node, error) in
            node.removeFromParent()
        }
    }
    
    // MARK: - DidMove Aux
    func layoutScene() {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        ballPositions = [CGPoint]()
        tuneBall = self.childNode(withName: "//TuneBall") as? SKSpriteNode
        tuneBall?.isHidden = true
        createBackground()
    }
    
    // MARK: - Update Aux
    func addTuneBlocks() {
        let blockTexture = SKTexture(imageNamed: "TuneBlock")
        for i in 0..<Scales.CMajor.count {
            let note = Scales.CMajor[i]
            guard let yPosition = note.position() else {return}
            
            let blockSprite = SKSpriteNode(texture: blockTexture)
            blockSprite.name = "TuneBlock"
            blockSprite.color = .white
            blockSprite.colorBlendFactor = 0.5
            blockSprite.anchorPoint = CGPoint(x: 0, y: 0.5)
            blockSprite.size = CGSize(width: 20, height: 20)
            blockSprite.zPosition = 10
            let x = frame.width/2 + CGFloat(i)*blockTexture.size().width
            let y = CGFloat(yPosition)
            blockSprite.position = CGPoint(x: x, y: y)
            
            let blockPhysicsBody = SKPhysicsBody(rectangleOf: blockTexture.size())
            blockPhysicsBody.contactTestBitMask = 0x00000001
            blockPhysicsBody.allowsRotation = false
            blockPhysicsBody.friction = 0
            blockPhysicsBody.linearDamping = 0
            blockPhysicsBody.angularDamping = 0
            blockPhysicsBody.usesPreciseCollisionDetection = true
            blockSprite.physicsBody = blockPhysicsBody
            
            addChild(blockSprite)
            
            let distanceToMoveX = frame.width + frame.width/2 + CGFloat(i+1)*blockTexture.size().width
            let moveLeft = SKAction.moveBy(x: -distanceToMoveX, y: 0, duration: Double(distanceToMoveX/100))
            blockSprite.run(moveLeft)
        }
    }
    
    func removeTuneBlocks() {
        enumerateChildNodes(withName: "TuneBlock") { (node, error) in
            node.removeFromParent()
        }
    }
    
    func moveTuneBall() {
        if let delegate = tunerDelegate {
            let estimatedFrequency = delegate.estimatedFrequency()
            let newY = estimatedFrequency != nil ? estimatedFrequency! - 100 : 0
            
            if let tuneBall = self.tuneBall {
                tuneBall.physicsBody?.usesPreciseCollisionDetection = true
                tuneBall.run(SKAction.moveTo(y: frame.midY + CGFloat(newY), duration: 0.4))
            }
        }
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == tuneBall || contact.bodyB.node == tuneBall {
            let blockSprite = contact.bodyA.node == tuneBall ? contact.bodyB.node : contact.bodyA.node
            if let block = blockSprite as? SKSpriteNode {
                block.color = .green
                score += 1
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == tuneBall || contact.bodyB.node == tuneBall {
            let blockSprite = contact.bodyA.node == self.tuneBall ? contact.bodyB.node : contact.bodyA.node
            if let block = blockSprite as? SKSpriteNode {
                block.color = .white
            }
        }
    }
}

extension GameScene {
    func createBackground() {
        createSky()
        createClouds()
        createMountains()
        createGround()
    }
    
    func createSky() {
        for i in 0...1 {
            let sky = SKSpriteNode(imageNamed: "Sky")
            sky.name = "Sky"
            sky.anchorPoint = CGPoint(x: 0, y: 0.5)
            sky.size = CGSize(width: frame.width*2, height: frame.height)
            sky.position = CGPoint(x: -frame.width/2 + CGFloat(i)*sky.size.width - 5, y: 0)
            sky.zPosition = -10
            addChild(sky)
        }
    }
    
    func createClouds() {
        for i in 0...1 {
            let clouds = SKSpriteNode(imageNamed: "Clouds")
            clouds.name = "Clouds"
            clouds.anchorPoint = CGPoint(x: 0, y: 0.5)
            clouds.size = CGSize(width: frame.width*2, height: frame.height)
            clouds.position = CGPoint(x: -frame.width/2 + CGFloat(i)*clouds.size.width - 5, y: 0)
            clouds.zPosition = -9
            addChild(clouds)
        }
    }
    
    func createMountains() {
        for i in 0...1 {
            let mountains = SKSpriteNode(imageNamed: "Mountains")
            mountains.name = "Mountains"
            mountains.anchorPoint = CGPoint(x: 0, y: 0.5)
            mountains.size = CGSize(width: frame.width*2, height: frame.height)
            mountains.position = CGPoint(x: -frame.width/2 + CGFloat(i)*mountains.size.width - 5, y: -40)
            mountains.zPosition = -8
            addChild(mountains)
        }
    }
    
    func createGround() {
        for i in 0...1 {
            let ground = SKSpriteNode(imageNamed: "Ground")
            ground.name = "Ground"
            ground.anchorPoint = CGPoint(x: 0, y: 0.5)
            ground.size = CGSize(width: frame.width*2, height: frame.height)
            ground.position = CGPoint(x: -frame.width/2 + CGFloat(i)*ground.size.width - 5, y: -40)
            ground.zPosition = -7
            
            let trees = SKSpriteNode(imageNamed: "Trees")
            trees.name = "Trees"
            trees.anchorPoint = CGPoint(x: 0, y: 0.5)
            trees.size = CGSize(width: ground.size.width, height: ground.size.height)
            trees.position = CGPoint(x: 0, y: 0)
            trees.zPosition = 0
            
            addChild(ground)
            ground.addChild(trees)
        }
    }
    
    func moveBackground() {
        moveSky()
        moveClouds()
        moveMountains()
        moveGround()
    }
    
    func moveSky() {
        moveLayer(named: "Sky", speed: 0.125)
    }
    
    func moveClouds() {
        moveLayer(named: "Clouds", speed: 0.25)
    }
    
    func moveMountains() {
        moveLayer(named: "Mountains", speed: 0.5)
    }
    
    func moveGround() {
        moveLayer(named: "Ground", speed: 1)
    }
    
    func moveLayer(named name: String, speed: CGFloat) {
        enumerateChildNodes(withName: name) { (node, error) in
            node.position.x -= speed
            if node.position.x < -(node.frame.size.width + self.frame.width/2) {
                node.position.x = -self.frame.width/2 + node.frame.size.width - 5
            }
        }
    }
}
