import SwiftUI
import PhotosUI

class PhotoManager {
    static let shared = PhotoManager()
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveImage(_ image: UIImage) -> String? {
        let id = UUID().uuidString
        let filename = "\(id).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(filename: String) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    // Deprecated: Old PHAsset fetcher kept for reference if needed, but unused now.
    func fetchImage(for id: String, targetSize: CGSize = CGSize(width: 300, height: 300), completion: @escaping (UIImage?) -> Void) {
        // Fallback to loading from disk if it looks like a filename
        if id.contains(".jpg") {
            completion(loadImage(filename: id))
            return
        }
        // ... old implementation ...
    }
}
