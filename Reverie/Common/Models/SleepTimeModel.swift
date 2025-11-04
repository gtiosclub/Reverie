//
//  SleepTimeModel.swift
//  Reverie
//
//  Created by Anoushka Gudla on 10/28/25.
//
import Foundation

class SleepTime {
    var bedtime: Date
    var wakeUpTime: Date
    
    init(bedtime: Date, wakeUpTime: Date) {
        self.bedtime = bedtime
        self.wakeUpTime = wakeUpTime
    }
    
    var duration: TimeInterval {
        return wakeUpTime.timeIntervalSince(bedtime)
    }
    
    func bedtimeTime() -> Date {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return bedtime
    }
    
    func wakeUpTimeTime() -> Date {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return wakeUpTime
    }
    
    func formattedTimeRange() -> DateInterval {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return DateInterval(start: bedtime,end: wakeUpTime)
    }
    
}
