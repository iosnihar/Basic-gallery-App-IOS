//
//  CustomView.swift
//  pagenation Demo
//
//  Created by Nihar Vaghela on 28/10/23.
//

import Foundation
import UIKit

class ProfileBottomPopupView: UIView {
    // Subviews
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let userImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        // Customize the view properties
        backgroundColor = .white
        layer.cornerRadius = 15
        // Add and configure subviews
        // User Image View
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 20 // Adjust the corner radius based on your requirement
        // Other labels
        nameLabel.textAlignment = .center
        emailLabel.textAlignment = .center
        
        // Layout constraints
        addSubview(nameLabel)
        addSubview(emailLabel)
        addSubview(userImageView)
        
        // Autolayout
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            userImageView.widthAnchor.constraint(equalToConstant: 80),
            userImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    func setUserDetails(name: String, email: String, image: UIImage) {
        nameLabel.text = name
        emailLabel.text = email
        userImageView.image = image
    }
}
