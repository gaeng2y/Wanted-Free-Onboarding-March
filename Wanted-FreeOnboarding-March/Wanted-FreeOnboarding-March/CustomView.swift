//
//  CustomView.swift
//  Wanted-FreeOnboarding-March
//
//  Created by gaeng on 2023/03/06.
//

import UIKit

enum ImageURL {
    private static let imageIds: [String] = [
        "europe-4k-1369012",
        "europe-4k-1318341",
        "europe-4k-1379801",
        "cool-lion-167408",
        "iron-man-323408"
    ]
    
    static subscript(index: Int) -> URL {
        let id = imageIds[index]
        return URL(string: "https://wallpaperaccess.com/download/" + id)!
    }
}

extension UIImage {
    var thumbnail: UIImage {
        get async {
            let size = CGSize(width: 50, height: 50)
            return await self.resizedImage(ofSize: size)
        }
    }
    
    func resizedImage(ofSize: CGSize) async -> UIImage {
        return self
    }
}

class CustomView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var loadButton: UIButton!
    private var imageLoadTask: Task<Void, Error>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadButton.setTitle("Load", for: .normal)
        loadButton.setTitle("Stop", for: .selected)
    }
    
    deinit {
    }
    
    func reset() {
        self.imageView.image = .init(systemName: "photo")
        self.progressView.progress = 0
        self.loadButton.isSelected = false
    }
    
    func setImage(_ image: UIImage) {
        self.imageView.image = image
    }
    
    func loadImage() {
        loadButton.sendActions(for: .touchUpInside)
    }
    
    func fetchImage(url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        
        if self.imageLoadTask.isCancelled {
            return UIImage(systemName: "xmark")!
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else {
            throw NSError(domain: "fetch error", code: 1004)
        }
        
        if self.imageLoadTask.isCancelled {
            return UIImage(systemName: "xmark")!
        }
        
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "image converting error", code: 999)
        }
        
        return image
    }
    
    func startLoad(url: URL) {
        Task {
            imageView.image = try await imageFetcher.fetchImage(url: url as NSURL)
        }
    }
    
    @IBAction private func onClickLoadButon(_ sender: UIButton) {
        sender.isSelected.toggle()

        guard sender.isSelected else {
            self.imageLoadTask?.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("Please check button's tag")
        }
        
        startLoad(url: ImageURL[sender.tag])
    }
    
    
}
