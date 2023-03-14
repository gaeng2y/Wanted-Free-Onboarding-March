//
//  ViewController.swift
//  Wanted-FreeOnboarding-March
//
//  Created by gaeng on 2023/03/06.
//

import UIKit

actor ImageFetcher {
    var images: NSCache<NSURL, UIImage> = NSCache()
    
    private subscript(url: NSURL) -> UIImage? {
        return images.object(forKey: url)
    }
    
    func fetchImage(url: NSURL) async throws -> UIImage {
        if let image = self[url] {
            return image
        }
        let (data, _) = try await URLSession.shared.data(from: url as URL)
        let image = UIImage(data: data)!
        images.setObject(image, forKey: url)
        return image
    }
}

let imageFetcher = ImageFetcher()
let imageSequence = ImageSequence()

class ImageIterator: AsyncIteratorProtocol {
    typealias Element = UIImage
    
    private var index: Int = 0
    
    func next() async throws -> UIImage? {
        defer { index += 1 }
        guard index < 5 else { return nil }
        let url = ImageURL[index]
        return try await imageFetcher.fetchImage(url: url as NSURL)
    }
}

class ImageSequence: AsyncSequence {
    typealias AsyncIterator = ImageIterator
    
    typealias Element = UIImage
    
    func makeAsyncIterator() -> ImageIterator {
        return ImageIterator()
    }
}

final class ViewController: UIViewController {
    
    @IBOutlet private var views: [CustomView]!
    @IBOutlet private var loadAllImageButton: UIButton!
    private var loadAllImageTask: Task<Void, Error>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        views.forEach { $0.reset() }
        loadAllImageButton.setTitle("Load All Images", for: .normal)
        loadAllImageButton.setTitle("Stop All Images", for: .selected)
    }
    
    @IBAction private func onClickLoadAllImageButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        guard sender.isSelected else {
            self.loadAllImageTask.cancel()
            views.forEach { $0.reset() }
            return
        }
        
        loadAllImageTask = Task {
            var index = 0
            for try await image in imageSequence {
                defer { index += 1 }
                views[index].setImage(image)
            }
        }
    }
}

