//
//  CoreDataHelper.swift
//  Cashelek
//
//  Created by Rustam Gradov on 13/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper {
    
    let container: NSPersistentContainer
    let model: NSManagedObjectModel
    
    //singleton
   static let shared = CoreDataHelper()
    
    private init() {
        //alternative - use MagicalRecord https://github.com/magicalpanda/MagicalRecord
        //через cocoapods
        
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        self.model = NSManagedObjectModel(contentsOf: modelURL)!
        self.container = NSPersistentContainer(name: "Grad", managedObjectModel: model)
       /*
        //получаем путь к общей для app extension и самого app папке (app groups / контейнер)
        //let appGroupsURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.tceh.gr")!
        //делаем путь к файлу = appGroupsURL + Store.sqlite
        let storeURL = appGroupsURL.appendingPathComponent("Store.sqlite")
        //создаем объект описания того где и как разместить хранилище на диске
        //раньше он делал это по умолчанию в собственном (но не общем) контейнере
        let description = NSPersistentStoreDescription(url: storeURL)
        self.container.persistentStoreDescriptions = [description]
        
        //миграция из старого места
        //let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        //coordinator.migratePersistentStore(<#T##store: NSPersistentStore##NSPersistentStore#>, to: <#T##URL#>, options: <#T##[AnyHashable : Any]?#>, withType: <#T##String#>)
        */
        self.container.loadPersistentStores { (description, error) in
            if let error = error {
                print(error)
            }
        }
        
//        чтобы viewContext (который работает на Main / UI потоке)
//        знал об изменениях, которые происходят в других контекстах
//        записи - удаления
        self.container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
//мы будем использовать CoreDataHelper.shared для доступа к этому объекту


