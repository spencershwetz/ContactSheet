//
//  CloudSyncHistoryView.swift
//  SwipePhoto
//
//  Created by Jaymeen Unadkat on 06/04/24.
//

import SwiftUI


///`CloudSyncHistoryViewController`
final class CloudSyncHistoryViewController: UIViewController {

    private let store = ProjectStore.shared

    init() {
        UIScrollView.appearance().bounces = false
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        addCloudHistoryView()
    }
}

#Preview(body: {
    return makeCloudHistoryController().asPreview()

    func makeCloudHistoryController() -> UIViewController {
        let vc = CloudSyncHistoryViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.prefersLargeTitles = true
        vc.title = "Export"
        return navigationController
    }
})


extension CloudSyncHistoryViewController {
    /// Adding the CloudHistory SwiftUI view as a hosting controller
    func addCloudHistoryView() {
        let controller = UIHostingController(rootView: CloudSyncHistoryView())
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.didMove(toParent: self)
        view.addSubview(controller.view, constraint: .fill)
    }
}



struct CloudSyncHistoryView: View {
    @StateObject var syncMonitor: CloudKitSyncMonitor = .shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Text("icloud sync history")
                    .font(.system(size: 28, weight: .bold))
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

//#Preview {
//    CloudSyncHistoryView()
//}

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
