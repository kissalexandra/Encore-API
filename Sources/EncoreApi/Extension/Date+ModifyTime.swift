//
//  Date+ModifyTime.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Foundation

extension DateComponents {
    static func years(_ value: Int) -> Self {
        Self(year: value)
    }
    static func months(_ value: Int) -> Self {
        Self(month: value)
    }
    static func weeks(_ value: Int) -> Self {
        Self(weekOfYear: value)
    }
    static func days(_ value: Int) -> Self {
        Self(day: value)
    }
    static func hours(_ value: Int) -> Self {
        Self(hour: value)
    }
    static func minutes(_ value: Int) -> Self {
        Self(minute: value)
    }
    static func seconds(_ value: Int) -> Self {
        Self(second: value)
    }

    static prefix func - (components: Self) -> Self {
        var result: Self = components
        result.year = components.year.map {
            -$0
        }
        result.month = components.month.map {
            -$0
        }
        result.weekOfYear = components.weekOfYear.map {
            -$0
        }
        result.day = components.day.map {
            -$0
        }
        result.hour = components.hour.map {
            -$0
        }
        result.minute = components.minute.map {
            -$0
        }
        result.second = components.second.map {
            -$0
        }
        result.nanosecond = components.nanosecond.map {
            -$0
        }
        return result
    }
}

extension Date {
    static func +(date: Self, components: DateComponents) -> Self {
        Calendar.current.date(byAdding: components, to: date) ?? date
    }

    static func -(date: Self, components: DateComponents) -> Self {
        date + -components
    }

    static func +=(date: inout Self, components: DateComponents) {
        date = date + components
    }

    static func -=(date: inout Self, components: DateComponents) {
        date = date - components
    }
}
