//
//  ViewController.swift
//  FulfillStorage
//
//  Created by 周 軼飛 on 2019/11/15.
//  Copyright © 2019 ZHOU. All rights reserved.
//

import UIKit

let calStr = "calculating..."
let unknownStr = "unknown"

class ViewController: UITableViewController {

    typealias Info = (title: String, detail: Int)
    var infos: [Info]!
    typealias ButtonAction = (title: String, action: () -> Void)
    var buttons: [ButtonAction]!

    override func viewDidLoad() {
        super.viewDidLoad()

        infos = [("Total", -1), ("GB", -1), ("MB", -1), ("KB", -1)]
        buttons = [("fulfill storage", { [weak self] in self?.fulfillStorage() })]

        readCapacity()
    }

    func readCapacity(shouldShowAlert: Bool = true) {
        DispatchQueue.global().async {
            let alertTitle = "Capacity"
            let fileURL = URL(fileURLWithPath:"/")
            do {
                let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
                if let capacity = values.volumeAvailableCapacityForImportantUsage {
                    if shouldShowAlert {
                        self.showConfirmation(title: alertTitle, message: "Available capacity for important usage: \(capacity)")
                    }
                    self.display(capacity: capacity)
                } else {
                    if shouldShowAlert {
                        self.showConfirmation(title: alertTitle, message: "Capacity is unavailable")
                    }
                    self.infos = [("Total", -2), ("GB", -2), ("MB", -2), ("KB", -2)]
                    self.refreshInfos()
                }
            } catch {
                if shouldShowAlert {
                    self.showConfirmation(title: alertTitle, message: "Error retrieving capacity: \(error.localizedDescription)")
                }
                self.infos = [("Total", -2), ("GB", -2), ("MB", -2), ("KB", -2)]
                self.refreshInfos()
            }
        }
    }

    func showConfirmation(title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func display(capacity: Int64) {
        let total = Int(capacity)
        var remainder = total
        let gigas = DataAllocator.size(of: remainder, from: .bytes, to: .gigabytes)
        remainder -= DataAllocator.size(of: gigas, from: .gigabytes, to: .bytes)
        let megas = DataAllocator.size(of: remainder, from: .bytes, to: .megabytes)
        remainder -= DataAllocator.size(of: megas, from: .megabytes, to: .bytes)
        let kilos = DataAllocator.size(of: remainder, from: .bytes, to: .kilobytes)
        infos = [("Total", total), ("GB", gigas), ("MB", megas), ("KB", kilos)]
        refreshInfos()
    }

    func refreshInfos() {
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

    func fulfillStorage() {
        let gigas = infos[1].detail
        let megas = infos[1].detail
        let kilos = infos[1].detail
        let alertTitle = "Store"

        func fileStorage(unit: DataAllocator.Unit, size: Int, frenquency: Int) {
            do {
                try FileStorage.fileStorage(unit: unit, size: size, frequency: frenquency)
                readCapacity(shouldShowAlert: false)
            } catch {
                print(error.localizedDescription)
                showConfirmation(title: alertTitle, message: error.localizedDescription)
            }
        }

        UIApplication.shared.beginIgnoringInteractionEvents()
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
        DispatchQueue.global().async {
            if gigas > 0 {
                for idx in 1...(gigas * 2) {
                    autoreleasepool {
                        fileStorage(unit: .megabytes, size: 512, frenquency: idx)
                    }
                }
            }
            if megas > 0 {
                for idx in 1...megas {
                    autoreleasepool {
                        fileStorage(unit: .megabytes, size: 1, frenquency: idx)
                    }
                }
            }
            if kilos > 0 {
                for idx in 1...kilos {
                    autoreleasepool {
                        fileStorage(unit: .kilobytes, size: 1, frenquency: idx)
                    }
                }
            }
            DispatchQueue.main.async {
                indicator.removeFromSuperview()
                indicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return infos.count
        case 1:
            return buttons.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = infos[indexPath.row].title

            let detailInt = infos[indexPath.row].detail
            let detailStr: String
            switch detailInt {
            case 0...:
                detailStr = detailInt.description
            case -1:
                detailStr = calStr
            default:
                detailStr = unknownStr
            }
            cell.detailTextLabel?.text = detailStr
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath)
            cell.textLabel?.text = buttons[indexPath.row].title
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            buttons[indexPath.row].action()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Capacity"
        case 1:
            return "Action"
        default:
            return nil
        }
    }

}
