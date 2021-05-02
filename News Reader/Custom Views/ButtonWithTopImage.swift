//
//  ButtonWithTopImage.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 29/04/21.
//

import UIKit

class ButtonWithTopImage: UIButton {
    
    let topImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    
    let titleTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(topImageView)
        topImageView.centerX(inView: self, topAnchor: topAnchor)
        
        
        addSubview(titleTextLabel)
        titleTextLabel.centerX(inView: self, topAnchor: topImageView.bottomAnchor, paddingTop: -5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = frame.height * 0.9
        topImageView.setDimensions(width: height, height: height)
    }
    
}
