//
//  CalendarViewController.swift
//  CustomCalendar
//
//  Created by Oleg Soloviev on 25.10.2020.
//  Copyright © 2020 Oleg Soloviev. All rights reserved.
//

import UIKit

final class CalendarViewController: UITableViewController {
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Custom Calendar"
        tableView.register(CalendarPickerCell.self, forCellReuseIdentifier: CalendarPickerCell.reuseIdentifier)
        tableView.rowHeight = 400
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CalendarPickerCell.reuseIdentifier, for: indexPath) as? CalendarPickerCell
        return cell ?? UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { "Dates" }
}

