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
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = .gray

    }
    var body: some View {
        VStack {
            VStack(spacing: 12) {
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
            }
            StepperView()
            SheetView()
            Spacer()
        }
        .actionSheet(isPresented: $exportVM.showActionSheet, content: {
            ActionSheet(title: Text("Export type"),
                        message: Text("Choose a export type"),
                        buttons: [
                            .default(Text("PDF")) {
                                print("Tapped on PDF export")
                            },
                            .default(Text("Image")) {
                                print("Tapped on Image export")
                            },
                            .cancel()
                        ])
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ExportImage")), perform: { _ in
            self.exportVM.showActionSheet.toggle()
        })        .onAppear {
            self.exportVM.recalculatePages()
        }
        .onChange(of: [self.exportVM.rowStepper, self.exportVM.columnStepper], perform: { value in
            self.exportVM.recalculatePages()
        })
        .onChange(of: self.exportVM.selectedColor) { value in
            if self.exportVM.selectedColorType == .Background {
     
                self.exportVM.bgColor = self.exportVM.selectedColor
            } else {
                self.exportVM.titleColor = self.exportVM.selectedColor
            }
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .background {
            ColorPicker(selection: $exportVM.selectedColor, label: {
                Text("")
                    .font(.title3)
            })
            .labelsHidden().opacity(0)
        }
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
    func ColorPickerCell(title: String, type: ExportViewModel.SelectedColor, color: Binding<Color>) -> some View {
        HStack {
            Text(title)
                .font(.title2)
            Circle()
                .fill(color.wrappedValue)
                .frame(width: 30, height: 30, alignment: .center)
                .overlay {
                    Circle()
                        .stroke(lineWidth: 2)
                }
                .onTapGesture {
                    self.exportVM.selectedColorType = type
                    UIColorWellHelper.helper.execute?()
                }
                .frame(width: 70)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

extension ExportView {
    func FileFormatView() -> some View {
        HStack {
            Text("File Format: ")
                .font(.title2)

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
            .frame(width: 70)



        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

///`StepperView`
extension ExportView {
    func StepperView() -> some View {
        HStack {
            VStack {
                Text("Rows \(exportVM.rowStepper)")
                    .font(.title2)

                Stepper("", value: $exportVM.rowStepper, in: 1...6)
                    .fixedSize()
            }
            Spacer()
            VStack {

                Text("Columns \(exportVM.columnStepper)")
                    .font(.title2)

                Stepper("", value: $exportVM.columnStepper, in: 1...6)
                    .fixedSize()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

///`SheetView`
extension ExportView {
    func SheetView() -> some View {
        TabView(selection: $exportVM.selectedPage) {
            ForEach(0..<exportVM.numberOfSheets, id: \.self) { i in
                ExportSheetCell(exportVM: exportVM, currentPage: .constant(i)) { snapShot in
                    self.exportVM.pageSnapshot[i] = snapShot
                }
                    .tag(i)
                    .frame(maxHeight: UIScreen.main.bounds.height / 2)
                    .id(i)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(maxHeight: UIScreen.main.bounds.height / 2 + 50)
    }
}
