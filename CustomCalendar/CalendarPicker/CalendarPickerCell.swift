//
//  CalendarPickerCell.swift
//  CustomCalendar
//
//  Created by Oleg Soloviev on 25.10.2020.
//  Copyright © 2020 Oleg Soloviev. All rights reserved.
//

import UIKit

final class CalendarPickerCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: CalendarPickerCell.self)

    private let calendar = Calendar(identifier: .gregorian)
    private lazy var collectionView = makeCollectionView()
    private lazy var headerView = CalendarPickerHeaderView(
        didTapRefreshCompletionHandler: { [weak self] in
            guard let self = self else { return }
            self.startSelectedDate = self.calendar.startOfDay(for: Date())
            self.endSelectedDate = self.startSelectedDate
            self.baseDate = self.startSelectedDate
        },
        didTapLastMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            self.baseDate = self.calendar.date(byAdding: .month, value: -1, to: self.baseDate) ?? self.baseDate
        },
        didTapNextMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            self.baseDate = self.calendar.date(byAdding: .month, value: 1, to: self.baseDate) ?? self.baseDate
    })
    private lazy var footerView = CalendarPickerFooterView(
        didTapStartDateCompletionHandler: { [weak self] in
            guard let self = self else { return }
            self.startDate = true
        },
        didTapEndDateCompletionHandler: { [weak self] in
            guard let self = self else { return }
            self.startDate = false
    })
    
    private lazy var startDate = true
    private lazy var startSelectedDate = calendar.startOfDay(for: Date())
    private lazy var endSelectedDate = calendar.startOfDay(for: Date())

    private lazy var days = generateDaysInMonth(for: baseDate)
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    private var numberOfWeeksInBaseDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 1
    }
    private var baseDate = Date() {
        didSet {
            days = generateDaysInMonth(for: baseDate)
            collectionView.reloadData()
            headerView.baseDate = baseDate
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(collectionView)
        addSubview(headerView)
        addSubview(footerView)

        headerView.baseDate = baseDate
        headerView.backgroundColor = backgroundColor
        footerView.backgroundColor = backgroundColor

        collectionView.register(CalendarDateCollectionViewCell.self, forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.deactivate(collectionView.constraints)
        NSLayoutConstraint.deactivate(headerView.constraints)
        NSLayoutConstraint.deactivate(footerView.constraints)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 90),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 245),

            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            footerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)

      collectionView.reloadData()
      layoutSubviews()
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarPickerCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { days.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day = days[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier, for: indexPath) as? CalendarDateCollectionViewCell
        cell?.day = day
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarPickerCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        selectedDateChanged(day.date)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
    }
}

private extension CalendarPickerCell {
    func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = backgroundColor
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
            else { throw CalendarDataError.metadataGeneration }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        return MonthMetadata(numberOfDays: numberOfDaysInMonth, firstDay: firstDayOfMonth, firstDayWeekday: firstDayWeekday)
    }
    
    func generateDaysInMonth(for baseDate: Date) -> [Day] {
        guard let metadata = try? monthMetadata(for: baseDate) else { preconditionFailure("An error occurred when generating the metadata for \(baseDate)") }
        
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth, isWithinDisplayedMonth: isWithinDisplayedMonth)
        }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
    }
    
    func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return Day(date: date, number: dateFormatter.string(from: date), isSelected: date >= startSelectedDate && date <= endSelectedDate, isWithinDisplayedMonth: isWithinDisplayedMonth)
    }
    
    func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard let lastDayInMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfDisplayedMonth) else { return [] }
        
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else { return [] }
        
        let days: [Day] = (1...additionalDays)
            .map { generateDay(offsetBy: $0, for: lastDayInMonth, isWithinDisplayedMonth: false) }
        
        return days
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
    
    func selectedDateChanged(_ date: Date) {
        if startDate {
            startSelectedDate = date
            endSelectedDate = date
        } else {
            if date >= startSelectedDate {
                endSelectedDate = date
            } else if date < startSelectedDate {
                startSelectedDate = date
            }
        }

        days = generateDaysInMonth(for: baseDate)
        collectionView.reloadData()
    }
}
