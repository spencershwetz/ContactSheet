//
//  CloudKitSyncMonitor.swift
//  SwipePhoto
//
//  Created by Windy on 08/03/24.
//

import Combine
import CoreData

final class CloudKitSyncMonitor {
    
    static let shared = CloudKitSyncMonitor()

    @Published var lastSyncDate: String = ""
    
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
}
