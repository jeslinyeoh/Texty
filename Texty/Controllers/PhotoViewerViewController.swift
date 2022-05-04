//
//  PhotoViewerViewController.swift
//  Texty
//
//  Created by Jeslin Yeoh on 25/12/2021
//  following iOS Academy's YouTube tutorial..
//

import UIKit
import SDWebImage

final class PhotoViewerViewController: UIViewController {
    
    private let url: URL

    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "photo"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds
    }
    
    
}
