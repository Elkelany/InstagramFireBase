//
//  CommentInputAccessoryView.swift
//  InstagramFireBase
//
//  Created by macOS on 3/20/19.
//  Copyright © 2019 macOS. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
//        textField.placeholder = "Enter Comment"
        return tv
    }()
    
    let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, bottom: nil, left: nil, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: -12, width: 50, height: 50)
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, left: leftAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingBottom: 8, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        
        setupLineSeparatorView()
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    fileprivate func setupLineSeparatorView() {
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(230, 230, 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, bottom: nil, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0.7)
    }
    
    @objc func handleSubmit() {
        guard let comment = commentTextView.text else { return }
        delegate?.didSubmit(for: comment)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
