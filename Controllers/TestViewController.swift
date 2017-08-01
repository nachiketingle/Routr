//
//  TestViewController.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/28/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        modalPresentationStyle = .overCurrentContext
        //view.bounds = CGRect(x: 50, y: 50, width: 50, height: 50)
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        view.isOpaque = false
        
        //presentationController?.presentedViewController = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func workButton(_ sender: UIButton) {
        view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        //self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
