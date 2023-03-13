//
//  CustomView.swift
//  Wanted-FreeOnboarding-March
//
//  Created by gaeng on 2023/03/06.
//

import UIKit

fileprivate enum ImageURL {
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
    private var observation: NSKeyValueObservation!
    private var task: URLSessionDataTask!
//    private var workItem: DispatchWorkItem!
    private var blockOperation: BlockOperation!
    private var imageLoadTask: Task<Void, Error>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadButton.setTitle("Load", for: .normal)
        loadButton.setTitle("Stop", for: .selected)
    }
    
    deinit {
        observation?.invalidate()
        observation = nil
    }
    
    func reset() {
        OperationQueue.main.addOperation {
            self.imageView.image = .init(systemName: "photo")
            self.progressView.progress = 0
            self.loadButton.isSelected = false
        }
    }
    
    func loadImage() {
        loadButton.sendActions(for: .touchUpInside)
    }
    
    func stopLoading() {
        
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
    
    func fetchThumbnail(url: URL) async throws -> UIImage {
        let image = try await fetchImage(url: url)
        return await image.thumbnail
    }
    
    private func startLoad(url: URL) {
        imageLoadTask = Task(priority: .userInitiated) {
            // concurrency 가 아닌 상황에서 호출하기 위한 방법
            let image = try await fetchImage(url: url)
            imageView.image = image
        }
        
        
//        blockOperation = BlockOperation {
//            guard !self.blockOperation.isCancelled else {
//                self.reset()
//                return
//            }
//
//            let request = URLRequest(url: url)
//
//            self.task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    guard error.localizedDescription == "cancelled" else {
//                        fatalError(error.localizedDescription)
//                    }
//
//                    self.reset()
//                    return
//                }
//
//                guard let data = data,
//                      let image = UIImage(data: data) else {
//                    OperationQueue.main.addOperation {
//                        self.imageView.image = .init(systemName: "xmark")
//                    }
//                    return
//                }
//
//                OperationQueue.main.addOperation {
//                    self.imageView.image = image
//                    self.loadButton.isSelected.toggle()
//                }
//            }
//
//            self.observation = self.task.progress.observe(\.fractionCompleted,
//                                                 options: [.new],
//                                                 changeHandler: { progress, change in
//                OperationQueue.main.addOperation {
//                    guard !self.blockOperation.isCancelled else {
//                        self.observation.invalidate()
//                        self.observation = nil
//                        self.progressView.progress = 0
//                        return
//                    }
//                    self.progressView.progress = Float(progress.fractionCompleted)
//                }
//            })
//
//            self.task.resume()
//        }
//
//        OperationQueue().addOperation(blockOperation)
    }
    
    @IBAction private func onClickLoadButon(_ sender: UIButton) {
        sender.isSelected.toggle()

        guard sender.isSelected else {
            self.imageLoadTask.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("Please check button's tag")
        }
        
        let url = ImageURL[sender.tag]
        startLoad(url: url)

//
        
//
//        let url = ImageURL[sender.tag]
//        startLoad(url: url)
    }
}
