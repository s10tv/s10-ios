//
//  MeViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core
import SDWebImage
import Bond

class MeViewController : BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var viewModel: MeViewModel!
    var dataSourceBond: UICollectionViewDataSourceBond<UICollectionViewCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.avatarURL ->> avatarView.dynImageURL
        viewModel.displayName ->> nameLabel
        
        dataSourceBond = UICollectionViewDataSourceBond(collectionView: collectionView)
        let servicesSection = viewModel.linkedServices.map { [unowned self] (service, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(.MeServiceCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! MeServiceCell
            cell.bindViewModel(service)
            return cell
        }
        let addSection = DynamicArray(["Add"]).map { [unowned self] (_, _) -> UICollectionViewCell in
            return self.collectionView.dequeueReusableCellWithReuseIdentifier(.AddCell, forIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        }
        
        DynamicArray([servicesSection, addSection]) ->> dataSourceBond
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.profileVM = ProfileViewModel(meteor: Meteor, user: viewModel.currentUser)
        }
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        Log.debug("Handding to edge \(edge) from dockVC")
        if edge == .Right {
            performSegue(.MeToDiscover)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
    
    @IBAction func linkNewService(sender: AnyObject) {
        let sheet = UIAlertController(title: LS(.meLinkNewSerivceTitle), message: nil, preferredStyle: .ActionSheet)
        for option in viewModel.linkableAccounts {
            sheet.addAction(option.name) { _ in
                // TODO: Actually add service
            }
        }
        sheet.addAction(LS(.meCancelTitle), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func showLogoutOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: LS(.settingsLogoutTitle), message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.settingsLogoutLogout)) { _ in
            Globals.accountService.logout()
            self.navigationController?.popToRootViewControllerAnimated(true)
//            self.performSegue(.SettingsToLoading)
        }
        sheet.addAction(LS(.settingsLogoutCancel), style: .Cancel)
        presentViewController(sheet)
    }

}

extension MeViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let service = viewModel.linkedServices[indexPath.row]
            let title = LS(.meRemoveServiceTitle, service.name.value, service.userDisplayName.value)
            let sheet = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
            sheet.addAction(LS(.meRemoveServiceConfirm), style: .Destructive) { _ in
                // TODO: Actually remove service
            }
            sheet.addAction(LS(.meCancelTitle), style: .Cancel)
            presentViewController(sheet)
        } else {
            linkNewService(self)
        }
    }
}