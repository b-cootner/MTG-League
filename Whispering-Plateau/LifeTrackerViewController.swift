//
//  LifeTrackerViewController.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/10/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
import UIKit

class LifeTrackerViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var player1NameLabel: UILabel!
    @IBOutlet weak var player1LifeLabel: UILabel!
    @IBOutlet weak var player2NameLabel: UILabel!
    @IBOutlet weak var player2LifeLabel: UILabel!

    @IBOutlet weak var player1WinIcon1: UIImageView!
    @IBOutlet weak var player1WinIcon2: UIImageView!

    @IBOutlet weak var player2WinIcon1: UIImageView!
    @IBOutlet weak var player2WinIcon2: UIImageView!

    @IBOutlet weak var player1RandomNumberLabel: UILabel!
    @IBOutlet weak var player2RandomNumberLabel: UILabel!
    @IBOutlet weak var randomNumberStackView: UIStackView!
    
    var users = [User]()

    var player1: User? {
        didSet {
            player1NameLabel.text = player1?.name
        }
    }

    var player2: User? {
        didSet {
            player2NameLabel.text = player2?.name
        }
    }

    var player1Life: Int = 0 {
        didSet {
            self.player1LifeLabel.text = "\(self.player1Life)"

            if player1Life <= 0 {
                gameOver(winner: player2, loser: player1)
            }
        }
    }

    var player2Life: Int = 0{
        didSet {
            self.player2LifeLabel.text = "\(self.player2Life)"

            if player2Life <= 0 {
                gameOver(winner: player1, loser: player2)
            }
        }
    }

    var winnerOfGame1: User?
    var winnerOfGame2: User?
    var winnerOfGame3: User?
    var playerIcons = [User: [UIImageView]]()
    private var diceAnimationTimer: Timer?
    private var lifeAnimationTimer: Timer?
    private var numberOfDiceRolls = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        reset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true

        guard let recordMatch = UserDefaults.standard.value(forKey: "reportMatches") as? Bool, let leagueName = UserDefaults.standard.value(forKey:"selectedLeagueName") as? String else {
            titleLabel.isHidden = true

            return
        }

        if recordMatch {
            titleLabel.isHidden = false
            titleLabel.text = "\(leagueName) League Match"
        } else {
            titleLabel.isHidden = false
            titleLabel.text = "Casual Match"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func reset() {
        player1 = nil
        player2 = nil
        player1Life = 20
        player2Life = 20

        winnerOfGame1 = nil
        winnerOfGame2 = nil
        winnerOfGame3 = nil

        player1WinIcon1.image = UIImage(named: "circle")
        player1WinIcon2.image = UIImage(named: "circle")
        player2WinIcon1.image = UIImage(named: "circle")
        player2WinIcon2.image = UIImage(named: "circle")

        guard let selectedLeagueId = UserDefaults.standard.value(forKey: "selectedLeagueId") as? Int else {
            return
        }

        League.getLeagueInfo(forLeagueId: selectedLeagueId) { (league) in
            self.users = league?.users ?? []
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "goToPlayers", sender: self)
            }
        }
    }

    @objc private func nextGame() {
        if player1Life > 20 {
            player1Life -= 1
        } else if player1Life < 20 {
            player1Life += 1
        }

        if player2Life > 20 {
            player2Life -= 1
        } else if player2Life < 20 {
            player2Life += 1
        }

        if player1Life == 20 && player2Life == 20 {
            lifeAnimationTimer?.invalidate()
        }
    }

    @objc private func rollDice() {
        randomNumberStackView.isHidden = false
        numberOfDiceRolls -= 1

        if numberOfDiceRolls == -15 {
            diceAnimationTimer?.invalidate()
            randomNumberStackView.isHidden = true
            player1RandomNumberLabel.textColor = .black
            player2RandomNumberLabel.textColor = .black
        } else if numberOfDiceRolls > 0{
            player1RandomNumberLabel.text = "\(Int.random(in: 1...20))"
            player2RandomNumberLabel.text = "\(Int.random(in: 1...20))"
        } else if numberOfDiceRolls == 0 {
            if Int(player1RandomNumberLabel.text ?? "0")! >  Int(player2RandomNumberLabel.text ?? "0")! {
                player1RandomNumberLabel.textColor = .green
            } else if Int(player1RandomNumberLabel.text ?? "0")! <  Int(player2RandomNumberLabel.text ?? "0")!  {
                player2RandomNumberLabel.textColor = .green
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playersVC = segue.destination as? PlayersViewController else {
            return
        }

        playersVC.modalPresentationStyle = .fullScreen

        if player1 == nil {
            playersVC.title = "⇦ Select Player 1:"
        } else {
            playersVC.title = "⇨ Select Player 2:"
        }

        playersVC.users = users
        playersVC.delegate = self
    }

    @IBAction func player1LifePlusClicked(_ sender: Any) {
        player1Life += 1
    }

    @IBAction func player1LifeMinusClicked(_ sender: Any) {
        if player1Life > 0 {
            player1Life -= 1
        }
    }

    @IBAction func player2LifePlusClicked(_ sender: Any) {
        player2Life += 1
    }

    @IBAction func player2LifeMinusClicked(_ sender: Any) {
        if player2Life > 0 {
            player2Life -= 1
        }
    }

    func gameOver(winner: User?, loser: User?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard let winner = winner, let loser = loser else {
                self.reset()
                return
            }

            if self.winnerOfGame1 == nil {
                self.winnerOfGame1 = winner
            } else if self.winnerOfGame2 == nil {
                self.winnerOfGame2 = winner

            } else if self.winnerOfGame3 == nil {
                self.winnerOfGame3 = winner
                self.updateIcon(forPlayer: winner)
                self.reportMatch(winner: winner, loser: loser, numberOfGames: 3)

                return
            }

            if self.winnerOfGame1 == self.winnerOfGame2 {
                self.reportMatch(winner: winner, loser: loser, numberOfGames: 2)
            } else {
                self.updateIcon(forPlayer: winner)
                self.lifeAnimationTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self,
                                                           selector: #selector(self.nextGame), userInfo: nil, repeats: true)
                if let lifeAnimationTimer = self.lifeAnimationTimer {
                    RunLoop.current.add(lifeAnimationTimer, forMode: .common)
                }
            }
        }
    }

    func updateIcon(forPlayer player: User) {
        guard let iconsForPlayer = playerIcons[player] else {
            return
        }

        for icon in iconsForPlayer {
            if icon.image == UIImage(named: "circle") {
                icon.image = UIImage(named: "circle.fill")
                return
            }
        }
    }

    @IBAction func didTapReset(_ sender: Any) {
        reset()
    }

    @IBAction func didTapDice(_ sender: Any) {
        numberOfDiceRolls = Int.random(in: 12...18)
        diceAnimationTimer?.invalidate()
        self.diceAnimationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                       selector: #selector(self.rollDice), userInfo: nil, repeats: true)
        if let diceAnimationTimer = self.diceAnimationTimer {
            RunLoop.current.add(diceAnimationTimer, forMode: .common)
        }
    }

    func reportMatch(winner: User, loser: User, numberOfGames: Int) {
        guard let recordMatch = UserDefaults.standard.value(forKey: "reportMatches") as? Bool, recordMatch == true else {
            let alert = UIAlertController(title: "Match not reported!", message: "Go to Settings to have matches recorded", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            self.reset()
            return
        }

        guard let selectedLeagueId = UserDefaults.standard.value(forKey: "selectedLeagueId") as? Int else {
            return
        }

        let matchReport = MatchReport(winner: winner,
                                      loser: loser,
                                      gameCount: numberOfGames,
                                      leagugeId: selectedLeagueId)
        matchReport.postMatchResult { (succes) in

            if succes {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Match Reported!", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    self?.reset()
                }
            } else {

            }
        }
    }
}

extension LifeTrackerViewController: PlayersViewControllerDelegate {
    func didSelect(user: User, isWinner: Bool) {
        if player1 == nil {
            player1 = user
            self.users = users.filter {$0.userId != player1?.userId}
            self.performSegue(withIdentifier: "goToPlayers", sender: self)

        } else {
            player2 = user

            if let player1 = player1, let player2 = player2 {
                self.playerIcons =  [player1: [player1WinIcon1!, player1WinIcon2!],
                                     player2: [player2WinIcon1!, player2WinIcon2!]]
            }
        }
    }
}
