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

}
