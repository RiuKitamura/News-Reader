//
//  Date+Extensions.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 01/05/21.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
