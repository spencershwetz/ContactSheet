import Foundation
import UIKit

class CloudDataManager {

    static let sharedInstance = CloudDataManager() // Singleton
    var cachedImages: [URL: UIImage] = [:]

    struct DocumentsDirectory {
        static let localDocumentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        static let iCloudDocumentsURL: URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }

    func isCloudEnabled() -> Bool {
        return DocumentsDirectory.iCloudDocumentsURL != nil
    }

    func saveMultipleImages(images: [UIImage], completion: @escaping ([URL?]) -> Void) {
        var urls: [URL] = []
        let dispatchGroup = DispatchGroup()

        for image in images {
            dispatchGroup.enter()
            saveImage(image: image, imageName: "\(UUID().uuidString).png") { url in
                ImageLoader.fetchFilesFromICloud()
                
                if let url = url {
                    print("URL -- \(url)")
                    urls.append(url)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(urls)
        }
    }

    func saveImage(image: UIImage, imageName: String = "\(UUID().uuidString)", completion: @escaping (URL?) -> Void) {
        if isCloudEnabled() {
            saveImageToCloud(image: image, imageName: imageName, completion: completion)
        } else {
            saveImageLocally(image: image, imageName: imageName, completion: completion)
        }
    }

    private func saveImageToCloud(image: UIImage, imageName: String, completion: @escaping (URL?) -> Void) {
        guard let iCloudDocumentsURL = DocumentsDirectory.iCloudDocumentsURL else {
            completion(nil)
            return
        }

        let fileURL = iCloudDocumentsURL.appendingPathComponent(imageName)

        DispatchQueue.global(qos: .background).async {
            if let imageData = image.jpegData(compressionQuality: 0.15) {
                do {
                    try imageData.write(to: fileURL, options: .atomic)
                    completion(fileURL)
                } catch {
                    print("Failed to save image to iCloud: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    private func saveImageLocally(image: UIImage, imageName: String, completion: @escaping (URL?) -> Void) {
        let fileURL = DocumentsDirectory.localDocumentsURL.appendingPathComponent(imageName)

        DispatchQueue.global(qos: .background).async {
            if let imageData = image.jpegData(compressionQuality: 0.15) {
                do {
                    try imageData.write(to: fileURL, options: .atomic)
                    completion(fileURL)
                } catch {
                    print("Failed to save image locally: \(error)")
                    completion(nil)
                    
                }
            } else {
                completion(nil)
            }
        }
    }
}


class ImageLoader {



    static func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
//        DispatchQueue.global(qos: .background).async {
//
//        if url.startAccessingSecurityScopedResource(){
//                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        completion(image)
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        completion(nil)
//                    }
//                }
//            }
//            url.stopAccessingSecurityScopedResource()
//        }


        let localFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent)
        let cloudFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent)

        DispatchQueue.global(qos: .background).async {
            fetchImageForURL(url: localFileURL) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        if CloudDataManager.sharedInstance.cachedImages[localFileURL] == nil {
                            CloudDataManager.sharedInstance.cachedImages[localFileURL] = image
                        }
                    }
                    completion(image)
                } else {
                    fetchImageForURL(url: cloudFileURL) { image in
                        if let image = image {
                            DispatchQueue.main.async {
                                if CloudDataManager.sharedInstance.cachedImages[cloudFileURL] == nil {
                                    CloudDataManager.sharedInstance.cachedImages[cloudFileURL] = image
                                }
                            }
                            completion(image)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }

    static func fetchImageForURL(url: URL, completion: @escaping ((UIImage?) -> ())) {
//        if CloudDataManager.sharedInstance.cachedImages[url] == nil {
        if let image: UIImage = CloudDataManager.sharedInstance.cachedImages[url] {
            completion(image)
        } else {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    let imageData = try Data(contentsOf: url)
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } catch {
                    print("Failed to load image from Documents Directory: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                print("File does not exist at path: \(url.path)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    static func fetchFilesFromICloud() {
        let fileManager = FileManager.default
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            print("iCloud is not enabled")
            return
        }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: iCloudURL, includingPropertiesForKeys: nil, options: [])
            for fileURL in fileURLs {
                // Check if file exists locally, if not, save to local and update Core Data
                let localFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileURL.lastPathComponent)
                if !fileManager.fileExists(atPath: localFileURL.path) {
                    try fileManager.copyItem(at: fileURL, to: localFileURL)
                }
            }
        } catch {
            print("Failed to fetch files from iCloud: \(error)")
        }
    }
}
