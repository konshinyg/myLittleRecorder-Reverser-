//
//  recCell.swift
//  myLittleRecorder
//
//  Created by Core on 02.08.17.
//  Copyright © 2017 Cornelius. All rights reserved.
//

import UIKit

class recCell: UITableViewCell {
    
    @IBOutlet weak var recordedCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
