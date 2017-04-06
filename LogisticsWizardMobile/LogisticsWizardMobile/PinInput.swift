//
//  PinInput.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 4/4/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit

final class PinInput: UIControl {
    
    // MARK: - Types
    
    private final class DigitView: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            textColor = .white
            
            font = .systemFont(ofSize: 100)
            adjustsFontSizeToFitWidth = true
            textAlignment = .center
            text = " "
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // MARK: - Properties
    
    var value = [Int]() {
        didSet {
            // Update views
            for (i, view) in digitViews.enumerated() {
                guard i < value.count else {
                    view.text = " "
                    continue
                }
                view.text = String(value[i])
            }

            // Fire events
            sendActions(for: .valueChanged)
            
            if value.count == length {
                sendActions(for: .primaryActionTriggered)
            }
        }
    }
    
    let length: Int
    
    private let digitViews: [DigitView]
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 8
        return view
    }()
    
    // MARK: - Initializers
    
    init(length: Int = 4) {
        self.length = length
        
        var views = [DigitView]()
        for _ in 0..<length {
            let view = DigitView()
            views.append(view)
        }
        digitViews = views
        
        super.init(frame: .zero)
        
        UIView.animate(withDuration: 2, animations: {
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 2
            self.layer.cornerRadius = 4
        })
        
        digitViews.forEach(stackView.addArrangedSubview)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UIResponder
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension PinInput: UITextInputTraits {
    var keyboardType: UIKeyboardType {
        get {
            return .numberPad
        }
        
        set {
            // Do nothing
        }
    }
}

extension PinInput: UIKeyInput {
    var hasText: Bool {
        return !value.isEmpty
    }
    
    func insertText(_ text: String) {
        guard value.count < length, let integer = Int(text) else { return }        
        value.append(integer)
    }
    
    func deleteBackward() {
        value.removeLast()
    }
}
