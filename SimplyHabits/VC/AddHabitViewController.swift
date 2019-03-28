//
//  AddHabitViewController.swift
//  SimplyHabits
//
//  Created by Kashyap Sodha on 3/12/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreData

class AddHabitViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    var managedContext: NSManagedObjectContext!
    //let coreDataStack = CoreDataStack()
    var habit: Habit?
    
    // MARK: Outlets
    @IBOutlet var habitField: UITextField!
    @IBOutlet var startDateField: UITextField!
    @IBOutlet var endDateField: UITextField!
    @IBOutlet var doneButton: UIButton!
    //@IBOutlet var flag: UISwitch!
    //@IBOutlet var picker: UIPickerView!
    
    @IBOutlet var colorValueField: UILabel!
    var pickerData: [String] = [String]()
    
    // MARK: Actions
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        // Dismiss the keybaord when Cancel button is clicked
        habitField.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissAndResign()
    }
    
    @IBAction func done(_ sender: Any) {
        
        // Get current date
        let dateToday = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        
        let todayDate = formatter.string(from: dateToday)
        
        guard let habitName = habitField.text, !habitName.isEmpty else {
            // Can Display alert box if the Habit is empty
            let title = "Enter Habit Name"
            let message = ""
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            ac.addAction(okAction)
            present(ac, animated: true, completion: nil)
            return
        }
    
        guard let startDate = startDateField.text, !startDate.isEmpty else {
            // Can Display alert box if the Habit is emptylet title = "End Habit!"
            let title = "Enter start date"
            let message = ""
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            ac.addAction(okAction)
            present(ac, animated: true, completion: nil)
            return
        }

        // Convert string to date
        let dateformatter1 = DateFormatter()
        dateformatter1.dateFormat = "MM/dd/yy"
        let dateStart = dateformatter1.date(from: startDate)
        
        // Check for past dates
        if (startDate < todayDate) {
            let title = "No past dates"
            let message = ""
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            ac.addAction(okAction)
            present(ac, animated: true, completion: nil)
            return
        }
        let endDate = Calendar.current.date(byAdding: .day, value: 20, to: dateStart!)
//        guard let endDate = startDate, !endDate.isEmpty else {
//            // Can Display alert box if the Habit is empty
//            return
//        }
//        let dateformatter2 = DateFormatter()
//        dateformatter2.dateFormat = "MM/dd/yy h:mm a Z"
//        let dateEnd = dateformatter2.date(from: endDate)
        
        guard var colorValue = colorValueField.text else {
            // Can Display alert box if the Habit is empty
            let title = "Select the color!"
            let message = ""
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            ac.addAction(okAction)
            present(ac, animated: true, completion: nil)
            return
        }
        if(colorValue.isEmpty){
            colorValue = "Red"
        }
        
        if let habit = self.habit {
            // Add records in Habit table
            habit.habit_name = habitName
            habit.start_date = dateStart
            habit.end_date = endDate
            habit.picker_value = colorValue
            habit.switch_value = true
            
            let dateWithTime = Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            
            let date = dateFormatter.string(from: dateWithTime)
            
            let dateTable = dateFormatter.string(from: habit.tdate!)
            
            // To not update the progress everytime user edits the Habit on the same day
            if (date != dateTable){
                if (habit.progress <= 21) {
                    habit.progress += 1
                } else {
                    let title = "End Habit!"
                    let message = "Congratulations! Your habit list expanded.Please go back on home page."
                    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    ac.addAction(okAction)
                    present(ac, animated: true, completion: nil)
                }
                
            }
            habit.tdate = Date()
        } else {
            // Add records to Habit table
            let habit = Habit(context: managedContext)
            habit.habit_name = habitName
            habit.start_date = dateStart
            habit.end_date = endDate
            habit.picker_value = colorValue
            habit.switch_value = true
            // If it's a future date, set to progress to 0;
            // so as to start the progress from the given date
            if (startDate > todayDate) {
                habit.progress = 0
            } else {
                habit.progress = 1
            }
            habit.tdate = Date()
        }
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("Error saving Habit: \(error)")
        }
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        var flag: Bool = true
        if(sender.isOn == true) {
            // Store value in Core Data
            flag = true
            habit?.switch_value = flag
            //habit!.progress += 1
        }
        else {
            // Store value in Core Data
            flag = false
            //habit?.switch_value = flag
            let title = "Reset Habit!"
            let message = "If you put the switch off, your progress will reset!"
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
                self.habit?.progress = 1
                do {
                    try self.managedContext.save()
                    self.dismissAndResign()
                } catch {
                    print("Error reseting Habit: \(error)")
                }
            }
            ac.addAction(resetAction)
            ac.addAction(cancelAction)
            present(ac, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        return string.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789/")) != nil
//    }
    
    // Hide the Done button and remove the comments below and extend UITextViewDelegate
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if doneButton.isHidden {
//            textView.text.removeAll()
//            doneButton.isHidden = false
//            UIView.animate(withDuration: 0.3, animations: {
//                    self.view.layoutIfNeeded()
//            })
//        }
//    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Display corresponding data for that row and column
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        let value = pickerData[row]
        colorValueField.text = value
        if (pickerData[row].isEmpty) {
            colorValueField.text = "Red"
        }
        //habit?.picker_value = value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Pop-up keyboard with cursor on Habit Field
        habitField.becomeFirstResponder()
        
        if let habit = habit {
            habitField.text = habit.habit_name // Delete function will delete this
            habitField.text = habit.habit_name // This will actually set it
            
            var resultDate1: String {
                let date1 = habit.start_date
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yy" // change format as per needs
                return formatter.string(from: date1!)
            }
            startDateField.text = resultDate1
            startDateField.text = resultDate1
            
            var resultDate2: String {
                let date2 = habit.end_date
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yy" // change format as per needs
                return formatter.string(from: (date2 ?? Date()))
            }
            endDateField.text = resultDate2
            endDateField.text = resultDate2
            
            colorValueField.text = habit.picker_value
            colorValueField.text = habit.picker_value
        }
        
        // Connect the data or do it from Storyboard
//        self.picker.delegate = self
//        self.picker.dataSource = self
        
        // Input data in picker array
        pickerData = ["Red", "Green", "Blue", "Yellow", "Orange"]
    }
}
