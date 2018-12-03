//
//  ScoreLabel.swift
//  TuneMyTone
//
//  Created by Fernando N. Frassia on 12/1/18.
//  Copyright © 2018 Fernando N. Frassia. All rights reserved.
//

import UIKit
import SpriteKit

class ScoreNode: SKNode {
    var success: SKSpriteNode!
    var congratsLbl: SKLabelNode!
    var scoreLbl: SKLabelNode!
    
    var score: Int = 0 {
        didSet {scoreLbl.text = "YOUR SCORE IS: \(min(100, score*10))"}
    }
    
    override init() {
        super.init()
        setCongratsLbl()
        setScoreLbl()
        setSuccess()
    }
    
    func setSuccess() {
        success = SKSpriteNode()
        success.position = CGPoint(x: frame.midX, y: scoreLbl.position.y + 80)
        addChild(success)
        
        var textures = [SKTexture]()
        for i in 0...16 {
            if i == 16 {
                for _ in 0...15 {
                    textures.append(SKTexture(imageNamed: "Success\(i)"))
                }
            } else {
                textures.append(SKTexture(imageNamed: "Success\(i)"))
            }
        }

        let textureAction = SKAction.animate(with: textures, timePerFrame: 0.04, resize: true, restore: false)
        success.run(SKAction.repeatForever(textureAction))
    }
    
    func createTickPath(ofLength n: Int) -> CGPath {
        let path = CGMutablePath()
        var x = success.position.x + 2
        var y = success.position.y + success.size.height/2
        path.move(to: CGPoint(x: x, y: y))
        
        let deltaX = CGFloat(0.1)
        let deltaY = CGFloat(0.2)
        for _ in 0...n {
            x += deltaX
            y -= deltaY
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
    
    func setCongratsLbl() {
        congratsLbl = SKLabelNode(fontNamed: "Subway Ticker")
        congratsLbl.name = "label"
        congratsLbl.text = "CONGRATULATIONS!"
        congratsLbl.fontSize = 20
        congratsLbl.fontColor = randColor()
        congratsLbl.horizontalAlignmentMode = .center;
        congratsLbl.verticalAlignmentMode = .center;
        congratsLbl.position = CGPoint(x: frame.midX, y: frame.size.height-2*congratsLbl.frame.size.height+10)
        addChild(congratsLbl)
    }
    
    func setScoreLbl() {
        scoreLbl = SKLabelNode(fontNamed: "Subway Ticker")
        scoreLbl.name = "scoreLabel"
        scoreLbl.fontSize = 20
        scoreLbl.fontColor = randColor()
        scoreLbl.horizontalAlignmentMode = .center;
        scoreLbl.verticalAlignmentMode = .center;
        scoreLbl.position = CGPoint(x: frame.midX, y: frame.size.height-scoreLbl.frame.size.height)
        addChild(scoreLbl)
    }
    
    func randUnder180() -> CGFloat {
        return CGFloat.random(in: 0..<180)
    }
    
    func randColor() -> SKColor {
        return SKColor(red: randUnder180()/255.0,
                       green: randUnder180()/255.0,
                       blue: randUnder180()/255.0,
                       alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
