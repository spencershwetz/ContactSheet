//
//  ExportViewModel.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 25/06/24.
//

import Foundation
import SwiftUI
import Combine

final class ExportViewModel: ObservableObject {

    var selectedProject: Project = .empty()

    @Published var selectedImages: [UIImage?] = []
    @Published var bgColor: Color = Color.black
    @Published var titleColor: Color = Color.white
    @Published var selectedColor: Color = Color.red
    @Published var selectedColorType: SelectedColor = .Background
    @Published var selectedExportType: SelectedExportType = .PDF

    @Published var rowStepper: Int = 6
    @Published var columnStepper: Int = 1
    
    @Published var numberOfSheets: Int = 1
    @Published var selectedPage: Int = 0
    
    @Published var pageSnapshot: [Int: UIImage] = [:]

    @Published var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8)
    ]

    enum SelectedColor {
        case Background
        case Title
    }

    enum SelectedExportType: String, CaseIterable {
        case PDF
        case JPEG
    }

    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($rowStepper, $columnStepper)
            .sink { [weak self] row, column in self?.recalculatePages(row: row, column: column) }
            .store(in: &subscriptions)
        
        $selectedColor
            .dropFirst()
            .sink { [weak self] in
                guard let self else { return }
                switch selectedColorType {
                case .Background: bgColor = $0
                case .Title: titleColor = $0
                }
            }
            .store(in: &subscriptions)
    }
    
    func fetchAllImages() {
        let imageIds: [String] = self.selectedProject.photos.compactMap({$0.assetIdentifier}).filter({!($0.isEmpty)})
        for imageId in imageIds {
            PhotoAssetStore.shared.getImageWithLocalId(identifier: imageId) { image in
                self.selectedImages.append(image)
            }
        }
    }
}

extension ExportViewModel {
    func setSteppers() {
        rowStepper = min(6, selectedProject.totalRows)
        columnStepper = min(6, selectedProject.totalColumns)
        columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: columnStepper)
    }

    func recalculatePages(row: Int, column: Int) {
        let imagePerPage = row * column
        self.numberOfSheets = Int(ceil(Double(Double(self.selectedImages.count)/Double(imagePerPage))))
        withAnimation {
            self.selectedProject.totalColumns = self.columns.count
            self.selectedProject.totalRows = Int(self.selectedImages.count / self.columns.count) + 1
        }
    }

    func getArrayForPage(index: Int) -> [UIImage?] {
        let pageNo = index + 1
        let maxImagePerPage: Int = self.columnStepper * self.rowStepper
        var images: [UIImage?] = []
        for i in index * maxImagePerPage..<maxImagePerPage * pageNo {
            if i < selectedImages.count {
                images.append(selectedImages[i])
            }
        }
        return images
    }
}

private extension Project {

    static func empty() -> Project {
        Project(
            id: UUID(),
            pageSizeRatio: .init(width: 0, height: 0),
            photoAspectRatio: .init(width: 0, height: 0),
            totalRows: 0,
            totalColumns: 0,
            photos: [],
            title: ""
        )
    }
}
