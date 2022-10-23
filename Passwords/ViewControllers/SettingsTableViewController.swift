//
//  SettingsTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/11/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit
import PasswordServices
import LocalAuthentication

class SettingsTableViewController: UITableViewControllerAuthenticable {
    var passwordService: PasswordService! = sharedPasswordService
    
    @IBOutlet weak var authEnabledSwitch: UISwitch!
    @IBOutlet weak var authTimeoutLabel: UILabel!
    @IBOutlet weak var authTimeoutCell: UITableViewCell!
    @IBOutlet weak var infoCell1: UITableViewCell!
    @IBOutlet weak var infoCell2: UITableViewCell!
    
    let kAutoLockNotApplicableText = "Not Applicable"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var config = infoCell1.defaultContentConfiguration()
        config.text = "Running on simulator"
        config.secondaryText = UIDevice.isSimulator ? "Yes" : "No"
        infoCell1.contentConfiguration = config
        
        config = infoCell2.defaultContentConfiguration()
        config.text = "Storage"
        config.secondaryText = sharedDefaults.bool(forKey: PasswordService.kMigratedToJson) ? PasswordService.kStorageFilename : "UserDefaults"
        infoCell2.contentConfiguration = config
        
        let authEnabled = sharedDefaults.bool(forKey: AuthController.kAuthEnabled)
        authEnabledSwitch.isOn = authEnabled
        
        authTimeoutLabel.text = authEnabled ? formatAuthTimeoutText(sharedDefaults.integer(forKey: AuthController.kAuthTimeout)) : kAutoLockNotApplicableText
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selection = tableView.cellForRow(at: indexPath)
        
        // Block destructive development features from running on real devices.
        // Arbitrary tag 99 used on storyboard to flag dangerous cells.
        if selection?.tag == 99 && !UIDevice.isSimulator {
            let ac = UIAlertController(title: "Disabled", message: "This action is only enabled on simulators to protect integrity of data on real devices during development.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        switch selection?.reuseIdentifier {
        case "DeleteAllRecords":
            deleteAllRecords()
        case "InsertExampleRecords":
            insertExampleRecords()
        case "SimulateTask":
            simulateTask()
        default:
            return
        }
    }
    
    func simulateTask() {
        guard let child = getTaskProgressViewController(storyboard: storyboard, view: view) else { return }

        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        let maxTicks = 10
        var curTick = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            curTick += 1
            if curTick == maxTicks {
                DispatchQueue.main.async {
                    child.willMove(toParent: nil)
                    child.view.removeFromSuperview()
                    child.removeFromParent()
                }
                timer.invalidate()
            } else {
                DispatchQueue.main.async {
                    debugPrint("\(curTick) \(maxTicks) \(Float(curTick/maxTicks))")
                    child.progress = Float(curTick) / Float(maxTicks)
                }
            }
        }
    }
    
    func deleteAllRecords() {
        let ac = UIAlertController(title: "Warning", message: "This action will erase all passwords. This action cannot be undone.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Erase", style: .destructive) { [unowned self] _ in
            var deletedRecordCount = 0
            do {
                try passwordService.getRecords().forEach {
                    try passwordService.deleteRecord($0)
                    deletedRecordCount += 1
                }
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
            let ac = UIAlertController(title: "Done", message: "Erased all \(deletedRecordCount) records.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true, completion: nil)
        })
        self.present(ac, animated: true, completion: nil)
    }
    
    func insertExampleRecords() {
        let ac = UIAlertController(title: "Warning", message: "This action will insert dummy records for development testing.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Continue", style: .destructive) { [unowned self] _ in
            let dummyRecords = [
                ["Google", "account1@gmail.com", "password1", "accounts.google.com"],
                ["Google", "account2@gmail.com", "password2", "accounts.google.com"],
                ["Google", "account3@gmail.com", "password3", "accounts.google.com"],
                ["Amazon", "user1", "password", nil],
                ["Facebook", "user1", "password", nil],
                ["Instagram", "user1@gmail.com", "password", nil],
                ["Instagram", "user2@gmail.com", "password", nil],
                ["Netflix", "user1@gmail.com", "password", nil],
                ["Github", "user1@gmail.com", "password", nil],
                ["Apple", "user1@icloud.com", "pass", nil]
            ]
            do {
                try dummyRecords.forEach { try passwordService.createRecord(app: $0[0]!, user: $0[1]!, password: $0[2]!, domain: $0[3], url: nil) }
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
            let ac = UIAlertController(title: "Done", message: "Inserted \(dummyRecords.count) dummy records.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true, completion: nil)
        })
        self.present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AuthTimeoutSelectionTableViewController {
            vc.selectionDelegate = self
            vc.selection = sharedDefaults.integer(forKey: AuthController.kAuthTimeout)
            vc.dismissOnSelection = false
        }
    }
    
    private func verifyBioAuthIsSupportedOnDevice(error: inout NSError?) -> Bool {
        let context = LAContext()
        var biometryIsSupported = false
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself to verify device is capible of biometric authentication."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, authenticationError) in
                DispatchQueue.main.async {
                    biometryIsSupported = success
                }
            }
        }
        return biometryIsSupported
    }
    
    // MARK: - Actions

    @IBAction func authEnabledSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            var error: NSError?
            if verifyBioAuthIsSupportedOnDevice(error: &error) {
                sharedDefaults.set(true, forKey: AuthController.kAuthEnabled)
                authTimeoutCell.isUserInteractionEnabled = true
                authTimeoutCell.accessoryType = .disclosureIndicator
                authTimeoutLabel.text = formatAuthTimeoutText(sharedDefaults.integer(forKey: AuthController.kAuthTimeout))
            } else {
                sharedDefaults.set(false, forKey: AuthController.kAuthEnabled)
                let ac = UIAlertController(title: "Biometry unavailable", message: "Your device reported it is not capible of biometric authentication. Details: \(error?.localizedDescription ?? "none")", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
                    authEnabledSwitch.setOn(false, animated: true)
                    self.dismiss(animated: true)
                })
                self.present(ac, animated: true)
            }
            
        } else {
            sharedDefaults.set(false, forKey: AuthController.kAuthEnabled)
            authTimeoutCell.isUserInteractionEnabled = false
            authTimeoutCell.accessoryType = .none
            authTimeoutLabel.text = kAutoLockNotApplicableText
        }
    }
}

extension SettingsTableViewController: AuthTimeoutSelectionDelegate {
    func timeoutWasSelected(withSeconds seconds: Int?) {
        let seconds = seconds ?? 0
        sharedDefaults.set(seconds, forKey: AuthController.kAuthTimeout)
        authTimeoutLabel.text = formatAuthTimeoutText(seconds)
    }
}
