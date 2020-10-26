//
//  CalendarPickerHeaderView.swift
//  CustomCalendar
//
//  Created by Oleg Soloviev on 25.10.2020.
//  Copyright © 2020 Oleg Soloviev. All rights reserved.
//

import UIKit

final class CalendarPickerHeaderView: UIView {
    
    private lazy var previousMonthButton = makeButton()
    private lazy var monthLabel = makeMonthLabel()
    private lazy var refreshButton = makeButton()
    private lazy var nextMonthButton = makeButton()
    
    private lazy var dayOfWeekStackView: UIStackView = {
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
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    var baseDate = Date() {
        didSet {
            monthLabel.text = dateFormatter.string(from: baseDate)
        }
    }
    
    private let didTapRefreshCompletionHandler: (() -> Void)
    private let didTapLastMonthCompletionHandler: (() -> Void)
    private let didTapNextMonthCompletionHandler: (() -> Void)
    
    init(didTapRefreshCompletionHandler: @escaping (() -> Void),
         didTapLastMonthCompletionHandler: @escaping (() -> Void),
         didTapNextMonthCompletionHandler: @escaping (() -> Void)) {
        
        self.didTapRefreshCompletionHandler = didTapRefreshCompletionHandler
        self.didTapLastMonthCompletionHandler = didTapLastMonthCompletionHandler
        self.didTapNextMonthCompletionHandler = didTapNextMonthCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        addSubview(previousMonthButton)
        addSubview(monthLabel)
        addSubview(refreshButton)
        addSubview(nextMonthButton)
        addSubview(separatorView)
        addSubview(dayOfWeekStackView)
        
        for dayNumber in 1...7 {
            let dayLabel = makeDayLabel(for: dayNumber)
            dayOfWeekStackView.addArrangedSubview(dayLabel)
        }
        
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        let leftImage = UIImage(systemName: "chevron.left.circle.fill", withConfiguration: configuration)
        let refreshImage = UIImage(systemName: "arrow.2.circlepath.circle.fill", withConfiguration: configuration)
        let rightImage = UIImage(systemName: "chevron.right.circle.fill", withConfiguration: configuration)
        
        previousMonthButton.setImage(leftImage, for: .normal)
        refreshButton.setImage(refreshImage, for: .normal)
        nextMonthButton.setImage(rightImage, for: .normal)
        
        previousMonthButton.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(didTapRefreshButton), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            previousMonthButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            previousMonthButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 28),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 28),
            
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            monthLabel.leadingAnchor.constraint(equalTo: previousMonthButton.trailingAnchor, constant: 10),
            
            refreshButton.trailingAnchor.constraint(equalTo: nextMonthButton.leadingAnchor, constant: -10),
            refreshButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            refreshButton.heightAnchor.constraint(equalToConstant: 28),
            refreshButton.widthAnchor.constraint(equalToConstant: 28),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            nextMonthButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextMonthButton.heightAnchor.constraint(equalToConstant: 28),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 28),
            
            separatorView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 14),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            dayOfWeekStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            dayOfWeekStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayOfWeekStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

private extension CalendarPickerHeaderView {
    
    @objc
    func didTapPreviousMonthButton() {
        didTapLastMonthCompletionHandler()
    }
    
    @objc
    func didTapRefreshButton() {
        didTapRefreshCompletionHandler()
    }
    
    @objc
    func didTapNextMonthButton() {
        didTapNextMonthCompletionHandler()
    }
    
    func dayOfWeekString(for dayNumber: Int) -> String {
        switch dayNumber {
        case 1: return "SUN"
        case 2: return "MON"
        case 3: return "TUE"
        case 4: return "WED"
        case 5: return "THU"
        case 6: return "FRI"
        case 7: return "SAT"
        default: return ""
        }
    }
    
    func makeDayLabel(for dayNumber: Int) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = dayOfWeekString(for: dayNumber)
        return label
    }
    
    func makeMonthLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }
    
    func makeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemBlue
        button.contentMode = .scaleAspectFill
        return button
    }
}
