//
//  ReportMatchViewController.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/2/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
import UIKit

class ReportMatchViewController: UIViewController {

    @IBOutlet weak var winnerTextField: UITextField!
    @IBOutlet weak var loserTextField: UITextField!
    @IBOutlet weak var numberOfGamesTextField: UITextField!

    var users: [User] = [User]()
    var didClickWinner = false

    //set via delegate
    var winner: User? {
        didSet {
            guard let winner = winner else {
                winnerTextField.text = nil

                return
            }
             winnerTextField.text = winner.name
        }
    }
    var loser: User? {
        didSet {
            guard let loser = loser else {
                loserTextField.text = nil

                return
            }
            loserTextField.text = loser.name
        }
    }
        

    override func viewDidLoad() {
        super.viewDidLoad()

        let winnerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(winnerClicked))
        winnerTextField.addGestureRecognizer(winnerGestureRecognizer)

        let loserGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loserClicked))
        loserTextField.addGestureRecognizer(loserGestureRecognizer)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.barTintColor = Constants.backgroundColor

        numberOfGamesTextField.delegate = self

        self.view.backgroundColor = Constants.backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getUsers()
    }

    private func getUsers() {
        guard let selectedLeagueId = UserDefaults.standard.value(forKey: "selectedLeagueId") as? Int else {
            return
        }

        League.getLeagueInfo(forLeagueId: selectedLeagueId) { (league) in
            self.users = league?.users ?? []
        }
    }

    @objc func winnerClicked() {
        didClickWinner = true
        performSegue(withIdentifier: "goToPlayers", sender: self)
    }

    @objc func loserClicked() {
        didClickWinner = false
        performSegue(withIdentifier: "goToPlayers", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playersVC = segue.destination as? PlayersViewController else {
            return
        }

        playersVC.title = didClickWinner ? "Select winner:" : "Select loser:"
        playersVC.users = users
        playersVC.isSelectingWinner = didClickWinner
        playersVC.delegate = self
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        guard let winner = winner, let loser = loser, let games = numberOfGamesTextField.text, let gameCount = Int(games),
            let selectedLeagueId = UserDefaults.standard.value(forKey: "selectedLeagueId") as? Int else {
            return
        }

        let matchReport = MatchReport(winner: winner, loser: loser, gameCount: gameCount, leagugeId: selectedLeagueId)
        matchReport.postMatchResult { (success) in
            if success {
                DispatchQueue.main.async { [weak self] in
                    self?.winner = nil
                    self?.loser = nil
                    self?.numberOfGamesTextField.text = nil

                    let alert = UIAlertController(title: "Match Reported!", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Error!", message: "This match was not reported. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ReportMatchViewController: PlayersViewControllerDelegate {
    func didSelect(user: User, isWinner: Bool) {
        if isWinner {
            winner = user
        } else {
            loser = user
        }
    }
}

extension ReportMatchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let intInput = Int(string) else {
            textField.text = nil

            return false
        }

        if intInput < 4 && intInput > 0 {
            textField.text = string
        }

        textField.resignFirstResponder()
        return false
    }
}
