//
//  GreatingDaysData.swift
//  iSalah
//
//  Created on 9.03.2025.
//

import SwiftUI

/// A struct to provide Islamic special days data for the next 5+ years
struct GreatingDaysData {
    
    /// Returns all Islamic special days for the next 5+ years
    static func getAllDays() -> [Int: [GreatingDaysModel]] {
        var allYearsDays: [Int: [GreatingDaysModel]] = [:]
        
        // Current year
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Add specific data for 2025
        allYearsDays[2025] = getDaysFor2025()
        
        // Add specific data for 2026
        allYearsDays[2026] = getDaysFor2026()
      
        return allYearsDays
    }
    
    /// Returns the accurate Islamic special days for 2025
    static func getDaysFor2025() -> [GreatingDaysModel] {
        let calendar = Calendar.current
        
        // Helper function to create date components
        func createDate(year: Int, month: Int, day: Int) -> Date {
            let components = DateComponents(year: year, month: month, day: day)
            return calendar.date(from: components) ?? Date()
        }
        
        return [
            // Beginning of Three Holy Months
            GreatingDaysModel(
                id: 1000,
                name: "Beginning of Three Holy Months",
                date: createDate(year: 2025, month: 1, day: 1)
            ),
            
            // Ragaib Night
            GreatingDaysModel(
                id: 1001,
                name: "Ragaib Night",
                date: createDate(year: 2025, month: 1, day: 2)
            ),
            
            // Night of Ascension
            GreatingDaysModel(
                id: 1002,
                name: "Night of Ascension",
                date: createDate(year: 2025, month: 1, day: 26)
            ),
            
            // Night of Forgiveness
            GreatingDaysModel(
                id: 1003,
                name: "Night of Forgiveness",
                date: createDate(year: 2025, month: 2, day: 13)
            ),
            
            // Beginning of Ramadan
            GreatingDaysModel(
                id: 1004,
                name: "Beginning of Ramadan",
                date: createDate(year: 2025, month: 3, day: 1)
            ),
            
            // Night of Power
            GreatingDaysModel(
                id: 1005,
                name: "Night of Power",
                date: createDate(year: 2025, month: 3, day: 26)
            ),
            
            // Eve of Eid al-Fitr
            GreatingDaysModel(
                id: 1006,
                name: "Eve of Eid al-Fitr",
                date: createDate(year: 2025, month: 3, day: 29)
            ),
            
            // Eid al-Fitr (Day 1)
            GreatingDaysModel(
                id: 1007,
                name: "Eid al-Fitr (Day 1)",
                date: createDate(year: 2025, month: 3, day: 30)
            ),
            
            // Eid al-Fitr (Day 2)
            GreatingDaysModel(
                id: 1008,
                name: "Eid al-Fitr (Day 2)",
                date: createDate(year: 2025, month: 3, day: 31)
            ),
            
            // Eid al-Fitr (Day 3)
            GreatingDaysModel(
                id: 1009,
                name: "Eid al-Fitr (Day 3)",
                date: createDate(year: 2025, month: 4, day: 1)
            ),
            
            // Eve of Eid al-Adha
            GreatingDaysModel(
                id: 1010,
                name: "Eve of Eid al-Adha",
                date: createDate(year: 2025, month: 6, day: 5)
            ),
            
            // Eid al-Adha (Day 1)
            GreatingDaysModel(
                id: 1011,
                name: "Eid al-Adha (Day 1)",
                date: createDate(year: 2025, month: 6, day: 6)
            ),
            
            // Eid al-Adha (Day 2)
            GreatingDaysModel(
                id: 1012,
                name: "Eid al-Adha (Day 2)",
                date: createDate(year: 2025, month: 6, day: 7)
            ),
            
            // Eid al-Adha (Day 3)
            GreatingDaysModel(
                id: 1013,
                name: "Eid al-Adha (Day 3)",
                date: createDate(year: 2025, month: 6, day: 8)
            ),
            
            // Eid al-Adha (Day 4)
            GreatingDaysModel(
                id: 1014,
                name: "Eid al-Adha (Day 4)",
                date: createDate(year: 2025, month: 6, day: 9)
            ),
            
            // Islamic New Year
            GreatingDaysModel(
                id: 1015,
                name: "Islamic New Year",
                date: createDate(year: 2025, month: 6, day: 26)
            ),
            
            // Day of Ashura
            GreatingDaysModel(
                id: 1016,
                name: "Day of Ashura",
                date: createDate(year: 2025, month: 7, day: 5)
            ),
            
            // Prophet's Birthday
            GreatingDaysModel(
                id: 1017,
                name: "Prophet's Birthday",
                date: createDate(year: 2025, month: 9, day: 3)
            )
        ]
    }
    
    /// Returns the accurate Islamic special days for 2026
    private static func getDaysFor2026() -> [GreatingDaysModel] {
        let calendar = Calendar.current
        
        // Helper function to create date components
        func createDate(year: Int, month: Int, day: Int) -> Date {
            let components = DateComponents(year: year, month: month, day: day)
            return calendar.date(from: components) ?? Date()
        }
        
        return [
            // Night of Ascension
            GreatingDaysModel(
                id: 2001,
                name: "Night of Ascension",
                date: createDate(year: 2026, month: 1, day: 15)
            ),
            
            // Night of Forgiveness
            GreatingDaysModel(
                id: 2002,
                name: "Night of Forgiveness",
                date: createDate(year: 2026, month: 2, day: 2)
            ),
            
            // Beginning of Ramadan
            GreatingDaysModel(
                id: 2003,
                name: "Beginning of Ramadan",
                date: createDate(year: 2026, month: 2, day: 19)
            ),
            
            // Night of Power
            GreatingDaysModel(
                id: 2004,
                name: "Night of Power",
                date: createDate(year: 2026, month: 3, day: 16)
            ),
            
            // Eve of Eid al-Fitr
            GreatingDaysModel(
                id: 2005,
                name: "Eve of Eid al-Fitr",
                date: createDate(year: 2026, month: 3, day: 19)
            ),
            
            // Eid al-Fitr (Day 1)
            GreatingDaysModel(
                id: 2006,
                name: "Eid al-Fitr (Day 1)",
                date: createDate(year: 2026, month: 3, day: 20)
            ),
            
            // Eid al-Fitr (Day 2)
            GreatingDaysModel(
                id: 2007,
                name: "Eid al-Fitr (Day 2)",
                date: createDate(year: 2026, month: 3, day: 21)
            ),
            
            // Eid al-Fitr (Day 3)
            GreatingDaysModel(
                id: 2008,
                name: "Eid al-Fitr (Day 3)",
                date: createDate(year: 2026, month: 3, day: 22)
            ),
            
            // Eve of Eid al-Adha
            GreatingDaysModel(
                id: 2009,
                name: "Eve of Eid al-Adha",
                date: createDate(year: 2026, month: 5, day: 26)
            ),
            
            // Eid al-Adha (Day 1)
            GreatingDaysModel(
                id: 2010,
                name: "Eid al-Adha (Day 1)",
                date: createDate(year: 2026, month: 5, day: 27)
            ),
            
            // Eid al-Adha (Day 2)
            GreatingDaysModel(
                id: 2011,
                name: "Eid al-Adha (Day 2)",
                date: createDate(year: 2026, month: 5, day: 28)
            ),
            
            // Eid al-Adha (Day 3)
            GreatingDaysModel(
                id: 2012,
                name: "Eid al-Adha (Day 3)",
                date: createDate(year: 2026, month: 5, day: 29)
            ),
            
            // Eid al-Adha (Day 4)
            GreatingDaysModel(
                id: 2013,
                name: "Eid al-Adha (Day 4)",
                date: createDate(year: 2026, month: 5, day: 30)
            ),
            
            // Islamic New Year
            GreatingDaysModel(
                id: 2014,
                name: "Islamic New Year",
                date: createDate(year: 2026, month: 6, day: 16)
            ),
            
            // Day of Ashura
            GreatingDaysModel(
                id: 2015,
                name: "Day of Ashura",
                date: createDate(year: 2026, month: 6, day: 25)
            ),
            
            // Prophet's Birthday
            GreatingDaysModel(
                id: 2016,
                name: "Prophet's Birthday",
                date: createDate(year: 2026, month: 8, day: 24)
            ),
            
            // Beginning of Three Holy Months
            GreatingDaysModel(
                id: 2017,
                name: "Beginning of Three Holy Months",
                date: createDate(year: 2026, month: 12, day: 10)
            ),
            
            // Ragaib Night
            GreatingDaysModel(
                id: 2018,
                name: "Ragaib Night",
                date: createDate(year: 2026, month: 12, day: 10)
            )
        ]
    }
    
    /// Returns estimated Islamic special days for years beyond 2026
    private static func getEstimatedDaysForYear(_ year: Int) -> [GreatingDaysModel] {
        let calendar = Calendar.current
        
        // Helper function to create date components
        func createDate(year: Int, month: Int, day: Int) -> Date {
            let components = DateComponents(year: year, month: month, day: day)
            return calendar.date(from: components) ?? Date()
        }
        
        // For years beyond 2026, we use estimated dates based on the fact that
        // Islamic calendar shifts approximately 11 days earlier each solar year
        let shiftDays = (year - 2026) * 11
        
        // Function to shift dates
        func shiftDate(month: Int, day: Int) -> (month: Int, day: Int) {
            let originalDate = createDate(year: 2026, month: month, day: day)
            let shiftedDate = Calendar.current.date(byAdding: .day, value: -shiftDays, to: originalDate) ?? originalDate
            let components = Calendar.current.dateComponents([.month, .day], from: shiftedDate)
            return (components.month ?? month, components.day ?? day)
        }
        
        // Base events from 2026 with dates adjusted
        let mirac = shiftDate(month: 1, day: 15)
        let berat = shiftDate(month: 2, day: 2)
        let ramazanStart = shiftDate(month: 2, day: 19)
        let kadir = shiftDate(month: 3, day: 16)
        let ramazanBayram = shiftDate(month: 3, day: 20)
        let kurbanBayram = shiftDate(month: 5, day: 27)
        let hicriYilbasi = shiftDate(month: 6, day: 16)
        let asure = shiftDate(month: 6, day: 25)
        let mevlid = shiftDate(month: 8, day: 24)
        let ucAylar = shiftDate(month: 12, day: 10)
        
        return [
            // Beginning of Three Holy Months (estimated)
            GreatingDaysModel(
                id: year * 1000 + 1,
                name: "Beginning of Three Holy Months",
                date: createDate(year: year, month: ucAylar.month, day: ucAylar.day)
            ),
            
            // Ragaib Night (estimated)
            GreatingDaysModel(
                id: year * 1000 + 2,
                name: "Ragaib Night",
                date: createDate(year: year, month: ucAylar.month, day: ucAylar.day)
            ),
            
            // Night of Ascension (estimated)
            GreatingDaysModel(
                id: year * 1000 + 3,
                name: "Night of Ascension",
                date: createDate(year: year, month: mirac.month, day: mirac.day)
            ),
            
            // Night of Forgiveness (estimated)
            GreatingDaysModel(
                id: year * 1000 + 4,
                name: "Night of Forgiveness",
                date: createDate(year: year, month: berat.month, day: berat.day)
            ),
            
            // Beginning of Ramadan (estimated)
            GreatingDaysModel(
                id: year * 1000 + 5,
                name: "Beginning of Ramadan",
                date: createDate(year: year, month: ramazanStart.month, day: ramazanStart.day)
            ),
            
            // Night of Power (estimated)
            GreatingDaysModel(
                id: year * 1000 + 6,
                name: "Night of Power",
                date: createDate(year: year, month: kadir.month, day: kadir.day)
            ),
            
            // Eid al-Fitr (estimated)
            GreatingDaysModel(
                id: year * 1000 + 7,
                name: "Eid al-Fitr",
                date: createDate(year: year, month: ramazanBayram.month, day: ramazanBayram.day)
            ),
            
            // Eid al-Adha (estimated)
            GreatingDaysModel(
                id: year * 1000 + 8,
                name: "Eid al-Adha",
                date: createDate(year: year, month: kurbanBayram.month, day: kurbanBayram.day)
            ),
            
            // Islamic New Year (estimated)
            GreatingDaysModel(
                id: year * 1000 + 9,
                name: "Islamic New Year",
                date: createDate(year: year, month: hicriYilbasi.month, day: hicriYilbasi.day)
            ),
            
            // Day of Ashura (estimated)
            GreatingDaysModel(
                id: year * 1000 + 10,
                name: "Day of Ashura",
                date: createDate(year: year, month: asure.month, day: asure.day)
            ),
            
            // Prophet's Birthday (estimated)
            GreatingDaysModel(
                id: year * 1000 + 11,
                name: "Prophet's Birthday",
                date: createDate(year: year, month: mevlid.month, day: mevlid.day)
            )
        ]
    }
}
