//
//  CropPresenter.swift
//  Contact Sheet
//
//  Created by Windy on 26/06/24.
//

import UIKit
import Mantis

final class CropPresenter {

    private var onCropped: ((UIImage) -> Void)?

    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func show(
        image: UIImage,
        ratio: Ratio,
        onCropped: @escaping (UIImage) -> Void
    ) {
        self.onCropped = onCropped

        let cropViewController = Mantis.cropViewController(image: image)
        cropViewController.config.showRotationDial = false
        cropViewController.config.ratioOptions = [.custom]
        cropViewController.config.addCustomRatio(
            byVerticalWidth: Int(ratio.width),
            andVerticalHeight: Int(ratio.height)
        )
        cropViewController.config.cropToolbarConfig.toolbarButtonOptions = .ratio
        cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(
            ratio: ratio.width / ratio.height)
        cropViewController.delegate = self

        viewController?.present(cropViewController, animated: true)
    }
}

extension CropPresenter: CropViewControllerDelegate {

    func cropViewControllerDidCrop(
        _ cropViewController: Mantis.CropViewController,
        cropped: UIImage,
        transformation: Mantis.Transformation,
        cropInfo: Mantis.CropInfo
    ) {
        onCropped?(cropped)
        cropViewController.dismiss(animated: true)
    }

    func cropViewControllerDidCancel(
        _ cropViewController: Mantis.CropViewController,
        original: UIImage
    ) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidFailToCrop(
        _ cropViewController: Mantis.CropViewController,
        original: UIImage
    ) {}

    func cropViewControllerDidBeginResize(
        _ cropViewController: Mantis.CropViewController
    ) {}

    func cropViewControllerDidEndResize(
        _ cropViewController: Mantis.CropViewController,
        original: UIImage,
        cropInfo: Mantis.CropInfo
    ) {}
}
