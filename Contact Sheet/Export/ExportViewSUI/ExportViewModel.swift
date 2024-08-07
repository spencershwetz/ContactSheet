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
import UIImageColorRatio

final class ExportViewModel: ObservableObject {

    @Published var selectedProject: Project = .empty()

    @Published var selectedImages: [UIImage?] = []
    @Published var bgColor: Color = Color.black
    @Published var titleColor: Color = Color.white
    @Published var selectedColor: Color = Color.red
    @Published var selectedColorType: SelectedColor = .Background
    @Published var selectedExportType: SelectedExportType = .PDF
    @Published var isShowColorBar = true
    @Published var refreshUI = false

    @Published var rowStepper: Int = 6
    @Published var columnStepper: Int = 1
    
    @Published var isInitialSetUp: Bool = true

    @Published var numberOfSheets: Int = 1
    @Published var selectedPage: Int = 0
    @Published var isSaving: Bool = false
    @Published var showSuccessAlert: Bool = false

    @Published var pageSnapshot: [Int: UIImage] = [:]
    
    @Published var spacingForSheetRows: Double = 8.0

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
    
    @State private(set) var analyzedColors: [UIColor] = []
    
    func fetchAllImages() {
        var imageURLs: [(String?, String?)] = self.selectedProject.photos.map({ ($0.imageURL, $0.editImageURL) }).filter({!(($0.0 ?? "").isEmpty)})
        imageURLs = imageURLs.filter({$0.0 != nil})
        for (imageURL, croppedImageURL) in imageURLs {

            if let croppedImageURL = croppedImageURL, let editImageURL = URL(string: croppedImageURL) {
                ImageLoader.loadImage(from: editImageURL) { [weak self] image in
                    guard let self = self else { return }
                    self.selectedImages.append(image)
                }
            } else {
                guard let imageURL, let imagePathURL = URL(string: imageURL) else { return }

                ImageLoader.loadImage(from: imagePathURL) { [weak self] image in
                    guard let self = self else { return }
                    self.selectedImages.append(image)
                }
            }
        }
        analyzeColors()

    }

    private func analyzeColors() {
        selectedImages.compactMap { $0 }.forEach { value in
            let result = value.calculateColorRatio(deviation: 200)
            let colors = result?.colorRatioArray.map(\.color) ?? []
            analyzedColors += colors
        }
    }
}

extension ExportViewModel {
    func setSteppers() {
        rowStepper = min(20, selectedProject.totalRows)
        columnStepper = min(20, selectedProject.totalColumns)
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
