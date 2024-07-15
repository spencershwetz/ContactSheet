//
//  ExportView.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 25/06/24.
//

import SwiftUI
import UIKit

///`ExportView`
struct ExportView: View {
    @ObservedObject private var exportVM: ExportViewModel
    
    init(exportVM: ExportViewModel) {
        self.exportVM = exportVM
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .trailing, spacing: 8) {
                ColorPickerCell(
                    title: "Background Color: ",
                    type: .Background,
                    color: $exportVM.bgColor
                )
                ColorPickerCell(
                    title: "Title Color: ",
                    type: .Title,
                    color: $exportVM.titleColor
                )
                FileFormatView()
                Toggle(isOn: $exportVM.isShowColorBar) {
                    Text("Show color: ")
                        .font(.title3)
                }
                .frame(width: 170)
            }
            StepperView()
            SheetView()
                .background {
                    BackgroundRenderingView()
                }
        }
        .onChange(of: [self.exportVM.rowStepper, self.exportVM.columnStepper], perform: { value in
            self.exportVM.recalculatePages(row: self.exportVM.rowStepper, column: self.exportVM.columnStepper)
        })
        .onAppear {
            exportVM.setSteppers()
            UIView.setAnimationsEnabled(false)
        }
        .padding(.all, 16)
        .background {
            ColorPicker("", selection: $exportVM.selectedColor)
                .labelsHidden()
                .opacity(0)
        }
        .onReceive(NotificationCenter.default.publisher(for: .renderImage), perform: { _ in
            exportVM.exportPages {
                exportVM.showSuccessAlert = true
            }
        })
        .alert(isPresented: $exportVM.showSuccessAlert,
               content: {
            Alert(
                title: Text(""),
                message: Text("Your sheets are stored to image library."),
                dismissButton: .default(Text("OK"))
            )
        })
    }
}

#Preview {
    ExportView(exportVM: ExportViewModel())
}

extension UIColorWell {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let uiButton = self.subviews.first?.subviews.last as? UIButton {
            UIColorWellHelper.helper.execute = {
                uiButton.sendActions(for: .touchUpInside)
            }
        }
    }
}

class UIColorWellHelper: NSObject {
    static let helper = UIColorWellHelper()
    var execute: (() -> ())?
    @objc func handler(_ sender: Any) {
        execute?()
    }
}

///`BackgroundColorView`
extension ExportView {
    func ColorPickerCell(
        title: String,
        type: ExportViewModel.SelectedColor,
        color: Binding<Color>
    ) -> some View {
        HStack {
            Spacer()
            Text(title)
                .font(.title3)
            Circle()
                .fill(color.wrappedValue)
                .frame(width: 24, height: 24)
                .overlay {
                    Circle()
                        .stroke(lineWidth: 1)
                }
                .onTapGesture {
                    self.exportVM.selectedColorType = type
                    UIColorWellHelper.helper.execute?()
                }
        }
    }
}

extension ExportView {
    func FileFormatView() -> some View {
        HStack {
            Spacer()
            
            Text("File Format: ")
                .font(.title3)

            Menu {
                ForEach(ExportViewModel.SelectedExportType.allCases, id: \.rawValue) { type in
                    Button(type.rawValue) {
                        self.exportVM.selectedExportType = type
                    }
                }
            } label: {
                Button(self.exportVM.selectedExportType.rawValue) {

                }
                .font(.system(size: 24, weight: .bold, design: .rounded))
            }
        }
    }
}

///`StepperView`
extension ExportView {
    func StepperView() -> some View {
        HStack {
            VStack {
                Text("Rows \(exportVM.rowStepper)")
                    .font(.title3)
                Stepper("", value: $exportVM.rowStepper, in: 1...20)
                    .fixedSize()
            }
            Spacer()
            VStack {
                Text("Columns \(exportVM.columnStepper)")
                    .font(.title3)
                Stepper("", value: $exportVM.columnStepper, in: 1...20)
                    .fixedSize()
            }
        }
    }
}

///`SheetView`
extension ExportView {
    func SheetView() -> some View {
        GeometryReader { proxy in
            ScrollView {
                TabView(selection: $exportVM.selectedPage) {
                    ForEach(0..<exportVM.numberOfSheets, id: \.self) { i in
                        ExportSheetCell(
                            exportVM: exportVM,
                            height: calculateHeight(width: proxy.size.width),
                            isRendering: false,
                            currentPage: .constant(i)
                        )
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: calculateHeight(width: proxy.size.width))
            }
        }
    }

    private func calculateHeight(width: CGFloat) -> CGFloat {
        let ratio = exportVM.selectedProject.pageSizeRatio
        return width * ratio.height / ratio.width
    }
}

///`BackgroundRenderingView`
extension ExportView {
    func BackgroundRenderingView() -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<exportVM.numberOfSheets, id: \.self) { i in
                    ExportSheetCell(
                        exportVM: exportVM,
                        height: calculateHeight(width: proxy.size.width),
                        isRendering: true,
                        currentPage: .constant(i)
                        , renderedImage: { image in
                            self.exportVM.pageSnapshot[i] = image
                        })
                    .padding(.horizontal, 12)
                    .frame(
                        width: UIScreen.main.bounds.width - 48,
                        height: calculateHeight(width: proxy.size.width),
                        alignment: .topLeading
                    )
                }
            }
            .opacity(0.001)
        }
    }
}

