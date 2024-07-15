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
    var height: Double
    var isRendering: Bool
    @Binding var currentPage: Int
    var renderedImage: ((_ image: UIImage) -> ())?
    var body: some View {
        cellBody
            .onReceive(NotificationCenter.default.publisher(for: .renderImage), perform: { _ in
                if let image = cellBody.snapshot(withBackgroundColor: self.exportVM.bgColor) {
                    renderedImage?(image)
                }
            })
            .onChange(of: self.exportVM.columnStepper, perform: { value in
                withAnimation {
                    self.exportVM.columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: self.exportVM.columnStepper)
                }
            })
            .background(self.exportVM.bgColor)
        
        .frame(height: height)
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
    ExportSheetCell(
        exportVM: ExportViewModel(),
        height: 0,
        isRendering: true,
        currentPage: .constant(0)
    )
}

extension ExportSheetCell {
    var cellBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exportVM.selectedProject.title)
                .font(.title)
                .bold()
                .foregroundStyle(exportVM.titleColor)
                .padding(.horizontal, 6)

            gridImages

            if exportVM.isShowColorBar {
                HStack(spacing: 0) {
                    ForEach(exportVM.analyzedColors, id: \.self) {
                        Color(uiColor: $0)
                            .frame(height: 32)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }

    var gridImages: some View {
        GeometryReader { proxy in
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
        .modifier(
            CustomFrameModifier(
                active: isRendering,
                width: UIScreen.main.bounds.width - 24,
                height: height - 96,
                alignment: .topLeading
            )
        )    }
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


struct CustomFrameModifier : ViewModifier {
    var active : Bool
    var width: Double
    var height: Double
    var alignment: SwiftUI.Alignment

    @ViewBuilder func body(content: Content) -> some View {
        if active {
            content.frame(width: width, height: height, alignment: alignment)
        } else {
            content
        }
    }
}
