//
//  TemplateData.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/03.
//

import Foundation

extension CoreDataModel {
    func addTemplateData() {
        context.perform { [weak self] in
            guard let self else { return }
            
            let restaurantsID = addCategory(name: String(localized: "Restaurants", comment: "Sample data category"), color: "nord1")?.id ?? .init()
            let groceriesID = addCategory(name: String(localized: "Groceries", comment: "Sample data category"), color: "nord4")?.id ?? .init()
            let subscriptionsID = addCategory(name: String(localized: "Subscriptions", comment: "Sample data category"), color: "nord6")?.id ?? .init()
            let transportID = addCategory(name: String(localized: "Transport", comment: "Sample data category"), color: "nord94")?.id ?? .init()
            let travelID = addCategory(name: String(localized: "Travel", comment: "Sample data category"), color: "nord7")?.id ?? .init()
            
            let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            
            func getDate(days: Int) -> Date {
                var localComponents = components
                localComponents.calendar = .current
                localComponents.day = (localComponents.day ?? 1) - days
                localComponents.hour = (8...23).randomElement() ?? 6
                localComponents.minute = (0..<60).randomElement() ?? 24
                return localComponents.date ?? Date()
            }
            
            let restaurantsSpendings: [SpendingEntityLocal] = [
                .init(amount: 10, amountUSD: 10, currency: "USD", date: getDate(days: 4), place: String(localized: "Food Delivery", comment: "Sample data place"), categoryId: restaurantsID, comment: ""),
                .init(amount: 15, amountUSD: 15, currency: "USD", date: getDate(days: 5), place: String(localized: "Fast Food", comment: "Sample data place"), categoryId: restaurantsID, comment: ""),
                .init(amount: 10, amountUSD: 10, currency: "USD", date: getDate(days: 7), place: String(localized: "Restaurant", comment: "Sample data place"), categoryId: restaurantsID, comment: ""),
                .init(amount: 12, amountUSD: 12, currency: "USD", date: getDate(days: 12), place: String(localized: "Some Restaurant", comment: "Sample data place"), categoryId: restaurantsID, comment: ""),
                .init(amount: 9, amountUSD: 9, currency: "USD", date: getDate(days: 13), place: String(localized: "Fast Food", comment: "Sample data place"), categoryId: restaurantsID, comment: ""),
                .init(amount: 22, amountUSD: 22, currency: "USD", date: getDate(days: 28), place: String(localized: "Some Restaurant", comment: "Sample data place"), categoryId: restaurantsID, comment: ""),
                .init(amount: 15, amountUSD: 15, currency: "USD", date: getDate(days: 37), place: String(localized: "Pizza Place", comment: "Sample data place"), categoryId: restaurantsID, comment: "")
            ]
            
            let groceriesSpendings: [SpendingEntityLocal] = [
                .init(amount: 1500, amountUSD: 10, currency: "JPY", date: Date(), place: String(localized: "Shop at Tokyo Airport", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 15, amountUSD: 15, currency: "USD", date: getDate(days: 3), place: String(localized: "Grocery Store", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 3.90, amountUSD: 3.90, currency: "USD", date: getDate(days: 5), place: String(localized: "Grocery Store", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 25, amountUSD: 25, currency: "USD", date: getDate(days: 12), place: String(localized: "Supermarket", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 2.50, amountUSD: 2.50, currency: "USD", date: getDate(days: 20), place: String(localized: "Supermarket", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 18, amountUSD: 18, currency: "USD", date: getDate(days: 23), place: String(localized: "Grocery Store", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 1.99, amountUSD: 1.99, currency: "USD", date: getDate(days: 28), place: String(localized: "Grocery Store", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 16, amountUSD: 16, currency: "USD", date: getDate(days: 35), place: "", categoryId: groceriesID, comment: ""),
                .init(amount: 35, amountUSD: 35, currency: "USD", date: getDate(days: 44), place: String(localized: "Supermarket", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
                .init(amount: 12, amountUSD: 12, currency: "USD", date: getDate(days: 51), place: "", categoryId: groceriesID, comment: ""),
                .init(amount: 7.70, amountUSD: 7.70, currency: "USD", date: getDate(days: 60), place: String(localized: "Grocery Store", comment: "Sample data place"), categoryId: groceriesID, comment: ""),
            ]
            
            let subscriptionsSpendings: [SpendingEntityLocal] = [
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 1), place: String(localized: "Music", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 11), place: String(localized: "Cloud Storage", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 2), place: String(localized: "Mobile network", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 31), place: String(localized: "Music", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 42), place: String(localized: "Cloud Storage", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 33), place: String(localized: "Mobile network", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 62), place: String(localized: "Music", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 72), place: String(localized: "Cloud Storage", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 64), place: String(localized: "Mobile network", comment: "Sample data place"), categoryId: subscriptionsID, comment: ""),
            ]
            
            let transportSpendings: [SpendingEntityLocal] = [
                .init(amount: 1000, amountUSD: 6.30, currency: "JPY", date: getDate(days: 1), place: String(localized: "Taxi", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 4), place: String(localized: "Subway", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 5, amountUSD: 5, currency: "USD", date: getDate(days: 6), place: String(localized: "Taxi", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 10), place: String(localized: "Bus", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 20), place: String(localized: "Subway", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 25), place: String(localized: "Bus", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 32), place: String(localized: "Bus", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 41), place: String(localized: "Subway", comment: "Sample data place"), categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 50), place: String(localized: "Subway", comment: "Sample data place"), categoryId: transportID, comment: ""),
            ]
            
            let travelSpendings: [SpendingEntityLocal] = [
                .init(amount: 39500, amountUSD: 150, currency: "JPY", date: getDate(days: 9), place: String(localized: "Plane tickets", comment: "Sample data place"), categoryId: travelID, comment: ""),
                .init(amount: 130, amountUSD: 130, currency: "USD", date: getDate(days: 78), place: String(localized: "Train tickets", comment: "Sample data place"), categoryId: travelID, comment: "")
            ]
            
            for spending in restaurantsSpendings {
                if spending.currency == "JPY" {
                    addSpending(spending: spending, timeZoneIdentifier: "Asia/Tokyo", playHaptic: false)
                } else {
                    addSpending(spending: spending, timeZoneIdentifier: "America/New_York", playHaptic: false)
                }
//                addSpending(spending: spending, timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier, playHaptic: false)
            }
            
            for spending in groceriesSpendings {
                if spending.currency == "JPY" {
                    addSpending(spending: spending, timeZoneIdentifier: "Asia/Tokyo", playHaptic: false)
                } else {
                    addSpending(spending: spending, timeZoneIdentifier: "America/New_York", playHaptic: false)
                }
//                addSpending(spending: spending, timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier, playHaptic: false)
            }
            
            for spending in subscriptionsSpendings {
                if spending.currency == "JPY" {
                    addSpending(spending: spending, timeZoneIdentifier: "Asia/Tokyo", playHaptic: false)
                } else {
                    addSpending(spending: spending, timeZoneIdentifier: "America/New_York", playHaptic: false)
                }
//                addSpending(spending: spending, timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier, playHaptic: false)
            }
            
            for spending in transportSpendings {
                if spending.currency == "JPY" {
                    addSpending(spending: spending, timeZoneIdentifier: "Asia/Tokyo", playHaptic: false)
                } else {
                    addSpending(spending: spending, timeZoneIdentifier: "America/New_York", playHaptic: false)
                }
//                addSpending(spending: spending, timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier, playHaptic: false)
            }
            
            for spending in travelSpendings {
                addSpending(spending: spending, timeZoneIdentifier: "America/New_York", playHaptic: false)
            }
        }
        
        HapticManager.shared.notification(.success)
    }
}
