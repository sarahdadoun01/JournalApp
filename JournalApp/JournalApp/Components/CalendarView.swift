//
//  CalendarView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-08.
//

import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable {
    
    @Binding var selectedDate: Date
    var entries: [Date: Int]

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16)
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context){
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        
        var parent: CalendarView
        
        init(_ parent: CalendarView){
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            return parent.entries[date] ?? 0
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
        
    }
}

struct CalendarView_Previews: PreviewProvider {
    
    @State static var previewDate = Date()
    
    static var previews: some View {
        CalendarView(selectedDate: $previewDate, entries: sampleEntries)
    }
    
    static let sampleEntries: [Date: Int] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd"
        
        return [
            formatter.date(from: "2025-03-06")!: 2, // 2 entries on this day
            formatter.date(from: "2025-03-07")!: 3, // 3 entries on this day
            formatter.date(from: "2025-03-08")!: 1 // 1 entries on this day
        ]
    }()
}
