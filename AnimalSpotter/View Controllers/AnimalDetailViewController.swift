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
        
        apiController.fetchDetails(for: animalName) { result in
            do {
                let animal = try result.get()
                DispatchQueue.main.async {
                    self.updateViews(with: animal)
                }
                apiController.fetchImage(at: animal.imageURL) { (result) in
                    if let image = try? result.get() {
                        DispatchQueue.main.async {
                        self.animalImageView.image = image
                        }
                    }
                }
            } catch {
                if let error = error as? NetworkError {
                    switch error {
                    case .noAuthorization:
                        print("No bearer token exists")
                        let alertController = UIAlertController(title: "Not Logged In", message: "Please Log In.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    case .incorrectAuthorization:
                        print("Bearer token invalid")
                    case .otherError:
                        print("Other error occurred; see log")
                    case .badData:
                        print("No data received or data was corrupted")
                    case .noDecode:
                        print("JSON could not be decoded")
                    }
                }
            }
        }
        
    }
    
    private func updateViews(with animal: Animal) {
        title = animal.name
        descriptionLabel.text = animal.description
        coordinatesLabel.text = "lat: \(animal.latitude), long: \(animal.longitude)"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        
        timeSeenLabel.text = df.string(from: animal.timeSeen)
    }
}
