//
//  ErrorHandler.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/08.
//

import Foundation
#if DEBUG
import OSLog
#endif

final class ErrorHandler: ObservableObject {
    static let shared: ErrorHandler = .init()
    
    @Published var appError: ErrorType? = nil
    @Published var showAlert: Bool = false
    
    func dropError() {
        appError = nil
        showAlert = false
    }
}

struct ErrorType: Identifiable, Equatable {
    let id: UUID = .init()
    let errorDescription: String
    let failureReason: String
    let recoverySuggestion: String
    let helpAnchor: String
    var createIssue: Bool = true
    
    init(error: Error) {
        self.errorDescription = String(
            format: NSLocalizedString("Unknown error: %@", comment: "Unexpected error description"),
            error.localizedDescription
        )
        self.failureReason = error.localizedDescription
        self.recoverySuggestion = NSLocalizedString("Please submit a bug report and try to restart the app", comment: "")
        self.helpAnchor = ""
    }
    
    init(_ localizedError: LocalizedError) {
        self.errorDescription = localizedError.errorDescription ?? ""
        self.failureReason = localizedError.failureReason ?? ""
        self.recoverySuggestion = localizedError.recoverySuggestion ?? ""
        self.helpAnchor = localizedError.helpAnchor ?? ""
    }
    
    init(_ urlError: URLError) {
        switch urlError {
        case URLError(.badURL):
            self.errorDescription = NSLocalizedString("Can't reach requested URL", comment: "")
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = NSLocalizedString("Try to restart the app", comment: "")
            self.helpAnchor = ""
            
        case URLError(.badServerResponse):
            self.errorDescription = NSLocalizedString("Squirrel servers did not response correctly", comment: "")
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = NSLocalizedString("Try to restart the app", comment: "")
            self.helpAnchor = ""
            
        case URLError(.notConnectedToInternet):
            self.errorDescription = urlError.localizedDescription
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = NSLocalizedString("Check your internet connection", comment: "")
            self.helpAnchor = ""
            self.createIssue = false
            
        default:
            self.errorDescription = urlError.localizedDescription
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = NSLocalizedString("Try to restart the app", comment: "")
            self.helpAnchor = ""
        }
    }
    
    init(errorDescription: String, failureReason: String, recoverySuggestion: String, helpAnchor: String = "") {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
        self.helpAnchor = helpAnchor
        self.createIssue = false
    }
    
    func publish(file: String? = nil, function: String? = nil) {
        #if DEBUG
        let fileString = file != nil ? ", in file \(file ?? "")" : ""
        let funcString = function != nil ? ", in function \(function ?? "")" : ""
        let logger = Logger(subsystem: Vars.appIdentifier, category: "errors")
        logger.error("Failure reason: \(self.failureReason)\(fileString)\(funcString), occured at \(Date.now.formatted(date: .numeric, time: .standard))")
        #endif
        
        ErrorHandler.shared.appError = self
        ErrorHandler.shared.showAlert = true
        HapticManager.shared.notification(.error)
    }
}
