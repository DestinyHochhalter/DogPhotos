//
//  ViewController.swift
//  dogPhotos
//
//  Created by Destiny Hochhalter on 12/29/18.
//  Copyright © 2018 Destiny Hochhalter. All rights reserved.
//

import UIKit
import Kingfisher
import ChameleonFramework

class DogPhotoVC: UIViewController {
    
    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var dimView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageGesture()
        hide(vw: dimView)
        getDogData()
    }
    
    @objc func getDogData() {
        if let url = URL(string: "https://dog.ceo/api/breeds/image/random") {
            // Background thread, heavy tasks go on bg thread
            DispatchQueue.global().async {
                URLSession.shared.dataTask(with: url) { (data, _, error) in
                    if error == nil { // no error
                        if let uwData = data {
                            if let jsonObj = try? JSONSerialization.jsonObject(with:
                                uwData, options: .allowFragments) {
                                if let jsonDict = jsonObj as? [String: Any] {
                                    if let message = jsonDict["message"] as? String {
                                        if let imageUrl = URL(string: message) {
                                            // updating the UI on main
                                            DispatchQueue.main.async {
                                                self.dogImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (dogImage, error, _, _) in
                                                    
                                                    if error == nil {
                                                        if let dogImage = self.dogImageView.image {
                                                            let avgColor = UIColor(averageColorFrom: dogImage)
                                                            let contrastColor = UIColor(complementaryFlatColorOf: avgColor)
                                                            self.dimView.backgroundColor = contrastColor
                                                            self.dogImageView.backgroundColor = avgColor
                                                            
                                                        }
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print(error.debugDescription)
                    }
                    }.resume()
            }
        }
    }
    
    
    // pass in a view, give a duration of how long it will fade in, add an optional completion for when the fade is done.
    func show(vw: UIView, duration: TimeInterval = 0, myCompletion: ((Bool) -> Void)? = nil) {
        vw.isHidden = false
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            vw.alpha = 1
        },completion: myCompletion)
    }
    
    func hide(vw: UIView, delay: TimeInterval = 0, duration: TimeInterval = 0) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            vw.alpha = 0
        }) { (finished) in
            vw.isHidden = true
            self.getDogData()
        }
    }
    
    @objc func imageTapped() {
        if let dogImage = dogImageView.image {
            saveImage(dogImage)
            show(vw: dimView, duration: 0.5) { (finished) in
                print("done")
                self.hide(vw: self.dimView, delay: 0.5, duration: 0.5)
            }
        }
    }
    
    func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func addImageGesture() {
        
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(getDogData))
        nextTap.numberOfTapsRequired = 1
        // create a @objc function
        // create a gesture
        let dblTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        dblTap.numberOfTapsRequired = 2
        // make view interactable = true
        dogImageView.isUserInteractionEnabled = true
        // set gesture to view
        dogImageView.addGestureRecognizer(dblTap)
        dogImageView.addGestureRecognizer(nextTap)
        nextTap.require(toFail: dblTap)
    }
}



