//
//  ViewController.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 6/28/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let padding: CGFloat = 10.0

    var standingItems: [Standing] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.collectionView.reloadData()
            }
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.barTintColor = Constants.backgroundColor

        self.view.backgroundColor = Constants.backgroundColor

        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]


        registerNibs()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: padding, left: 0, bottom: 0, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = Constants.backgroundColor

        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(getLeagueStandings), for: .valueChanged)

        if UserDefaults.standard.value(forKey: "selectedLeagueId") == nil {
            League.getLeagues { (leagues) in
                UserDefaults.standard.setValue(leagues.last?.leagueId ?? 0, forKey: "selectedLeagueId")
                UserDefaults.standard.setValue(leagues.last?.name ?? 0, forKey: "selectedLeagueName")
                self.getLeagueStandings()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getLeagueStandings()
    }

    @objc private func getLeagueStandings() {
        guard let selectedLeagueId = UserDefaults.standard.value(forKey: "selectedLeagueId") as? Int else {
            return
        }

        Standing.getStandings(forLeague: selectedLeagueId) { (standings) in
            self.standingItems = standings
        }
    }

    private func registerNibs() {
        collectionView.register(UINib(nibName: "StandingsCell", bundle: .main), forCellWithReuseIdentifier: "StandingsCell")
    }
}

extension ViewController: UICollectionViewDelegate {

}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return standingItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandingsCell", for: indexPath) as! StandingsCell
        cell.configureCell(standingItems[indexPath.item])
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.size.width - (2 * padding), height: 115.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: padding, bottom: 0.0, right: padding)
    }
}
