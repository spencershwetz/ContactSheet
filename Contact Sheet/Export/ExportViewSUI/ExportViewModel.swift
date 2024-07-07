//
//  ExportViewModel.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 25/06/24.
//

import Foundation
import SwiftUI
import Combine
import PDFKit

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
    
    @Published var isInitialSetUp: Bool = true

    @Published var numberOfSheets: Int = 1
    @Published var selectedPage: Int = 0
    @Published var isSaving: Bool = false
    @Published var showSuccessAlert: Bool = false

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
///        Publishers.CombineLatest($rowStepper, $columnStepper)
///            .sink { [weak self] row, column in self?.recalculatePages(row: row, column: column) }
///            .store(in: &subscriptions)

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
        isInitialSetUp = false
    }

    func recalculatePages(row: Int, column: Int) {
        guard !isInitialSetUp else { return }
        let imagePerPage = row * column
        self.numberOfSheets = Int(ceil(Double(Double(self.selectedImages.count)/Double(imagePerPage))))
        withAnimation {
            self.selectedProject.totalColumns = self.columnStepper
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

extension ExportViewModel {
    func exportPages(completion: (() -> ())?) {
        guard isSaving == false else { return }
        ///Adding a 0.5 second delay for the images gets rendered correctly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let images: [UIImage] = self.pageSnapshot.sorted(by: {$0.key < $1.key}).compactMap { dict in
                return dict.value
            }
            if self.selectedExportType == .JPEG {
                /**for image in images {
                    usleep(200000)
                    ///                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    ContactSheetPhotoAlbum.sharedInstance.saveImage(image: image){}
                }*/
                self.shareImagesWithName(images, name: self.selectedProject.title)
//                completion?()
            } else {
                let pdf = images.makePDF()
                self.sharePDFWithName(pdf, name: self.selectedProject.title)

            }
            self.isSaving = false
            self.pageSnapshot = [:]
        }
    }

    func sharePDF(_ filePDF: PDFDocument) {
        if let pdfData = filePDF.dataRepresentation() {
            let objectsToShare = [pdfData]

            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            if let keyWindow = UIApplication.keyWindow {
                keyWindow.rootViewController?.present(activityVC, animated: true, completion: {})
            }
        }
    }
    func sharePDFWithName(_ filePDF: PDFDocument, name: String) {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "\(name).pdf"
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        print(temporaryFileURL.path)
            filePDF.write(to: temporaryFileURL)
            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            if let keyWindow = UIApplication.keyWindow {
                keyWindow.rootViewController?.present(activityViewController, animated: true, completion: {})
            }
    }

    func shareImagesWithName(_ images: [UIImage], name: String) {
//        let activityViewController = UIActivityViewController(activityItems: [images.first!, name], applicationActivities: nil)
        let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        if let keyWindow = UIApplication.keyWindow {
            keyWindow.rootViewController?.present(activityViewController, animated: true, completion: {})
        }
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

extension Array where Element: UIImage {

    func makePDF() -> PDFDocument {
        let pdfDocument = PDFDocument()
        for (index,image) in self.enumerated() {
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: index)
        }
        return pdfDocument
    }

}
