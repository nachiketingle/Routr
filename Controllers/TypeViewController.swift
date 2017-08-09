//
//  TypeViewController.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 8/3/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import UIKit

class TypeViewController: UIViewController {
    @IBOutlet weak var pickerView: UIPickerView!

    var types: [String] = ["Attractions", "Hotels", "Restaurants"]
    var selection: String = "Attrations"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "unwindToCollection" {
                if let nextViewController = segue.destination as? PopupCollectionViewController {
                    nextViewController.selectedType = selection
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension TypeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // returns the number of 'columns' to display.

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("Title for \(row) is \(types[row])")
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selection = types[row]
        performSegue(withIdentifier: "unwindToCollection", sender: self)
    }
}
