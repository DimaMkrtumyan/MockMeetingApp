//
//  MeetingPageViewController.swift
//  MeetingMock
//
//  Created by Dmitriy Mkrtumyan on 22.11.23.
//

import UIKit

final class MeetingPageViewController: UIViewController {
    //MARK: - UI Objects
    private var addButton: PrimaryButton?
    private var removeButton: PrimaryButton?
    let participantsViews: [PrimaryView] = (0..<10).map { _ in PrimaryView() }
    
    //MARK: - Data
    let primaryYPoint: CGFloat = 65
    private lazy var primaryData = PrimaryData(
        width: self.view.bounds.width - (20 * 2),
        height: self.view.bounds.height * 0.8,
        inset: 20,
        primaryXPoint: 20,
        primaryYPoint: primaryYPoint,
        buttonsYPoint: view.bounds.height - (((view.bounds.height - (view.bounds.height * 0.8)) - primaryYPoint) - 40),
        buttonsWidth: ((view.bounds.width - (20 * 2)) / 2) - 10,
        buttonsHeight: ((view.bounds.height - (view.bounds.height * 0.8)) - 140)
    )
    private var participantsIndex: Int = 0
    private var participantsID: Int {
        participantsIndex + 1
    }
    private var previousIndex: Int {
        self.participantsIndex - 1
    }
    private var currentIndex: Int {
        self.participantsIndex
    }
    private var durationOfAnimation: Double = 0.4
    
    //MARK: - Business Logic
    private func addButtonsActions() {
        addButton?.onTap(action: {
            self.addParticipant()
        })
        removeButton?.onTap(action: {
            self.removeParticipant()
        })
    }
    
    private func addOrRemoveParticipant(flag: Bool) {
        subviewsCalculations(counter: participantsIndex, flag: flag)
    }
    
    private func addParticipant() {
        addOrRemoveParticipant(flag: true)
    }
    
    private func removeParticipant() {
        addOrRemoveParticipant(flag: false)
    }
    
    private func addGestures(index: Int) {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(viewTapped))
        
        self.participantsViews[index].addGestureRecognizer(tap)
        self.participantsViews[index].isUserInteractionEnabled = true
    }
    
    private func removeSubviewAnimation(_ view: PrimaryView) {
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.fromValue = 1.0
        fadeOutAnimation.toValue = 0.0
        fadeOutAnimation.duration = 0.3
        fadeOutAnimation.fillMode = .forwards
        fadeOutAnimation.isRemovedOnCompletion = true
        
        view.layer.add(fadeOutAnimation, forKey: "fadeOut")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            view.removeFromSuperview()
        }
    }
    
    @objc
    private func viewTapped() {
        addOrRemoveParticipant(flag: false)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
        addButtonsActions()
        addGestures(index: 0)
    }
}

//MARK: - UI Configuration Methods
extension MeetingPageViewController {
    private func initialUISetup() {
        view.backgroundColor = .white
        
        participantsViews[0].setup(frame: CGRect(x: primaryData.primaryXPoint,
                                                 y: 65,
                                                 width: primaryData.width,
                                                 height: primaryData.height),
                                   counter: participantsID)
        
        view.addSubview(participantsViews[0])
        
        addButton = PrimaryButton(frame:
                                    CGRect(
                                        x: primaryData.primaryXPoint,
                                        y: primaryData.buttonsYPoint,
                                        width: primaryData.buttonsWidth,
                                        height: primaryData.buttonsHeight),
                                  title: "ADD")
        
        removeButton = PrimaryButton(frame:
                                        CGRect(
                                            x: primaryData.buttonsWidth + (primaryData.inset * 2),
                                            y: primaryData.buttonsYPoint,
                                            width: primaryData.buttonsWidth,
                                            height: primaryData.buttonsHeight),
                                     title: "REMOVE")
        
        if let addButton, let removeButton {
            view.addSubview(addButton)
            view.addSubview(removeButton)
        }
    }
    
}

extension MeetingPageViewController {
    //MARK: - Second Recalculation Case (5 -> 6/ 6 -> 5)
    private func secondCaseRecalculation(_ yOrigin: CGFloat) {
        let height = (participantsViews[0].frame.width / 2) - (primaryData.inset / 2)
        let height2 = (primaryData.height / 2) - (primaryData.inset / 2)

        if currentIndex == 5 {
            self.participantsViews[0].recalculateFrame(size: CGSize(width: self.primaryData.width,
                                                                    height: height2))
            self.participantsViews[1].frame.origin = CGPoint(x: self.participantsViews[0].frame.minX,
                                                             y: self.participantsViews[0].frame.maxY + self.primaryData.inset)
            self.participantsViews[2].frame.origin = CGPoint(x: self.participantsViews[1].frame.width + (2 * self.primaryData.inset),
                                                             y: self.participantsViews[1].frame.minY)
            self.participantsViews[3].frame.origin = CGPoint(x: self.participantsViews[1].frame.minX,
                                                             y: self.participantsViews[1].frame.maxY + self.primaryData.inset)
            self.participantsViews[4].frame.origin = CGPoint(x: self.participantsViews[3].frame.width + (2 * self.primaryData.inset),
                                                             y: self.participantsViews[3].frame.minY)
        } else {
            self.participantsViews[self.previousIndex].recalculateFrame(size: CGSize(width: height,
                                                                                     height: height))
            
            self.participantsViews[self.currentIndex].setup(
                frame: CGRect(origin: CGPoint(
                    x: self.participantsViews[self.previousIndex].frame.maxX + self.primaryData.inset,
                    y: yOrigin),
                              size: self.participantsViews[self.previousIndex].frame.size),
                counter: self.participantsID)
            
            self.view.addSubview(self.participantsViews[self.currentIndex])
            
            self.addGestures(index: self.currentIndex)
        }
    }
    
    //MARK: - Third Recalculation Case (8 -> 9/ 9 -> 8)
    private func thirdCaseRecalculation(_ flag: Bool) {
        if flag {
            let rect = (self.participantsViews[2].frame.width / 2) - (self.primaryData.inset / 2)
            
            UIView.animate(withDuration: self.durationOfAnimation) {
                self.participantsViews[0].recalculateFrame(size: CGSize(width: self.primaryData.width,
                                                                        height: self.primaryData.height / 2))
                self.participantsViews[1].frame.origin = CGPoint(x: self.participantsViews[0].frame.minX,
                                                                 y: self.participantsViews[0].frame.maxY + self.primaryData.inset)
                
                self.participantsViews[2].frame.origin = CGPoint(x: self.participantsViews[1].frame.width + (2 * self.primaryData.inset),
                                                                 y: self.participantsViews[1].frame.minY)
                
                self.participantsViews[3].frame.origin = CGPoint(x: self.participantsViews[1].frame.minX,
                                                                 y: self.participantsViews[1].frame.maxY + self.primaryData.inset)
                self.participantsViews[3].recalculateFrame(size: CGSize(width: rect, height: rect))
                
                self.participantsViews[4].frame.origin = CGPoint(x: self.participantsViews[3].frame.width + (2 * self.primaryData.inset),
                                                                 y: self.participantsViews[3].frame.minY)
                self.participantsViews[4].recalculateFrame(size: self.participantsViews[3].frame.size)
                
                self.participantsViews[5].frame.origin = CGPoint(x: self.participantsViews[2].frame.minX,
                                                                 y: self.participantsViews[4].frame.minY)
                self.participantsViews[5].recalculateFrame(size: self.participantsViews[4].frame.size)
                
                self.participantsViews[6].frame.origin = CGPoint(x: self.participantsViews[5].frame.maxX + self.primaryData.inset,
                                                                 y: self.participantsViews[5].frame.minY)
                self.participantsViews[6].recalculateFrame(size: self.participantsViews[5].frame.size)
                
                self.participantsViews[7].frame.origin = CGPoint(x: self.participantsViews[3].frame.minX,
                                                                 y: self.participantsViews[3].frame.maxY + self.primaryData.inset)
                self.participantsViews[7].recalculateFrame(size: self.participantsViews[6].frame.size)
                
                self.participantsViews[self.currentIndex].setup(frame: CGRect(origin: CGPoint(x: self.participantsViews[7].frame.maxX + self.primaryData.inset,
                                                                                              y: self.participantsViews[7].frame.minY),
                                                                              size: self.participantsViews[7].frame.size),
                                                                counter: self.participantsID)
                
                self.view.addSubview(self.participantsViews[self.currentIndex])
                
                self.addGestures(index: self.currentIndex)
            }
        } else {
            let rect = self.participantsViews[1].frame.width
            let smallRect = (rect / 2) - (self.primaryData.inset / 2)
            
            UIView.animate(withDuration: self.durationOfAnimation) {
                self.participantsViews[0].recalculateFrame(size: CGSize(width: rect,
                                                                        height: rect))
                
                self.participantsViews[1].frame.origin = CGPoint(x: self.participantsViews[0].frame.maxX + self.primaryData.inset,
                                                                 y: self.participantsViews[0].frame.minY)
                
                self.participantsViews[2].frame.origin = CGPoint(x: self.participantsViews[0].frame.minX,
                                                                 y: self.participantsViews[0].frame.maxY + self.primaryData.inset)
                
                self.participantsViews[3].frame.origin = CGPoint(x: self.participantsViews[1].frame.minX,
                                                                 y: self.participantsViews[2].frame.minY)
                self.participantsViews[3].recalculateFrame(size: CGSize(width: rect, height: rect))
                
                self.participantsViews[4].frame.origin = CGPoint(x: self.participantsViews[2].frame.minX,
                                                                 y: self.participantsViews[2].frame.maxY + self.primaryData.inset)
                self.participantsViews[4].recalculateFrame(size: CGSize(width: rect, height: rect))
                
                self.participantsViews[5].frame.origin = CGPoint(x: self.participantsViews[3].frame.minX,
                                                                 y: self.participantsViews[4].frame.minY)
                self.participantsViews[5].recalculateFrame(size: CGSize(width: rect, height: rect))
                
                self.participantsViews[6].frame.origin = CGPoint(x: self.participantsViews[4].frame.minX,
                                                                 y: self.participantsViews[4].frame.maxY + self.primaryData.inset)
                self.participantsViews[6].recalculateFrame(size: CGSize(width: smallRect,
                                                                        height: smallRect))
                
                self.participantsViews[7].frame.origin = CGPoint(x: self.participantsViews[6].frame.maxX + self.primaryData.inset,
                                                                 y: self.participantsViews[6].frame.minY)
                self.participantsViews[7].recalculateFrame(size: CGSize(width: smallRect,
                                                                        height: smallRect))
                
                self.removeSubviewAnimation(self.participantsViews[self.currentIndex])
                self.participantsIndex -= 1
            }
        }
    }
    
    
    //MARK: - Subviews Calculations
    private func subviewsCalculations(counter: Int, flag: Bool) {
        //MARK: participantsIndex + 1
        if flag && counter < 9 {
            self.participantsIndex += 1
        }
        
        var yOrigin: CGFloat {
            if self.currentIndex > 1 {
                if self.currentIndex % 2 == 0 {
                    self.participantsViews[self.previousIndex - 1].frame.maxY + self.primaryData.inset
                } else {
                    self.participantsViews[self.previousIndex].frame.maxY + self.primaryData.inset
                }
            } else {
                self.participantsViews[self.previousIndex].frame.maxY + self.primaryData.inset
            }
        }
        
        switch counter {
        case 0:
            if flag {
                
                let height = (primaryData.height / 2) - (primaryData.inset / 2)
                self.participantsViews[self.previousIndex].recalculateFrame(size:
                                                                                CGSize(
                                                                                    width: self.primaryData.width,
                                                                                    height: height))
                
                self.participantsViews[self.currentIndex].setup(frame: CGRect(
                    origin: CGPoint( x: self.primaryData.primaryXPoint,
                                     y: yOrigin),
                    size: self.participantsViews[self.previousIndex].frame.size),
                                                                counter: self.participantsID)
                self.view.addSubview(self.participantsViews[self.currentIndex])
                
                self.addGestures(index: self.currentIndex)
            }
        case 1:
            if flag {
                secondCaseRecalculation(yOrigin)
            } else {
                UIView.animate(withDuration: self.durationOfAnimation) {
                    self.participantsViews[0].recalculateFrame(
                        size: CGSize(width: self.primaryData.width,
                                     height: self.primaryData.height))
                }
                
                removeSubviewAnimation(participantsViews[1])
                
                participantsIndex -= 1
            }
        case 2..<4:
            if flag {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: self.durationOfAnimation) {
                        self.participantsViews[self.currentIndex].setup(
                            frame: CGRect(origin:
                                            CGPoint(x: self.participantsViews[self.previousIndex - 1].frame.origin.x,
                                                    y: yOrigin),
                                          size: self.participantsViews[1].frame.size),
                            counter: self.participantsID)
                        self.view.addSubview(self.participantsViews[self.currentIndex])
                        
                        self.addGestures(index: self.currentIndex)
                    }
                }
            } else {
                removeSubviewAnimation(self.participantsViews[self.currentIndex])
                self.participantsIndex -= 1
                
                if self.currentIndex == 1 {
                    UIView.animate(withDuration: 0.5) {
                        self.participantsViews[1].recalculateFrame(
                            size: CGSize(width: self.primaryData.width,
                                         height: self.participantsViews[0].frame.height))
                        
                    }
                }
            }
        case 4:
            if flag {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: self.durationOfAnimation) {
                        self.participantsViews[0].recalculateFrame(size: self.participantsViews[self.previousIndex].frame.size)
                        
                        self.participantsViews[1].frame.origin = CGPoint(
                            x: self.participantsViews[0].frame.width + (2 * self.primaryData.inset),
                            y: self.primaryData.primaryYPoint)
                        
                        self.participantsViews[2].frame.origin = CGPoint(
                            x: self.participantsViews[0].frame.origin.x,
                            y: self.participantsViews[0].frame.maxY + self.primaryData.inset)
                        
                        self.participantsViews[3].frame.origin = CGPoint(
                            x: self.participantsViews[1].frame.origin.x,
                            y: self.participantsViews[1].frame.maxY + self.primaryData.inset)
                        
                        self.participantsViews[4].frame.origin = CGPoint(
                            x: self.participantsViews[2].frame.origin.x,
                            y: self.participantsViews[2].frame.maxY + self.primaryData.inset)
                        
                        self.participantsViews[self.currentIndex].setup(
                            frame: CGRect(origin:
                                            CGPoint(x: self.participantsViews[self.previousIndex - 1].frame.origin.x,
                                                    y: self.participantsViews[3].frame.maxY + self.primaryData.inset),
                                          size: self.participantsViews[self.previousIndex].frame.size),
                            counter: self.participantsID)
                        self.view.addSubview(self.participantsViews[self.currentIndex])
                        
                        self.addGestures(index: self.currentIndex)
                    }
                }
            } else {
                removeSubviewAnimation(self.participantsViews[self.currentIndex])
                self.participantsIndex -= 1
            }
        case 5..<7:
            if flag {
                let previousViewSize: CGSize
                let previousViewOrigin: CGPoint
                let rect = (self.participantsViews[self.previousIndex].frame.width / 2) - ((primaryData.inset / 2) * 0.1)
                print(self.currentIndex)
                if self.currentIndex == 6 {
                    previousViewSize = CGSize(width: rect,
                                              height: rect)
                    previousViewOrigin = CGPoint(x: self.participantsViews[self.previousIndex - 1].frame.minX,
                                                 y: self.participantsViews[self.previousIndex - 1].frame.maxY + primaryData.inset)
                } else {
                    previousViewSize = self.participantsViews[self.previousIndex].frame.size
                    previousViewOrigin = CGPoint(x: self.participantsViews[self.previousIndex].frame.width + (primaryData.inset * 2),
                                                 y: self.participantsViews[self.previousIndex].frame.minY)
                }
                
                self.participantsViews[self.currentIndex].setup(frame: CGRect(origin: previousViewOrigin,
                                                                              size: previousViewSize),
                                                                counter: self.participantsID)
                self.view.addSubview(self.participantsViews[self.currentIndex])
                
                self.addGestures(index: self.currentIndex)
            } else {
                removeSubviewAnimation(self.participantsViews[self.currentIndex])
                if self.currentIndex == 5 {
                    UIView.animate(withDuration: self.durationOfAnimation) {
                        self.secondCaseRecalculation(yOrigin)
                        self.participantsIndex -= 1
                    }
                } else {
                    self.participantsIndex -= 1
                }
            }
        case 7:
            if flag {
                self.thirdCaseRecalculation(flag)
            } else {
                removeSubviewAnimation(self.participantsViews[self.currentIndex])
                self.participantsIndex -= 1
            }
        case 8:
            if flag {
                UIView.animate(withDuration: self.durationOfAnimation) {
                    self.participantsViews[5].frame.origin = CGPoint(x: self.participantsViews[3].frame.minX,
                                                                     y: self.participantsViews[3].frame.maxY + self.primaryData.inset)
                    self.participantsViews[6].frame.origin = CGPoint(x: self.participantsViews[4].frame.minX,
                                                                     y: self.participantsViews[5].frame.minY)
                    self.participantsViews[7].frame.origin = CGPoint(x: self.participantsViews[4].frame.maxX + self.primaryData.inset,
                                                                     y: self.participantsViews[4].frame.minY)
                    self.participantsViews[8].frame.origin = CGPoint(x: self.participantsViews[7].frame.maxX + self.primaryData.inset,
                                                                     y: self.participantsViews[7].frame.minY)
                    
                    self.participantsViews[9].setup(frame: CGRect(origin: CGPoint(x: self.participantsViews[6].frame.maxX + self.primaryData.inset,
                                                                                  y: self.participantsViews[6].frame.minY),
                                                                  size: self.participantsViews[8].frame.size),
                                                    counter: self.participantsID)
                }
                
                self.view.addSubview(self.participantsViews[9])
                
                self.addGestures(index: 9)
            } else {
                self.thirdCaseRecalculation(flag)
            }
            
        case 9:
            if flag == false {
                let rect = (self.participantsViews[2].frame.width / 2) - (self.primaryData.inset / 2)
                
                UIView.animate(withDuration: self.durationOfAnimation) {
                    self.participantsViews[0].recalculateFrame(size: CGSize(width: self.primaryData.width,
                                                                            height: self.primaryData.height / 2))
                    self.participantsViews[1].frame.origin = CGPoint(x: self.participantsViews[0].frame.minX,
                                                                     y: self.participantsViews[0].frame.maxY + self.primaryData.inset)
                    self.participantsViews[2].frame.origin = CGPoint(x: self.participantsViews[1].frame.width + (2 * self.primaryData.inset),
                                                                     y: self.participantsViews[1].frame.minY)
                    
                    self.participantsViews[3].frame.origin = CGPoint(x: self.participantsViews[1].frame.minX,
                                                                     y: self.participantsViews[1].frame.maxY + self.primaryData.inset)
                    self.participantsViews[3].recalculateFrame(size: CGSize(width: rect, height: rect))
                    
                    self.participantsViews[4].frame.origin = CGPoint(x: self.participantsViews[3].frame.width + (2 * self.primaryData.inset),
                                                                     y: self.participantsViews[3].frame.minY)
                    self.participantsViews[4].recalculateFrame(size: self.participantsViews[3].frame.size)
                    
                    self.participantsViews[5].frame.origin = CGPoint(x: self.participantsViews[2].frame.minX,
                                                                     y: self.participantsViews[4].frame.minY)
                    self.participantsViews[5].recalculateFrame(size: self.participantsViews[4].frame.size)
                    
                    self.participantsViews[6].frame.origin = CGPoint(x: self.participantsViews[5].frame.maxX + self.primaryData.inset,
                                                                     y: self.participantsViews[5].frame.minY)
                    self.participantsViews[6].recalculateFrame(size: self.participantsViews[5].frame.size)
                    
                    self.participantsViews[7].frame.origin = CGPoint(x: self.participantsViews[3].frame.minX,
                                                                     y: self.participantsViews[3].frame.maxY + self.primaryData.inset)
                    
                    self.participantsViews[8].frame.origin = CGPoint(x: self.participantsViews[7].frame.maxX + self.primaryData.inset,
                                                                     y: self.participantsViews[7].frame.minY)
                }
                
                removeSubviewAnimation(self.participantsViews[self.currentIndex])
                self.participantsIndex -= 1
            }
            
        default:
            print("Default Case!")
        }
    }
    
}
