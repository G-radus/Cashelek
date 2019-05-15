//
//  EntriesTableViewController.swift
//  Cashelek
//
//  Created by Rustam Gradov on 12/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit
import CoreData

class EntriesTableViewController: UITableViewController, NewEntryViewControllerDelegate {
    
    //создаю пустой список, куда будут добавляться данные из базы
//    var entries: [Entry] = Entry.loadAllEntries()
    //вместо верхнего теперь выгружаю то, что нужно
    let fetchedController = Entry.fetchedResultsController()
    
    
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        //настраиваю отображение даты и времени
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        
        tableView.allowsSelection = false
        //подписаться на изменения в базе в соответсвии с запросом
        fetchedController.delegate = self
        //достает первоначальный результат
        //выполнить запрос
        try! fetchedController.performFetch()
       
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedController.sections![section].numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTableViewCell", for: indexPath) as! EntryTableViewCell

//        let entry = entries[indexPath.row]  -> изначально было так
        
        let entry = fetchedController.object(at: indexPath)
        
        cell.labelCategory.text = entry.category
        cell.labelVenue.text = entry.venue.name
        cell.labelAmount.text = String(format: "₽%u", Int(entry.amount))
        cell.labelDate.text = dateFormatter.string(from: entry.date)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NewEntryViewController {
            controller.delegate = self
        }
    }
   
    func entryCreated() { // _ entry: Entry убираю аргумент,т.к. сохраняю в базу
        //добавляю новую entry в пустой массив
//        entries.append(entry)
        //добавляю в начало массива, чтобы на выходе показывало свежие операции в начале
//        entries.insert(entry, at: 0)  -> это больше не нужно
        //перезагружаю таблицу
        //        tableView.reloadData() -> тоже делать не нужно
        //убираю экран
        dismiss(animated: true, completion: nil)
        //тоже убираю, т.к. в этом контексте я ничего не сохраняю более
//        try? CoreDataHelper.shared.container.viewContext.save()
        
    }
    
    //для поддержки удаления\изменения ячеек
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    //после того как нажал удалить:
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //получаю тот объект, который собираюсь удалить
        //и удаляю его
//        let entry = entries.remove(at: indexPath.row) -> тоже больше не надо, т.к. нет массива
        let entry = fetchedController.object(at: indexPath)
       
        
        //удалить из CoreData
        //delete просто помечает на удаление
        CoreDataHelper.shared.container.viewContext.delete(entry)
        //конкретно удаляет из базы
        try? CoreDataHelper.shared.container.viewContext.save()
        
    }
}

extension EntriesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //появились новые данные, которые подходят под запрос
        //за которыми следит NSFetchResultsController
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //вызывается на каждое изменение
        //какого-либо объекта, попавшего под запрос
        //за которым следит NSFetchResultsController
        
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
