//
//  EntryTableViewCell.swift
//  Cashelek
//
//  Created by Rustam Gradov on 12/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelVenue: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
