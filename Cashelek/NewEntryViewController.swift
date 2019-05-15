//
//  ViewController.swift
//  Cashelek
//
//  Created by Rustam Gradov on 06/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit

//должен кому-то сказать, что появился новый Entry
protocol NewEntryViewControllerDelegate: class {
    
    func entryCreated() //_ entry: Entry - убираю, т.к. кладу его сразу в базу
}

class NewEntryViewController: UIViewController, CategoriesTableViewControllerDelegate, VenuesTableViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var AmountTF: UITextField!
    @IBOutlet weak var CategoriesButton: UIButton!
    @IBOutlet weak var VenuesButton: UIButton!
    
    //Чтобы создать Entry, т.к. у меня нет нигде этих значений в этом вью
    //Создаю контейнер, куда можно складывать полученные кат-ии и места
    var selectedVenue:Venue?
    var selectedCategory: String?
    //добавляю св-во delegate
    //туда буду отправлять события в рамках протокола
    weak var delegate: NewEntryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmountTF.delegate = self
        
        
    /*
         //Если надо прилепить что-то к клаве, и чтобы оно поднималось и исчезало
         //вместе с клавой
         
        //подписываюсь на открытие/закрытие клавы
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            //узнаю размер клавиатуры, чтобы поместить тектовое поле выше неё
            guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            //считаю куда подвинуть текстовое поле(снизу вверх)
            //место куда должен попасть
            let targetY = frame.origin.y - self.AmountTF.frame.height - 16
            //место откуда выезжает текстовое поле
            let sourceY = self.AmountTF.frame.origin.y
            //анимация
            UIView.animate(withDuration: 0.2, animations: {
                self.AmountTF.transform = CGAffineTransform(translationX: 0, y: targetY - sourceY)
            })
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            //сводит на 0 все изменения
            UIView.animate(withDuration: 0.2, animations: {
                self.AmountTF.transform = CGAffineTransform.identity
            })
        }
 */
        //создаем распознователь жестов.
        //Тыкаем в любом месте экрана и клава пропадает
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(recognizer)
    }
    
    @objc func dismissKeyboard() {
        //убрать клаву, т.е. убрать фокус с текстового поля
        AmountTF.resignFirstResponder()
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        let text = AmountTF.text
        
        guard let venue = selectedVenue, let category = selectedCategory,
            let value = text, let amount = Double(value) else { return }
        
        //создаю новый контекст, который будет сохранять
        //НЕ в главном потоке
        
        CoreDataHelper.shared.container.performBackgroundTask { context in
            //здесь я уже не в Main Thread
            //context - новосозданный NSManagedObjectContext
            //который может писать/читать объекты, не блокируя выполнение
            
            let concurrentVenue: Venue
            
            //если ранее не сохранял (т.е. не был в этом месте)
            //то вставляю его в новый (асинхронный) контекст
            if venue.managedObjectContext == nil {
                context.insert(venue)
                concurrentVenue = venue
            } else {
                //я его достал из основного контекста (viewContext)
                //поэтому нужно перенсти venue  в другой контекст,
                //чтобы правильно  создать связь
                concurrentVenue = context.object(with: venue.objectID) as! Venue
            }
            
            let entry = Entry(context: context)
            entry.amount = amount
            entry.venue = concurrentVenue
            entry.category = category
            entry.date = Date()
            
            try! context.save()
        }
        
        //вставляем venue  в контекст
        //только если его еще не вставляли ранее
//        if venue.managedObjectContext == nil {
//            CoreDataHelper.shared.container.viewContext.insert(venue)
//        }
        
        //если проходит гард, создаем Entry
        //удаляю, т.к. создал выше в другом контексте в кордате
//        let entry = Entry(amount: amount, venue: venue, category: category)
        
        //вызываю необходимый метод у делегата
        delegate?.entryCreated()//убираю entry как аргумент, т.к. кладу его сразу в базу
        
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        
        //закрываю экран
        presentingViewController?.dismiss(animated: true, completion: nil)
        //убираю клаву вместе с полем
        AmountTF.resignFirstResponder()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //показываю клаву в поле, чтобы сразу начать вводить текст
        AmountTF.becomeFirstResponder()
    }
    //подписываюсь под метод протокола
    func categorySelected(_ category: String) {
        print("user selected category \(category)")
        //снимаю выделение с ячейки
        dismiss(animated: true, completion: nil)
        //получаю значение на кнопку, выбранное в категориях
        CategoriesButton.setTitle(category, for: .normal)
        //кладу в контейнер полученную категорию, чтобы иметь доступ к ней
        //из любого метода ViewController-а
        selectedCategory = category
    }
    //подписываюсь под метод протокола
    func venueSelected(_ venue: Venue) {
        print("user selected venue \(venue)")
        
        dismiss(animated: true, completion: nil)
        //получаю значение на кнопку, выбранное в местах
        VenuesButton.setTitle(venue.name, for: .normal)
        //кладу в контейнер полученное место, чтобы иметь доступ к нему
        //из любого метода ViewController-а
        //и проверяю есть ли у меня в базе venue с таким id
        if let exictingVenue = Venue.getById(venue.id) {
            //если да, то использую его
            selectedVenue = exictingVenue
        } else {
            //если нет, то новый
            selectedVenue = venue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigation = segue.destination as? UINavigationController {
            if let controller = navigation.viewControllers.first as? CategoriesTableViewController {
                
                controller.delegate = self
                
            }
            if let controller = navigation.viewControllers.first as?
                VenuesTableViewController {
                
                controller.delegate = self
            }
        }
    }
    //запретить писать в текстовом поле что-то, кроме цифр(Double)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //проанализировать текст и вернуть true если позволить применить изменение
        //или false если - нет
        
        //преобразую текущий текст в NSString для использования с NSRange
        let text = textField.text! as NSString
        // result - после применения ввода текста пользователем
        let result = text.replacingCharacters(in: range, with: string)
        // пробую сделать Double из получившейся строки
        let value = Double(result)
        
        return value != nil || result.isEmpty
    }
}

