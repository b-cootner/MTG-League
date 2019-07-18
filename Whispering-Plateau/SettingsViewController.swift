//
//  SettingsViewController.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/15/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var leagueLabel: UILabel!
    @IBOutlet weak var reportMatchCell: UITableViewCell!

    var leagues: [League] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        League.getLeagues { (leagues) in
            self.leagues = leagues
        }

        if let selectedLeagueName = UserDefaults.standard.value(forKey: "selectedLeagueName") as? String {
            leagueLabel.text = selectedLeagueName
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let leagueVC = segue.destination as? LeaguesViewController else {
            return
        }

        leagueVC.title = "Select League:"
        leagueVC.leagues = leagues
        leagueVC.delegate = self
    }
}

extension SettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "goToLeagues", sender: self)
            break
        default:
            break
        }
    }
}

extension SettingsViewController: LeaguesViewControllerDelegate {
    func didSelect(league: League) {
        UserDefaults.standard.setValue(league.leagueId, forKey: "selectedLeagueId")
        UserDefaults.standard.setValue(league.name, forKey: "selectedLeagueName")
        leagueLabel.text = league.name
    }
}
