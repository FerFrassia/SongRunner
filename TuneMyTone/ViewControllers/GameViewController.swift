//
//  GameViewController.swift
//  TuneMyTone
//
//  Created by Fernando N. Frassia on 11/27/18.
//  Copyright © 2018 Fernando N. Frassia. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Beethoven
import Pitchy
import Hue

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameSKView: SKView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var offsetLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var gameScene: GameScene!
    var frequency: Double?
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        let config = Config(estimationStrategy: .yin)
        let pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine.levelThreshold = -30.0
        return pitchEngine
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameScene = GameScene(fileNamed: "GameScene")
        gameScene.size = gameSKView.frame.size
        gameScene.scaleMode = .aspectFill
        gameScene.tunerDelegate = self
        
        gameSKView.showsFPS = true
        gameSKView.showsNodeCount = true
        gameSKView.presentScene(gameScene)
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        let text = pitchEngine.active
            ? NSLocalizedString("Start", comment: "").uppercased()
            : NSLocalizedString("Stop", comment: "").uppercased()
        actionButton.setTitle(text, for: .normal)
        actionButton.backgroundColor = pitchEngine.active
            ? UIColor(red: 1.0/255.0, green: 153.0/255.0, blue: 2.0/255.0, alpha: 1.0)
            : .red
        
        noteLabel.text = "--"
        pitchEngine.active ? pitchEngine.stop() : pitchEngine.start()
        pitchEngine.active ? gameScene.startGame() : gameScene.stopGame()
        offsetLabel.isHidden = !pitchEngine.active
    }
}

// MARK: - PitchEngineDelegate
extension GameViewController: PitchEngineDelegate {
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        noteLabel.text = pitch.note.string
        
        let offsetPercentage = pitch.closestOffset.percentage
        let absOffsetPercentage = abs(offsetPercentage)
        
        print("pitch : \(pitch.note.string) - percentage : \(offsetPercentage)")
        
        guard absOffsetPercentage > 1.0 else {
            return
        }
        
        let prefix = offsetPercentage > 0 ? "" : "-"
        offsetLabel.text = "\(prefix)" + String(format:"%.2f", absOffsetPercentage)
        offsetLabel.isHidden = false
        
        frequency = pitch.frequency
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        print(error)
    }
    
    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below level threshold")
    }
}

// MARK: - GameSceneDelegate
extension GameViewController: GameSceneDelegate {
    func estimatedFrequency() -> Double? {
        return frequency
    }
}

// MARK: - Aux
private func offsetColor(_ offsetPercentage: Double) -> UIColor {
    let color: UIColor
    
    switch abs(offsetPercentage) {
    case 0...5:
        color = UIColor(hex: "3DAFAE")
    case 6...25:
        color = UIColor(hex: "FDFFB1")
    default:
        color = UIColor(hex: "E13C6C")
    }
    
    return color
}


