//
//  ViewController.swift
//  Wanted-FreeOnboarding-March
//
//  Created by gaeng on 2023/03/06.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private var views: [CustomView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        views.forEach {
            $0.reset()
        }
    }
    
    @IBAction private func onClickLoadAllImageButton(_ sender: UIButton) {
        views.forEach {
            $0.loadImage()
        }
    }
}
