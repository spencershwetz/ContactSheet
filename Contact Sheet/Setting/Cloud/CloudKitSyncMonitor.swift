//
//  CloudKitSyncMonitor.swift
//  Contact Sheet
//
//  Created by Windy on 08/03/24.
//

import Combine
import CoreData

final class CloudKitSyncMonitor: ObservableObject {

    static let shared = CloudKitSyncMonitor()

    @Published var lastSyncDate: String = ""
    fileprivate var disposables = Set<AnyCancellable>()

    @Published var usedContainerForiCloud: String = ""
    @Published var usedContainerForiCloudLog: String = ""
    @Published var cloudEventsList: [EventLogger] = []


    private var subscriptions = Set<AnyCancellable>()

    func setupObserver() {
        NotificationCenter.default
            .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .map { $0.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] }
            .compactMap { $0 as? NSPersistentCloudKitContainer.Event }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                if event.succeeded {
                    self?.lastSyncDate = event.endDate?.formattedHourFormat ?? ""
                }
            }
            .store(in: &subscriptions)
    }
}

private extension Date {

    var formattedHourFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
    }

    var fullDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter.string(from: self)
    }
}


extension CloudKitSyncMonitor {
    struct EventLogger: Equatable {
        var event: NSPersistentCloudKitContainer.EventType
        var startString: String
        var endString: String
        var finalSuccessString: String
        var errorString: String?
        var atDate: Date
        var visibleLocalString: String {
            atDate.fullDate
        }

        init(
            event: NSPersistentCloudKitContainer.EventType = .setup,
            startString: String = "",
            endString: String = "",
            finalSuccessString: String = "",
            errorString: String? = nil,
            atDate: Date = Date()
        ) {
            self.event = event
            self.startString = startString
            self.endString = endString
            self.finalSuccessString = finalSuccessString
            self.errorString = errorString
            self.atDate = atDate
        }
    }
}
