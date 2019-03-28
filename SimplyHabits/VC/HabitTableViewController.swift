//
//  HabitTableViewController.swift
//  SimplyHabits
//
//  Created by Kashyap Sodha on 3/12/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class HabitTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    // Its primary responsibility is to manage our managed objects(Habits) and update our table view
    var resultsController: NSFetchedResultsController<Habit>!
    let coreDataStack = CoreDataStack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Did you perform your activities for today?"
        content.body = "Please visit app and notify me!"
        content.sound = UNNotificationSound.default
        
        // Create the notification trigger
        // For one time notification
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        // For daily notifications
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let uuidString = UUID().uuidString
        
        let notificationRequest = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Register the request with Notification Center
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: nil)
        
        // Creating a request
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        
        // Sorting values to be displayed on table view
        let sortDescriptiors = NSSortDescriptor(key: "start_date", ascending: true)
        request.sortDescriptors = [sortDescriptiors]
        resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        resultsController.delegate = self
        // Fetch
        do {
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
    }
    
    // MARK: Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of cells to be displayed
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath)
        // Configuring the cell
        let habit = resultsController.object(at: indexPath)
        cell.textLabel?.text = habit.habit_name
        if (habit.progress <= 20) {
            cell.detailTextLabel?.text = String(habit.progress) + "/21"
        } else {
            let title = "Congratulations!"
            let message = "Please left swipe to finish the '\(String(habit.habit_name!))' habit."
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            ac.addAction(okAction)
            present(ac, animated: true, completion: nil)
        }
        // Doesn't work
        if (habit.picker_value == "Red") {
            cell.textLabel?.textColor = UIColor.red
            cell.detailTextLabel?.textColor = UIColor.red
            UINavigationBar.appearance().barTintColor = UIColor.red
        } else if (habit.picker_value == "Green") {
            cell.textLabel?.textColor = UIColor.green
            cell.detailTextLabel?.textColor = UIColor.green
            UINavigationBar.appearance().barTintColor = UIColor.green
        } else if (habit.picker_value == "Blue") {
            cell.textLabel?.textColor = UIColor.blue
            cell.detailTextLabel?.textColor = UIColor.blue
            UINavigationBar.appearance().barTintColor = UIColor.blue
        } else if (habit.picker_value == "Yellow") {
            cell.textLabel?.textColor = UIColor.yellow
            cell.detailTextLabel?.textColor = UIColor.yellow
            UINavigationBar.appearance().barTintColor = UIColor.yellow
        } else if (habit.picker_value == "Orange") {
            cell.textLabel?.textColor = UIColor.orange
            cell.detailTextLabel?.textColor = UIColor.orange
            UINavigationBar.appearance().barTintColor = UIColor.orange
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            // Delete Habit
            let habit = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(habit)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Delete failed: \(error)")
                completion(false)
            }
            
        }
        action.image = UIImage(named: "trash")
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Check") { (action, view, completion) in
            // Habit performed
            let habit = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(habit)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Delete failed: \(error)")
                completion(false)
            }
        }
        action.image = UIImage(named: "check")
        action.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAddHabit", sender: tableView.cellForRow(at: indexPath))
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddHabitViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        // If an item is selected
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddHabitViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for:cell) {
                let habit = resultsController.object(at: indexPath)
                vc.habit = habit
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath){
                let habit = resultsController.object(at: indexPath)
                cell.textLabel?.text = habit.habit_name
            }
        default:
            break
        }
    }
}
