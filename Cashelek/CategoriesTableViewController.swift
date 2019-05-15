//
//  CategoriesTableViewController.swift
//  Cashelek
//
//  Created by Rustam Gradov on 09/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit

protocol CategoriesTableViewControllerDelegate: class {
    //    Определяем список методов, каждый из которых соответсвует одному
    //    событию, которое было произведено
    func categorySelected(_ category: String)
}

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet var tableCategories: UITableView!
    //тип свойства - это тот, кто умеет использовать делегат сверху
    weak var delegate: CategoriesTableViewControllerDelegate?
    //как только категории меняются говорю им saveCategories
    //применяю для этого DidSet
    var categories = ["rest", "benz", "cafe", "bar"] {
        didSet {
            saveCategories()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadСategories()
        
        //говорю датасорсу, что я(объект класса) буду давать данные для таблицы
        tableCategories.dataSource = self
        tableCategories.delegate = self
    }
    
    @IBAction func AddButton(_ sender: Any) {
        //создаю всплывающее окно
        let alert = UIAlertController(title: "Новая категория", message: nil, preferredStyle: .alert)
        //создаю кнопки (action)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        //добавляю action на alert
        alert.addAction(cancelAction)
        //создаю текстовое поле на алерте
        alert.addTextField { (textField) in
            textField.placeholder = "Категория"
        }
        //добавляю "Создать" action
        let okAction = UIAlertAction(title: "Создать", style: .default) { (action) in
            
            print("нажали на создать")
            //достаю введенный текст
            let newCategory = alert.textFields![0].text!
            self.categories.append(newCategory)
            self.tableCategories.reloadData()
        }
        //добавляю action на alert
        alert.addAction(okAction)
        
        //показываю
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        
        presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    //Методы ДатаСорса
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell") as! CategoryTableViewCell
        
        let category = categories[indexPath.row]
        
        cell.labelCategory.text = category
        
        return cell
        
    }
    
    //Методы делегата
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //снять выделение с ячейки
        tableView.deselectRow(at: indexPath, animated: true)
        //достаю категорию из массива
        let category = categories[indexPath.row]
        print(category)
        //и говорю кому-то, что ее выбрали
        delegate?.categorySelected(category)
    }
    
    //для поддержки удаления\изменения ячеек
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    //после того как нажали удалить:
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let indexToDelete = indexPath.row
        //удаляем из массива
        categories.remove(at: indexToDelete)
        //обновляем таблицу
        //tableCategories.reloadData()
        //удаление ячеек с анимацией
        tableCategories.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //сохранение категорий в UserDefaults
    func saveCategories() {
        
        let defaults = UserDefaults.standard
        defaults.set(categories, forKey: "categories")
        defaults.synchronize()
    }
    //загрузка категорий
    func loadСategories() {
        
    let defaults = UserDefaults.standard
        //если по ключу есть массив String, то исполнится if
        //и в value будет этот массив
        if let value = defaults.array(forKey: "categories") as? [String] {
            self.categories = value
        }
    }
}
