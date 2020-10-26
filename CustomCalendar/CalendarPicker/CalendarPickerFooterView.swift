//
//  CalendarPickerFooterView.swift
//  CustomCalendar
//
//  Created by Oleg Soloviev on 25.10.2020.
//  Copyright © 2020 Oleg Soloviev. All rights reserved.
//

import UIKit

final class CalendarPickerFooterView: UIView {
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    private lazy var splitView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    private lazy var startButton = makeButton()
    private lazy var endButton = makeButton()
    
    private let didTapStartDateCompletionHandler: (() -> Void)
    private let didTapEndDateCompletionHandler: (() -> Void)
    
    init(
        didTapStartDateCompletionHandler: @escaping (() -> Void),
        didTapEndDateCompletionHandler: @escaping (() -> Void)
    ) {
        self.didTapStartDateCompletionHandler = didTapStartDateCompletionHandler
        self.didTapEndDateCompletionHandler = didTapEndDateCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGroupedBackground
        
        layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        addSubview(separatorView)
        addSubview(splitView)
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(startButton)
        buttonStackView.addArrangedSubview(endButton)

        let startButtonTitle = makeAttributedTitle(title: .start, image: .smallcircle)
        startButton.setAttributedTitle(startButtonTitle, for: .normal)
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)

        let endButtonTitle = makeAttributedTitle(title: .end, image: .circle)
        endButton.setAttributedTitle(endButtonTitle, for: .normal)
        endButton.addTarget(self, action: #selector(didTapEndButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let smallDevice = UIScreen.main.bounds.width <= 350
        let fontPointSize: CGFloat = smallDevice ? 14 : 17
        
        startButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
        endButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            splitView.topAnchor.constraint(equalTo: topAnchor),
            splitView.centerXAnchor.constraint(equalTo: centerXAnchor),
            splitView.heightAnchor.constraint(equalToConstant: bounds.height),
            splitView.widthAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

private extension CalendarPickerFooterView {
    
    enum TitleText: String {
        case start = "Start Date"
        case end = "End Date"
    }

    enum CircleImage: String {
        case circle = "circle"
        case smallcircle = "smallcircle.fill.circle"
    }

    func makeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.textColor = .systemBlue

        return button
    }

    func makeAttributedTitle(title: TitleText, image: CircleImage) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        if let chevronImage = UIImage(systemName: image.rawValue) {
            let imageAttachment = NSTextAttachment(image: chevronImage)
            
            attributedString.append(
                NSAttributedString(attachment: imageAttachment)
            )
            
            attributedString.append(
                NSAttributedString(string: " \(title.rawValue)")
            )
        }
        return attributedString
    }
    
    @objc
    func didTapStartButton() {
        let startButtonTitle = makeAttributedTitle(title: .start, image: .smallcircle)
        startButton.setAttributedTitle(startButtonTitle, for: .normal)

        let endButtonTitle = makeAttributedTitle(title: .end, image: .circle)
        endButton.setAttributedTitle(endButtonTitle, for: .normal)

        didTapStartDateCompletionHandler()
    }
    
    @objc
    func didTapEndButton() {
        let startButtonTitle = makeAttributedTitle(title: .start, image: .circle)
        startButton.setAttributedTitle(startButtonTitle, for: .normal)

        let endButtonTitle = makeAttributedTitle(title: .end, image: .smallcircle)
        endButton.setAttributedTitle(endButtonTitle, for: .normal)

        didTapEndDateCompletionHandler()
    }
}
