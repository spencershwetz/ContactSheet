//
//  CloudSyncHistoryView.swift
//  SwipePhoto
//
//  Created by Jaymeen Unadkat on 06/04/24.
//

import SwiftUI

struct CloudSyncHistoryView: View {
    @StateObject var syncMonitor: CloudKitSyncMonitor = .shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Text("icloud sync history")
                    .font(.system(size: 20))
                Spacer()
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.backward.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(Color.primary)
                }
            }.frame(height: 100)


            historyList()
        }
        .padding(.horizontal)
        .toolbar(.hidden)
    }
}

#Preview {
    CloudSyncHistoryView()
}

extension CloudSyncHistoryView {
    func historyList() -> some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                
                HStack {
                    Spacer()
                    Button {
                        self.syncMonitor.cloudEventsList.removeAll()
                    } label: {
                        Text("Clear History")
                            .font(.system(size: 20))
                            .underline()
                    }

                }

                Divider()

                VStack(alignment: .leading) {
                    Text("Used container - \(self.syncMonitor.usedContainerForiCloud) ✅")
                    Text("Container Logs - \(self.syncMonitor.usedContainerForiCloudLog)")
                    Divider()
                }


                ForEach(self.syncMonitor.cloudEventsList.sorted(by: {$0.atDate > $1.atDate}), id: \.atDate) { element in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Start - \(element.startString)")
                                Text("End - \(element.endString)")
                                Text("Output - \(element.finalSuccessString)")
                                if let error = element.errorString {
                                    Text("Error - \(error)")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Text(element.visibleLocalString)
                                .multilineTextAlignment(.trailing)
                        }
                        Divider()

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                }
            }
        }
    }
}
