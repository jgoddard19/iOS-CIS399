//
//  DayService.swift
//  FinalProject
//
//  Created by Jared Goddard on 7/28/15.
//
//

import Foundation

class DayService {
    // MARK: Service
    func dayList() -> Array<(title: String, subtitle: String)> {
        return [("Monday", "Contains \(mondayLifts.count) lifts"),
            ("Tuesday", "Contains \(tuesdayLifts.count) lifts"),
            ("Wednesday", "Contains \(wednesdayLifts.count) lifts"),
            ("Thursday", "Contains \(thursdayLifts.count) lifts"),
            ("Friday", "Contains \(fridayLifts.count) lifts"),
            ("Saturday", "Contains \(saturdayLifts.count) lifts"),
            ("Sunday", "Contains \(sundayLifts.count) lifts")]
    }
    
    func daysForList(day: String) -> Array<String>? {
        let result: Array<String>?
        switch day {
        case "Monday":
            result = mondayLifts
        case "Tuesday":
            result = tuesdayLifts
        case "Wednesday":
            result = wednesdayLifts
        case "Thursday":
            result = thursdayLifts
        case "Friday":
            result = fridayLifts
        case "Saturday":
            result = saturdayLifts
        case "Sunday":
            result = sundayLifts
        default:
            result = nil
        }
        
        return result
    }
    
    // MARK: Initialization
    private init() {
        mondayLifts = []
        tuesdayLifts = []
        wednesdayLifts = []
        thursdayLifts = []
        fridayLifts = []
        saturdayLifts = []
        sundayLifts = []
    }
    
    // MARK: Properties (Private)
    private let mondayLifts: Array<String>!
    private let tuesdayLifts: Array<String>!
    private let wednesdayLifts: Array<String>!
    private let thursdayLifts: Array<String>!
    private let fridayLifts: Array<String>!
    private let saturdayLifts: Array<String>!
    private let sundayLifts: Array<String>!
    
    // MARK: Properties (Static)
    static let sharedDayService = DayService()
}