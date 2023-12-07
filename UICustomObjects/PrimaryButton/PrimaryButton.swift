//
//  PrimaryButton.swift
//  MeetingMock
//
//  Created by Dmitriy Mkrtumyan on 22.11.23.
//

import UIKit.UIView

class PrimaryButton: UIButton {
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        initialSetup(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init(coder:) has not been implemented")
    }
    
    private func initialSetup(title: String) {
        backgroundColor = .black
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    }
    
    func onTap(action: @escaping () -> Void) {
        addAction(UIAction(handler: { _ in
            action()
        }), for: .touchUpInside)
    }
    
}
