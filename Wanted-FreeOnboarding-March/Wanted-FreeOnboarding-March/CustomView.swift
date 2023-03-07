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

class CustomView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var loadButton: UIButton!
    private var observation: NSKeyValueObservation!
    private var task: URLSessionDataTask!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadButton.setTitle("Load", for: .normal)
        loadButton.setTitle("Stop", for: .selected)
    }
    
    deinit {
        observation.invalidate()
        observation = nil
    }
    
    func reset() {
        imageView.image = .init(systemName: "photo")
        progressView.progress = 0
        loadButton.isEnabled = true
        loadButton.isSelected = false
    }
    
    func loadImage() {
        loadButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction private func onClickLoadButon(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        guard sender.isSelected else {
            task.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("Please check button's tag")
        }
        
        let url = ImageURL[sender.tag]
        let request = URLRequest(url: url)
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                guard error.localizedDescription == "cancelled" else {
                    fatalError(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    self.reset()
                }
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.imageView.image = .init(systemName: "xmark")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        observation = task.progress.observe(\.fractionCompleted,
                                             options: [.new],
                                             changeHandler: { progress, change in
            DispatchQueue.main.async {
                self.progressView.progress = Float(progress.fractionCompleted)
            }
        })
        
        task.resume()
    }
}
