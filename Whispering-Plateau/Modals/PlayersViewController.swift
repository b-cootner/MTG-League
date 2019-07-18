//
//  PlayersViewController.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/2/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
import UIKit

protocol PlayersViewControllerDelegate: class {
    func didSelect(user: User, isWinner: Bool)
}

class PlayersViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationTitle: UINavigationItem!

    var users: [User] = [User]()
    var sortedUsers: [User] {
        return users.sorted(by: { $0.firstName < $1.firstName })
    }

    //Assigned via segue
    weak var delegate: PlayersViewControllerDelegate?
    var isSelectingWinner: Bool = false
    var presentedFromLifeTracker: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.barTintColor = Constants.backgroundColor

        self.view.backgroundColor = Constants.backgroundColor

        registerNibs()

        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationTitle.title = title
    }

    private func registerNibs() {
        collectionView.register(UINib(nibName: "UserCell", bundle: .main), forCellWithReuseIdentifier: "UserCell")
    }
}

extension PlayersViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(user: sortedUsers[indexPath.item], isWinner: isSelectingWinner)
    }
}

extension PlayersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = sortedUsers[indexPath.item]
        cell.nameLabel.text = user.name
        return cell
    }
}

extension PlayersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 40.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}
