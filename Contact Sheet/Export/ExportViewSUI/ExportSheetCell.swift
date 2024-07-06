//
//  ExportSheetCell.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 30/06/24.
//

import SwiftUI

///`ExportSheetCell`
struct ExportSheetCell: View {
    @ObservedObject var exportVM: ExportViewModel
    @Binding var currentPage: Int

    var completion: ((_ sheetSnap: UIImage?) -> ())?
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(self.exportVM.selectedProject.title)
                    .font(.title)
                    .bold()
                    .padding(.all, 12)
                    .foregroundStyle(self.exportVM.titleColor)
                    .frame(height: 40)
                    .padding(.bottom, 8)

                GeometryReader { proxy in
                    ScrollView {
                        LazyVGrid(columns: exportVM.columns, spacing: 8) {
                            let arrImages = exportVM.getArrayForPage(index: self.currentPage)
                            ForEach(0..<arrImages.count, id: \.self) { index in
                                ImageCell(viewModel: exportVM, image: arrImages[index])
                                    .frame(
                                        width: max(calculateItemSize(proxy.size, 8), 0),
                                        height: max(calculateItemSize(proxy.size, 8), 0),
                                        alignment: .center
                                    )
                                    .clipped()
                            }
                        }
                    }
                }
            }
            .onChange(of: self.exportVM.columnStepper, perform: { value in
                withAnimation {
                    self.exportVM.columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: self.exportVM.columnStepper)
                }
            })
            .background(self.exportVM.bgColor)
        }
        .border(.primary, width: 1)
    }
    
    private func calculateItemSize(_ size: CGSize, _ spacing: Double) -> CGFloat {
        let numberOfColumn = CGFloat(exportVM.columnStepper)
        let actualWidth = size.width - numberOfColumn * spacing
        let height = calculateItemHeight(size, spacing)
        return actualWidth / numberOfColumn > height ?  height : actualWidth / numberOfColumn
    }

    private func calculateItemHeight(_ size: CGSize, _ spacing: Double) -> CGFloat {
        let numberOfRows = CGFloat(exportVM.rowStepper)
        let actualHeight = size.height - numberOfRows * spacing
        return actualHeight / numberOfRows
    }


}

#Preview {
    ExportSheetCell(exportVM: ExportViewModel(), currentPage: .constant(0))
}

extension ExportSheetCell {
    struct ImageCell: View {
        @StateObject var viewModel: ExportViewModel
        var image: UIImage?

        var body: some View {
            VStack {
                GeometryReader { geo in
                    Image(uiImage: self.image ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: getHeightWidth(totalSize: geo.size).width,
                            height: getHeightWidth(totalSize: geo.size).height,
                            alignment: .center
                        )
                        .clipped()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        func getHeightWidth(totalSize: CGSize) -> (width: Double,height: Double) {
            var width: Double = totalSize.width
            var height: Double = totalSize.height
            if self.viewModel.selectedProject.photoAspectRatio.width > self.viewModel.selectedProject.photoAspectRatio.height {
                height = self.viewModel.selectedProject.photoAspectRatio.height * width / self.viewModel.selectedProject.photoAspectRatio.width
            } else {
                width = self.viewModel.selectedProject.photoAspectRatio.width * height / self.viewModel.selectedProject.photoAspectRatio.height
            }

            return (width, height)
        }
    }
}
