//
//  DisplayResultController.swift
//  TpsLidarDemo
//
//  Created by Nguyen Le on 8/31/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

class DisplayResultController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    var imageBase64String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let url = URL(string: imageUrl)
//        let data = try? Data(contentsOf: url!)
//        resultImage.image = UIImage(data: data!)
        
        let imageData = Data(base64Encoded: "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")
    
            resultImage.image = UIImage(data: imageData!)
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
