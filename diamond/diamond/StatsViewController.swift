//
//  StatsViewController.swift
//  diamond
//
//  Created by Daniel Ostashev on 05/11/2022.
//

import UIKit

class StatsViewController: UIViewController {
    
    @IBOutlet weak var firstTree: UIView!
    @IBOutlet weak var secondTree: UIView!
    
    @IBOutlet weak var thirdTree: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    func setProgress(_ progress: Float) {
        heightConstraint.constant = CGFloat(300 * (1 - progress))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        secondTree.isHidden = true
        thirdTree.isHidden = true
        thirdView.isHidden = true
        
        let image = UIImageView(image: UIImage(named: "res_white"))
        view.addSubview(image)
        view.sendSubviewToBack(image)
        image.frame = CGRect(
            origin: view.convert(.zero, from: firstTree),
            size: firstTree.frame.size)
        
        let mask = UIView(frame: firstTree.frame)
        mask.backgroundColor = .white
        
        view.addSubview(mask)
        mask.frame = firstTree.bounds
        mask.frame.origin.y += mask.frame.height
        
        firstTree.mask = mask
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            mask.frame = self.firstTree.bounds
        }, completion: { _ in
            self.firstTree.mask = nil
            self.secondTree.isHidden = false
            self.secondTree.mask = mask
            
            image.frame = CGRect(
                origin: self.view.convert(.zero, from: self.secondTree),
                size: self.firstTree.frame.size)
            mask.frame = self.secondTree.bounds
            mask.frame.origin.y += mask.frame.height
            
            image.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                image.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                    mask.frame.origin.y -= mask.frame.height
                }, completion: { _ in
                    self.secondTree.mask = nil
                    
                    self.thirdTree.isHidden = false
                    self.thirdView.isHidden = false
                    self.thirdView.alpha = 0
                    
                    self.setProgress(0)
                    self.view.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.thirdView.alpha = 1
                    }, completion: { _ in
                        UIView.animate(withDuration: 1, animations: {
                            self.setProgress(0.64)
                            self.view.layoutIfNeeded()
                        }, completion: { _ in
                            image.removeFromSuperview()
                        })
                    })
                })
            })
        })
    }
    
    @IBAction func shareDidPressed() {
        let controller = UIActivityViewController(
            activityItems: ["I saved 57.6 kg CO2. Come join me using Carbon!"],
            applicationActivities: nil)
        
        present(controller, animated: true)
    }
    
    @IBAction func updateProgress(_ slider: UISlider) {
        setProgress(slider.value)
    }
}
