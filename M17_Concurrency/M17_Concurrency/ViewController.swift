//
//  ViewController.swift
//  M17_Concurrency
//
//  Created by Maxim NIkolaev on 08.12.2021.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let service = Service()
    let imagesCount = 5
    
    
//    private lazy var imageView: UIImageView = {
//        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        view.contentMode = .scaleAspectFit
//        return view
//    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 220, y: 220, width: 140, height: 140))
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        setupConstraints()
        onLoad()
    }
    
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
    }

    private func onLoad() {
        var images = [UIImageView]()
        
        let group = DispatchGroup()
        
        
        for _ in 0...imagesCount-1 {
            group.enter()
            service.getImageURL { urlString, error in
                guard
                    let urlString = urlString
                else {
                    return
                }
                
                let image = self.service.loadImage(urlString: urlString)
                DispatchQueue.main.async {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = image
                    images.append(imageView)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .global(qos: .userInteractive)) {
            for image in images {
                DispatchQueue.main.async {
                    self.stackView.addArrangedSubview(image)
                }
            }
            DispatchQueue.main.async {
                print(self.stackView.arrangedSubviews)
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
}
