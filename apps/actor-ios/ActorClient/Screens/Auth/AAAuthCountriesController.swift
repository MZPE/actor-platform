//
//  AAAuthCountriesController.swift
//  ActorClient
//
//  Created by Danil Gontovnik on 3/31/15.
//  Copyright (c) 2015 Actor LLC. All rights reserved.
//

import UIKit

protocol AAAuthCountriesControllerDelegate : NSObjectProtocol {
    
    func countriesController(countriesController: AAAuthCountriesController, didChangeCurrentIso currentIso: String)
    
}

class AAAuthCountriesController: AATableViewController {
    
    // MARK: -
    // MARK: Private vars
    
    private let countryCellIdentifier = "countryCellIdentifier"
    
    private var _countries: NSDictionary!
    private var _letters: NSArray!
    
    // MARK: -
    // MARK: Public vars
    
    weak var delegate: AAAuthCountriesControllerDelegate?
    var currentIso: String = ""
    
    // MARK: -
    // MARK: Contructors
    
    override init() {
        super.init()
        
        self.title = "Country" // TODO: Localize
        
        let cancelButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelButtonPressed")) // TODO: Localize
        self.navigationItem.setLeftBarButtonItem(cancelButtonItem, animated: false)
        
        tableView.registerClass(AAAuthCountryCell.self, forCellReuseIdentifier: countryCellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 44.0
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Methods
    
    func cancelButtonPressed() {
        dismiss()
    }
    
    // MARK: -
    // MARK: Getters
    
    private func countries() -> NSDictionary {
        if (_countries == nil) {
            var countries = NSMutableDictionary()
            for (index, iso) in enumerate(ABPhoneField.sortedIsoCodes()) {
                let countryName = ABPhoneField.countryNameByCountryCode()[iso as! String] as! String
                let phoneCode = ABPhoneField.callingCodeByCountryCode()[iso as! String] as! String
                //            if (self.searchBar.text.length == 0 || [countryName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                
                let countryLetter = countryName.substringToIndex(advance(countryName.startIndex, 1))
                if (countries[countryLetter] == nil) {
                    countries[countryLetter] = NSMutableArray()
                }
                
                countries[countryLetter]!.addObject([countryName, iso, phoneCode])
            }
            _countries = countries;
        }
        return _countries;
    }
    
    private func letters() -> NSArray {
        if (_letters == nil) {
            _letters = (countries().allKeys as NSArray).sortedArrayUsingSelector(Selector("compare:"))
        }
        return _letters;
    }
    
    // MARK: -
    // MARK: UITableView Data Source
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return [UITableViewIndexSearch] + letters() as [AnyObject]
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if title == UITableViewIndexSearch {
            return 0
        }
        return index - 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return letters().count;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (countries()[letters()[section] as! String] as! NSArray).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AAAuthCountryCell = tableView.dequeueReusableCellWithIdentifier(countryCellIdentifier, forIndexPath: indexPath) as! AAAuthCountryCell
        
        cell.setSearchMode(false) // TODO: Add search bar
        
        let letter = letters()[indexPath.section] as! String
        let countryData: AnyObject = (countries()[letter] as! NSArray)[indexPath.row]
        cell.setTitle(countryData[0] as! String)
        cell.setCode("+\(countryData[2] as! String)")

        return cell
    }
    
    // MARK: -
    // MARK: UITableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (delegate?.respondsToSelector(Selector("countriesController:didChangeCurrentIso:")) != nil) {
            let letter = letters()[indexPath.section] as! String
            let countryData: AnyObject = (countries()[letter] as! NSArray)[indexPath.row]
            
            delegate!.countriesController(self, didChangeCurrentIso: countryData[1] as! String)
        }
        dismiss()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let letter = letters()[section] as! String
        return letter
    }
    
    // MARK: -
    // MARK: Navigation
    
    private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}