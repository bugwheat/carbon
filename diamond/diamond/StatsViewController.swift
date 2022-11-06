//
//  StatsViewController.swift
//  diamond
//
//  Created by Daniel Ostashev on 05/11/2022.
//

import UIKit

class StatsViewController: UIViewController {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    func setProgress(_ progress: Float) {
        heightConstraint.constant = CGFloat(300 * (1 - progress))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProgress(0.64)
    }
    
    @IBAction func updateProgress(_ slider: UISlider) {
        setProgress(slider.value)
    }
}
