//
//  NotePosition.swift
//  TuneMyTone
//
//  Created by Fernando N. Frassia on 11/30/18.
//  Copyright © 2018 Fernando N. Frassia. All rights reserved.
//

public struct MyNote {
    public var letter: String
    public var octave: Int
    
    public var string: String {
        return letter + "\(octave)"
    }
    
    public init(letter: String, octave: Int) {
        self.letter = letter
        self.octave = octave
    }
    
    public func position() -> Double? {
        let initialPosition = 0.0
        let distanceConstant = 5.0
    
        guard let index = noteValues().firstIndex(of: self.string) else {return nil}
        return initialPosition + Double(index) * distanceConstant
    }
    
    private func noteValues() -> [String] {
        let templateValues = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        var values = [String]()
        for i in 0...2 {
            values += templateValues.map {$0 + "\(i)"}
        }
        return values
    }
}
