//
//  NewsTableViewCell.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 28/04/21.
//

import UIKit

protocol NewsTableViewCellDelegate: class {
    func didSwipeBookmark(cell: NewsTableViewCell, isShown: Bool)
    func didClickBookmark(cell: NewsTableViewCell)
}

class NewsTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NewsTableViewCellDelegate?
    
    var viewModel: NewsViewModel? {
        didSet { configure() }
    }
    
    var lineConstraint: NSLayoutConstraint?
    var arrowConstraint: NSLayoutConstraint?
    
    private let newsImageView: CacheImageView = {
        let iv = CacheImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "placeholder_image")
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private let publishTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let newsTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 3
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var bookmarkButton: ButtonWithTopImage = {
        let button = ButtonWithTopImage(type: .system)
        button.topImageView.image = UIImage(systemName: "book")
        button.titleTextLabel.text = "Bookmark"
        button.addTarget(self, action: #selector(didClickBookmark), for: .touchUpInside)
        return button
    }()
    
    
    
    //MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        var shouldShow = false
        switch sender.direction {
        case .left:
            shouldShow = false
        case .right:
            shouldShow = true
        default:
            return
        }
        
        delegate?.didSwipeBookmark(cell: self, isShown: shouldShow)
        
    }
    
    @objc func didClickBookmark() {
        delegate?.didClickBookmark(cell: self)
    }
    
    //MARK: - Helpers
    private func configureUI() {
        self.selectionStyle = .none
        contentView.addSubview(newsImageView)
        
        contentView.addSubview(shadowView)
        shadowView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, paddingTop: 100, paddingBottom: 10)
        
        newsImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: shadowView.bottomAnchor, trailing: contentView.trailingAnchor)

        
        let verticalLine = UIView()
        verticalLine.backgroundColor = .white
        shadowView.addSubview(verticalLine)
        verticalLine.anchor(top: shadowView.topAnchor, bottom: shadowView.bottomAnchor, paddingTop: 10, paddingBottom: 10, width: 1)
        lineConstraint = verticalLine.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: -1)
        lineConstraint?.isActive = true
        
        contentView.addSubview(bookmarkButton)
        bookmarkButton.centerY(inView: shadowView)
        bookmarkButton.anchor(trailing: verticalLine.leadingAnchor, paddingRight: 20, width: 40, height: 40)
        
        let leftArrwoImage = UIImageView(image: UIImage(systemName: "chevron.right"))
        leftArrwoImage.tintColor = .white
        contentView.addSubview(leftArrwoImage)
        leftArrwoImage.centerY(inView: shadowView)
        leftArrwoImage.setDimensions(width: 7, height: 20)
        arrowConstraint = leftArrwoImage.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: -16)
        arrowConstraint?.isActive = true
        
        contentView.addSubview(publishTimeLabel)
        publishTimeLabel.anchor(top: verticalLine.topAnchor, leading: verticalLine.trailingAnchor, paddingLeft: 16)
        
        let horizontalLine = UIView()
        horizontalLine.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [newsTitleLabel, horizontalLine, subTitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.addGestureRecognizer(createSwipeGestureRecognizer(for: .left))
        stack.addGestureRecognizer(createSwipeGestureRecognizer(for: .right))
        
        contentView.addSubview(stack)
        stack.anchor(top: publishTimeLabel.bottomAnchor, leading: publishTimeLabel.leadingAnchor, bottom: shadowView.bottomAnchor, trailing: leftArrwoImage.leadingAnchor, paddingBottom: 16, paddingRight: 16)
        horizontalLine.setDimensions(width: 200, height: 1)
                
    }
    
    private func configure() {
        guard let vm = self.viewModel else { return }
        self.newsImageView.downloadImage(from: vm.imageUrl)
        self.publishTimeLabel.text = vm.publishTime
        self.newsTitleLabel.text = vm.newsTitle
        self.subTitleLabel.text = vm.newsSubTitle
        
        lineConstraint?.constant = -1
        arrowConstraint?.constant = -16
    }
    
    private func createSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))

        swipeGestureRecognizer.direction = direction

        return swipeGestureRecognizer
    }

    
}
