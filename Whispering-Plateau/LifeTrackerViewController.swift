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
    
    @IBOutlet weak var matchResultsBlocker: UIView!
    @IBOutlet weak var matchResultsTextView: UITextView!

    var matchStartDate : Date?
    var game2StartDate: Date?
    var game3StartDate: Date?
    let formatter = DateComponentsFormatter()


    var users = [User]()

    var player1: User? {
        didSet {
            player1NameLabel.text = player1?.name ?? "Player 1"
        }
    }

    var player2: User? {
        didSet {
            player2NameLabel.text = player2?.name ?? "Player 2"
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

        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.maximumUnitCount = 2
        reset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        navigationController?.setNavigationBarHidden(true, animated: animated)


        guard let leagueName = UserDefaults.standard.value(forKey:"selectedLeagueName") as? String else {
            titleLabel.text = "Error no leauge selected. Go to Settings!"

            return
        }


        titleLabel.isHidden = false
        titleLabel.text = "\(leagueName) League Match"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func reset() {
        matchResultsBlocker.isHidden = true
        matchResultsTextView.isHidden = true
        matchResultsTextView.text = "Match Results:"

        player1 = nil
        player2 = nil
        player1Life = 20
        player2Life = 20

        winnerOfGame1 = nil
        winnerOfGame2 = nil
        winnerOfGame3 = nil

        player1WinIcon1.image = Constants.circleIcon
        player1WinIcon2.image = Constants.circleIcon
        player2WinIcon1.image = Constants.circleIcon
        player2WinIcon2.image = Constants.circleIcon

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
            player1RandomNumberLabel.textColor = UIColor(named: "darkModeOppositeColor")
            player2RandomNumberLabel.textColor = UIColor(named: "darkModeOppositeColor")
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

        playersVC.presentedFromLifeTracker = true
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
                self.game2StartDate = Date()
            } else if self.winnerOfGame2 == nil {
                self.winnerOfGame2 = winner
                self.game3StartDate = Date()
            } else if self.winnerOfGame3 == nil {
                self.winnerOfGame3 = winner
                self.updateIcon(forPlayer: winner)
                self.reportMatch(winner: winner, loser: loser, numberOfGames: 3)

                return
            }

            if self.winnerOfGame1 == self.winnerOfGame2 {
                self.game3StartDate = nil
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
            if icon.image == Constants.circleIcon {
                icon.image = Constants.circleFilledIcon
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

    @IBAction func didTapPlayer1Concede(_ sender: Any) {
        player1Life = 0
    }

    @IBAction func didTapPlayer2Concede(_ sender: Any) {
        player2Life = 0
    }

    var matchResultTimeBreakdown: String {
        let matchFinishedDate = Date()

        if let game3StartDate =  game3StartDate {
            return """
            Game 1 Length: \(formatter.string(from: matchStartDate ?? Date(), to: game2StartDate ?? Date()) ?? "")
            Game 2 Length: \(formatter.string(from: game2StartDate ?? Date(), to: game3StartDate) ?? "")
            Game 3 Length: \(formatter.string(from: game3StartDate, to: matchFinishedDate) ?? "")
            Total Match Length: \(formatter.string(from: matchStartDate ?? Date(), to: matchFinishedDate) ?? "")
            """
        }
        return """
        Game 1 Length: \(formatter.string(from: matchStartDate ?? Date(), to: game2StartDate ?? Date()) ?? "")
        Game 2 Length: \(formatter.string(from: game2StartDate ?? Date(), to: matchFinishedDate) ?? "")
        Total Match Length: \(formatter.string(from: matchStartDate ?? Date(), to: matchFinishedDate) ?? "")
        """
    }


    func reportMatch(winner: User, loser: User, numberOfGames: Int) {
        matchResultsBlocker.isHidden = false
        matchResultsTextView.isHidden = false
        let alert = UIAlertController(title: "Match Over!", message: "Would you like to report this match?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            guard let selectedLeagueId = UserDefaults.standard.value(forKey: "selectedLeagueId") as? Int else {
                return
            }


            let matchReport = MatchReport(winner: winner,
                                          loser: loser,
                                          gameCount: numberOfGames,
                                          leagugeId: selectedLeagueId)
            matchReport.postMatchResult { (succes) in
                let successText = succes ? "✅ Match Reported Successfully" : "⚠️ Error: Match Not Reported! ⚠️"

                DispatchQueue.main.async { [weak self] in
                    self?.matchResultsTextView.text = """
                    Match Results:

                    Winner: \(winner.name)
                    Loser: \(loser.name)
                    Games Played: \(numberOfGames)
                    \(self!.matchResultTimeBreakdown)
                    \(successText)
                    """
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (alert) in
            DispatchQueue.main.async { [weak self] in
                self?.matchResultsTextView.text = """
                Match Results:
                
                Winner: \(winner.name)
                Loser: \(loser.name)
                Games Played: \(numberOfGames)
                \(self!.matchResultTimeBreakdown)
                🤝 Match Choosen Not To Be Reported
                """
            }
        }))
        self.present(alert, animated: true, completion: nil)
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

                matchStartDate = Date()
                game2StartDate = nil
                game3StartDate = nil
            }
        }
    }
}
