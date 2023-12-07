//
//  PrimaryView.swift
//  MeetingMock
//
//  Created by Dmitriy Mkrtumyan on 22.11.23.
//

import UIKit.UIView

public class PrimaryView: UIView {
    let counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 70, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    func recalculateFrame(size: CGSize, point: CGPoint? = nil) {
        self.frame.size = size
        if let point {
            self.frame.origin = point
        }
        counterLabel.frame = self.bounds
    }
    
    func setup(frame: CGRect? = nil, counter: Int) {
        performAddAnimation()
        if let frame {
            self.frame = frame
        }
        
        counterLabel.frame = self.bounds
        counterLabel.text = "\(String(describing: counter))"
        
        addSubview(counterLabel)
        
        self.backgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
    }
        
    func performAddAnimation() {
        let fadeInAnimation = CATransition()
        fadeInAnimation.type = CATransitionType.moveIn
        fadeInAnimation.duration = 0.3
        
        self.layer.add(fadeInAnimation, forKey: "fadeIn")
    }

}
