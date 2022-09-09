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
    @IBOutlet weak var scanAgainButton: UIButton!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var measurementView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorIcon: UIImageView!
    var imageBase64String = ""
    var width = 0.0
    var height = 0.0
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.isHidden = true
        errorIcon.isHidden = true
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        

        scanAgainButton.layer.cornerRadius = scanAgainButton.layer.frame.height / 2
        scanAgainButton.setImage(UIImage(systemName: "arrow.clockwise.circle"), for: .normal)
        scanAgainButton.imageView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
        scanAgainButton.tintColor = .white
        scanAgainButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        scanAgainButton.addTarget(self, action: #selector(scanAgain), for: .touchUpInside)
       

//        let url = URL(string: imageUrl)
//        let data = try? Data(contentsOf: url!)
//        resultImage.image = UIImage(data: data!)
        let imageData = Data(base64Encoded: imageBase64String)
    
        resultImage.image = UIImage(data: imageData!)
        widthLabel.text = "\(width)"
        heightLabel.text = "\(height)"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.imageView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
        let close = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItems = [close]
        
        self.view.insertSubview(statusBarView, at: 0)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        
        
        self.navigationItem.title = "Scan Result"
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.view.backgroundColor = .black
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if (imageBase64String.isEmpty) {
            resultImageView.isHidden = true
            measurementView.isHidden = true
            errorLabel.isHidden = false
            errorIcon.isHidden = false
        } else {
            errorLabel.isHidden = true
            resultImageView.isHidden = false
            measurementView.isHidden = false
            errorIcon.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func close() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func scanAgain() -> Void {
        mainController.scanAgain()
        self.navigationController?.popViewController(animated: true)
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


extension UIViewController {
    var statusBarView: UIView {
        let v = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIApplication.shared.statusBarFrame.height)))
        v.backgroundColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        return v
    }
}
