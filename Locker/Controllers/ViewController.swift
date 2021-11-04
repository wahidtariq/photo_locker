//
//  ViewController.swift
//  Locker
//
//  Created by wahid tariq on 30/10/21.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var imageArray: [ImageData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "images") as? Data{
            let jsonDecoder = JSONDecoder()
            do{
                imageArray = try jsonDecoder.decode([ImageData].self, from: savedData)
            }catch{
                print("cannot load images from defaults.")
            }
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionViewCell
        
        let image = imageArray[indexPath.item]
        let path = getDocumentsDirectory().appendingPathComponent(image.image)
        cell.imageview.image = UIImage(contentsOfFile: path.path)
        cell.imageview.layer.cornerRadius = 10
        cell.imageview.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageview.layer.borderWidth = 2
        cell.layer.cornerRadius = 7
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVc") as! DetailViewController
        let image = imageArray[indexPath.item]
        let path = getDocumentsDirectory().appendingPathComponent(image.image)
        vc.tempImageSaver = UIImage(contentsOfFile: path.path)
        //        vc.tempImageSaver = imageArray[indexPath.item].image
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { [self] (_) in
                
                let image = imageArray[indexPath.item]
                
                imageArray.remove(at: imageArray.firstIndex(of: image)!)
                save()
                collectionView.deleteItems(at: [indexPath])
                collectionView.reloadData()
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [delete])
            
        }
        return context
        
    }
    
    
    @IBAction func imagePickerPressed(_ sender: UIBarButtonItem) {
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let Actualimage = ImageData(image: imageName)
        imageArray.append(Actualimage)
        save()
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
        
    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save(){
        
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(imageArray){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "images")
        }else{
            print("failed to save images.")
        }
    }
    
    
}

