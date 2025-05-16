//
//  AnchorLayoutGuide.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

class AnchorLayoutGuide: UIWindow {
    
    var newFrame: CGRect = .zero {
        didSet {
            if newFrame.width != 0 && newFrame.height != 0 {
                selectedView.frame = newFrame
                self.hideShowConstraints()
            }
        }
    }
    var mainViewFrame: CGRect = .zero {
        didSet {
            mainView.frame = mainViewFrame
        }
    }
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    private let selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    private let leadingConstant: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
//        label.isHidden = true
        label.text = ""
        label.layer.cornerRadius = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let trailingConstant: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
//        label.isHidden = true
        label.text = ""
        label.layer.cornerRadius = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let topConstant: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
//        label.isHidden = true
        label.text = ""
        label.layer.cornerRadius = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let bottomConstant: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
//        label.isHidden = true
        label.text = ""
        label.layer.cornerRadius = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leadingLine: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let trailingLine: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let topLine: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var timer: Timer?
    
    deinit {
        self.resignKey()
        self.isHidden = true
    }
    
    init() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            super.init(windowScene: windowScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        self.backgroundColor = .clear
        self.windowLevel = .normal
        self.isUserInteractionEnabled = false
        self.doInitSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods
extension AnchorLayoutGuide {
    private func doInitSetup() {
        self.addSubview(mainView)
        self.mainView.addSubview(selectedView)
        self.mainView.addSubview(leadingLine)
        self.mainView.addSubview(trailingLine)
        self.mainView.addSubview(topLine)
        self.mainView.addSubview(bottomLine)
//        self.mainView.addSubview(leadingConstant)
//        self.mainView.addSubview(trailingConstant)
//        self.mainView.addSubview(topConstant)
//        self.mainView.addSubview(bottomConstant)
        
        let inset: CGFloat = 4
        
        let leadingView = UIView()
        leadingView.layer.cornerRadius = 5
        leadingView.isHidden = true
        leadingView.backgroundColor = .red
        leadingView.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.addSubview(leadingView)
        leadingView.addSubview(leadingConstant)
        NSLayoutConstraint.activate([
            leadingConstant.leadingAnchor.constraint(equalTo: leadingView.leadingAnchor, constant: inset),
            leadingConstant.trailingAnchor.constraint(equalTo: leadingView.trailingAnchor, constant: -inset),
            leadingConstant.topAnchor.constraint(equalTo: leadingView.topAnchor, constant: inset),
            leadingConstant.bottomAnchor.constraint(equalTo: leadingView.bottomAnchor, constant: -inset)
        ])
        
        let trailingView = UIView()
        trailingView.layer.cornerRadius = 5
        trailingView.isHidden = true
        trailingView.backgroundColor = .red
        trailingView.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.addSubview(trailingView)
        trailingView.addSubview(trailingConstant)
        NSLayoutConstraint.activate([
            trailingConstant.leadingAnchor.constraint(equalTo: trailingView.leadingAnchor, constant: inset),
            trailingConstant.trailingAnchor.constraint(equalTo: trailingView.trailingAnchor, constant: -inset),
            trailingConstant.topAnchor.constraint(equalTo: trailingView.topAnchor, constant: inset),
            trailingConstant.bottomAnchor.constraint(equalTo: trailingView.bottomAnchor, constant: -inset)
        ])
        
        let topView = UIView()
        topView.layer.cornerRadius = 5
        topView.isHidden = true
        topView.backgroundColor = .red
        topView.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.addSubview(topView)
        topView.addSubview(topConstant)
        NSLayoutConstraint.activate([
            topConstant.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: inset),
            topConstant.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -inset),
            topConstant.topAnchor.constraint(equalTo: topView.topAnchor, constant: inset),
            topConstant.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -inset)
        ])
        
        let bottomView = UIView()
        bottomView.layer.cornerRadius = 5
        bottomView.isHidden = true
        bottomView.backgroundColor = .red
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.addSubview(bottomView)
        bottomView.addSubview(bottomConstant)
        NSLayoutConstraint.activate([
            bottomConstant.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: inset),
            bottomConstant.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -inset),
            bottomConstant.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: inset),
            bottomConstant.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -inset)
        ])
        
        NSLayoutConstraint.activate([
            leadingView.centerXAnchor.constraint(equalTo: leadingLine.centerXAnchor),
            leadingView.centerYAnchor.constraint(equalTo: leadingLine.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            trailingView.centerXAnchor.constraint(equalTo: trailingLine.centerXAnchor),
            trailingView.centerYAnchor.constraint(equalTo: trailingLine.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topView.centerXAnchor.constraint(equalTo: topLine.centerXAnchor),
            topView.centerYAnchor.constraint(equalTo: topLine.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomView.centerXAnchor.constraint(equalTo: bottomLine.centerXAnchor),
            bottomView.centerYAnchor.constraint(equalTo: bottomLine.centerYAnchor)
        ])
        
        self.setConstraintsOfFrames()
        self.makeKeyAndVisible()
    }
    
    private func setConstraintsOfFrames() {
        NSLayoutConstraint.activate([
            leadingLine.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            leadingLine.trailingAnchor.constraint(equalTo: selectedView.leadingAnchor),
            leadingLine.centerYAnchor.constraint(equalTo: selectedView.centerYAnchor),
            leadingLine.heightAnchor.constraint(equalToConstant: 1.5)
        ])
        
        NSLayoutConstraint.activate([
            trailingLine.leadingAnchor.constraint(equalTo: selectedView.trailingAnchor),
            trailingLine.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            trailingLine.centerYAnchor.constraint(equalTo: selectedView.centerYAnchor),
            trailingLine.heightAnchor.constraint(equalToConstant: 1.5)
        ])
        
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: mainView.topAnchor),
            topLine.bottomAnchor.constraint(equalTo: selectedView.topAnchor),
            topLine.centerXAnchor.constraint(equalTo: selectedView.centerXAnchor),
            topLine.widthAnchor.constraint(equalToConstant: 1.5)
        ])
        
        NSLayoutConstraint.activate([
            bottomLine.topAnchor.constraint(equalTo: selectedView.bottomAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            bottomLine.centerXAnchor.constraint(equalTo: selectedView.centerXAnchor),
            bottomLine.widthAnchor.constraint(equalToConstant: 1.5)
        ])
    }
    
    private func hideShowConstraints() {
        self.timer?.invalidate()
        self.leadingLine.isHidden = false
        self.trailingLine.isHidden = false
        self.bottomLine.isHidden = false
        self.topLine.isHidden = false
        let trailing = (mainViewFrame.size.width - (newFrame.origin.x + newFrame.width))
        let bottom = (mainViewFrame.size.height - (newFrame.origin.y + newFrame.height))
        self.leadingConstant.text = "\(Int(newFrame.origin.x))"
        self.trailingConstant.text = "\(Int(trailing))"
        self.topConstant.text = "\(Int(newFrame.origin.y))"
        self.bottomConstant.text = "\(Int(bottom))"
        self.leadingConstant.superview?.isHidden = false
        self.trailingConstant.superview?.isHidden = false
        self.topConstant.superview?.isHidden = false
        self.bottomConstant.superview?.isHidden = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            DispatchQueue.main.async {
                self.leadingLine.isHidden = true
                self.trailingLine.isHidden = true
                self.bottomLine.isHidden = true
                self.topLine.isHidden = true
                
                self.leadingConstant.superview?.isHidden = true
                self.trailingConstant.superview?.isHidden = true
                self.topConstant.superview?.isHidden = true
                self.bottomConstant.superview?.isHidden = true
            }
        })
    }
}
