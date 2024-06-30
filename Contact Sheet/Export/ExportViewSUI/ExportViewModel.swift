//
//  ExportViewModel.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 25/06/24.
//

import Foundation
import SwiftUI

///ExportViewModel
class ExportViewModel: ObservableObject {

//    @Published var selectedProject: Project!
    @Published var selectedProject: Project = Project(id: UUID(), pageSizeRatio: .init(width: 0, height: 0), photoAspectRatio: .init(width: 0, height: 0), totalRows: 0, totalColumns: 0, photos: [], title: "") 

    @Published var selectedImages: [UIImage?] = []
    @Published var bgColor: Color = Color.black
    @Published var titleColor: Color = Color.white
    @Published var selectedColor: Color = Color.red
    
    @Published var showActionSheet: Bool = false

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
}

extension ExportViewModel {
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
    func recalculatePages() {
        let imagePerPage: Int = self.columnStepper * self.rowStepper
        self.numberOfSheets = Int(ceil(Double(Double(self.selectedImages.count)/Double(imagePerPage))))
    }

    func getArrayForPage(index: Int) -> [UIImage?] {
        let pageNo = index + 1
        let maxImagePerPage: Int = self.columnStepper * self.rowStepper
        var images: [UIImage?] = []
        for i in index * maxImagePerPage..<maxImagePerPage * pageNo {
            if i < selectedImages.count {
                let image = selectedImages[i]
                images.append(selectedImages[i])
            }
        }
        return images
    }
}
