//
//  DetailViewController.swift
//  Locker
//
//  Created by wahid tariq on 30/10/21.
//

import UIKit

class DetailViewController: UIViewController {
    var tempImageSaver: UIImage?
    @IBOutlet var Detailimageview: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = tempImageSaver else {return}
        Detailimageview.image = image
        
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        Detailimageview.addGestureRecognizer(gesture)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionTapped))
    }
    
    @objc func scaleImage(_ sender: UIPinchGestureRecognizer){
        Detailimageview.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
    }
  
    @objc func actionTapped(){
        guard let image = Detailimageview.image?.jpegData(compressionQuality: 0.8) else {
            print("no image found.")
                        return
    }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)

        
    }

  
}
