//
//  MainViewController.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: NewNoteViewController.segueId, sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case NewNoteViewController.segueId?:
            guard let destinationNAVVC = segue.destination as? UINavigationController else { return }
            guard let destinationVC = destinationNAVVC.topViewController as? NewNoteViewController else { return }
            destinationVC.delegate = self


        case EditNoteViewController.segueId?:
            guard let _ = segue.destination as? EditNoteViewController else { return }

        default:
            print(#function + " " + "Unknown Segue")
        }
    }

}

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: EditNoteViewController.segueId, sender: indexPath)
    }

}

extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellId = "cell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        return cell
    }
}

extension MainViewController: NewNoteViewControllerDelegate {

    func didTapCancel(from newNoteViewController: NewNoteViewController) {
        newNoteViewController.dismiss(animated: true) { 

        }
    }

    func didTapSave(from newNoteViewController: NewNoteViewController) {
        newNoteViewController.dismiss(animated: true) {

        }
    }
}
