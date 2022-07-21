//
//  Table view.swift
//  Diplom-project
//
//  Created by Артем Томило on 14.06.22.
//

import UIKit

extension MapViewController {
    
    //MARK: - Table view settings
    
    func tableViewSettings() {
        
        //MARK: - someview
        
        view.addSubview(someView)
        
        someView.translatesAutoresizingMaskIntoConstraints = false
        
        showMenuConstraint = someView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        hiddenMenuConstraint = someView.trailingAnchor.constraint(equalTo: view.leadingAnchor)
        NSLayoutConstraint.activate([
            someView.topAnchor.constraint(equalTo: view.topAnchor),
            someView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            someView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            hiddenMenuConstraint])
        
        someView.backgroundColor = .systemGray4
        someView.alpha = 1
        
        //MARK: - viewForUserData
        
        someView.addSubview(viewForUserData)
        
        viewForUserData.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewForUserData.topAnchor.constraint(equalTo: someView.safeAreaLayoutGuide.topAnchor, constant: 20),
            viewForUserData.trailingAnchor.constraint(equalTo: someView.trailingAnchor),
            viewForUserData.leadingAnchor.constraint(equalTo: someView.leadingAnchor),
            viewForUserData.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        viewForUserData.backgroundColor = .systemMint
        
        //MARK: - nameLabel
        
        viewForUserData.addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: viewForUserData.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: viewForUserData.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: viewForUserData.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: viewForUserData.leadingAnchor, constant: 120)
        ])
        
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.italicSystemFont(ofSize: 20)
        
        //MARK: - showMenuButton
        
        view.addSubview(showMenuButton)
        
        showMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            showMenuButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            showMenuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            showMenuButton.widthAnchor.constraint(equalToConstant: 50),
            showMenuButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        showMenuButton.setImage(UIImage(named: "menu"), for: .normal)
        showMenuButton.backgroundColor = .white
        showMenuButton.alpha = 0.75
        showMenuButton.layer.cornerRadius = 25
        
        showMenuButton.addTarget(self, action: #selector(showAndHideTableView(_:)), for: .primaryActionTriggered)
        
        //MARK: - avatarView
        
        viewForUserData.addSubview(avatarView)
        
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            avatarView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -25),
            avatarView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        avatarView.frame.size = CGSize(width: 40, height: 40)
        avatarView.layer.cornerRadius = 20
        avatarView.contentMode = .scaleAspectFill
        avatarView.image = UIImage(named: "photo")
        
        //MARK: - signOutButton
        
        someView.addSubview(signOutButton)
        
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signOutButton.bottomAnchor.constraint(equalTo: someView.safeAreaLayoutGuide.bottomAnchor),
            signOutButton.leadingAnchor.constraint(equalTo: someView.leadingAnchor, constant: 40),
            signOutButton.trailingAnchor.constraint(equalTo: someView.trailingAnchor, constant: -40),
            signOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        signOutButton.backgroundColor = .black
        signOutButton.layer.cornerRadius = 20
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.tintColor = .white
        
        signOutButton.addTarget(self, action: #selector(signOutFromAcc(_:)), for: .primaryActionTriggered)
        
        //MARK: - tableView
        
        someView.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: viewForUserData.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: someView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: someView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor)
        ])
        
        tableView.backgroundColor = .systemGray4
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "table-cell")
        
        //MARK: - Clear view
        
        view.addSubview(clearView)
        
        clearView.translatesAutoresizingMaskIntoConstraints = false
        
        showClearViewConstraint = clearView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        hiddenClearViewConstraint = clearView.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        NSLayoutConstraint.activate([
            clearView.topAnchor.constraint(equalTo: view.topAnchor),
            clearView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            clearView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            hiddenClearViewConstraint
        ])
        
        clearView.backgroundColor = .systemGray6
        clearView.alpha = 0.5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        clearView.addGestureRecognizer(tapGesture)
        clearView.isUserInteractionEnabled = true
        tapGesture.delegate = self
    }
    
    //MARK: - Table view actions
    
    func showMenuFunc() {
        showMenuButton.alpha = 0
        filterButton.isHidden = true
        hideMarkerInfoView()
        
        NSLayoutConstraint.deactivate([hiddenMenuConstraint, hiddenClearViewConstraint])
        NSLayoutConstraint.activate([showMenuConstraint, showClearViewConstraint])
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.showMenuButton.backgroundColor = .clear
            self.showMenuButton.alpha = 1
        }
        showTableView = true
    }
    
    func hideMenuFunc() {
        showMenuButton.alpha = 0
        
        NSLayoutConstraint.deactivate([showMenuConstraint, showClearViewConstraint])
        NSLayoutConstraint.activate([hiddenMenuConstraint, hiddenClearViewConstraint])
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if self.lightStyle  {
                self.showMenuButton.backgroundColor = .systemGray3
                self.showMenuButton.alpha = 1
            } else {
                self.showMenuButton.backgroundColor = .white
                self.showMenuButton.alpha = 0.75
                self.filterButton.isHidden = false
            }
        }
        showTableView = false
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        allPlacesButton.isHidden = false
        hidingButton.isHidden = false
        hideMenuFunc()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
