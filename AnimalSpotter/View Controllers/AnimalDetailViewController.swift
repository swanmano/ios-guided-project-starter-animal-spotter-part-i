//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {
    
    // MARK: - Properties
    var animalName: String?
    var apiController: APIController?
    
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDetails()
    }
    
    private func getDetails() {
        guard let apiController = apiController,
            let animalName = animalName else {
                print("AnimalDetailViewController: API Controller and animal name are required dependencies")
                return
        }
        
        
        
    }
}
