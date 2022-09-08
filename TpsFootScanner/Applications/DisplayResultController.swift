//
//  DisplayResultController.swift
//  TpsFootScanner
//
//  Created by Nguyen Le on 8/31/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

class DisplayResultController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    var imageBase64String = ""
    var width = 0.0
    var height = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let url = URL(string: imageUrl)
//        let data = try? Data(contentsOf: url!)
//        resultImage.image = UIImage(data: data!)
        
        let imageData = Data(base64Encoded: imageBase64String)
    
        resultImage.image = UIImage(data: imageData!)
        widthLabel.text = "\(width)"
        heightLabel.text = "\(height)"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
