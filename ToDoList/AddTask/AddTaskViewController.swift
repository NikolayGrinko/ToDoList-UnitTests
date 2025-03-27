//
//  AddTaskViewProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import UIKit

protocol AddTaskViewProtocol: AnyObject {
    func dismissView()
}

class AddTaskViewController: UIViewController, AddTaskViewProtocol {
    var presenter: AddTaskPresenterProtocol?
    var editingTask: TaskEntity? // ✅ Для редактирования)
    private let addButton = UIButton()
    
    private let userIdTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите User ID"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите название задачи"
        return textField
    }()
    
    private let completedSwitch: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("✅ AddTaskViewController открыт через \(presentingViewController != nil ? "present" : "push")")
        if let task = editingTask {
            loadTaskData(task) // ✅ Заполняем поля, если редактируем задачу
        }
    }
    
    func setupUI() {
        view.backgroundColor = .white
        title = editingTask == nil ? "Новая задача" : "Редактирование"
        navigationItem.title = "Добавить задачу"
        
        let stackView = UIStackView(arrangedSubviews: [
            userIdTextField,
            titleTextField,
            completedSwitch
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped)
        )
    }
    
    private func loadTaskData(_ task: TaskEntity) {
        userIdTextField.text = "\(task.userId)"
        titleTextField.text = task.todo
        completedSwitch.isOn = task.completed
    }
    
    func presentAddTaskScreen(from view: UIViewController) {
        let addTaskVC = AddTaskViewController()
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        view.present(navigationController, animated: true, completion: nil) // ✅ Используем present
    }
    
    @objc private func cancelTapped() {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true) // Закрываем через pop
            } else {
                navigationController.dismiss(animated: true, completion: nil) // Закрываем весь nav
            }
        } else {
            dismiss(animated: true, completion: nil) // Закрываем обычный модальный экран
        }
    }
    
    @objc func saveTapped() {
        
        guard let title = titleTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty,
              let userIdText = userIdTextField.text, let userId = Int(userIdText) else {
            showAlert(title: "Ошибка", message: "Введите корректные данные!") // ✅ Показываем алерт
            return
        }
        
        let task = TaskEntity(
            id: editingTask?.id ?? Int64(Date().timeIntervalSince1970),
            todo: title,
            completed: completedSwitch.isOn,
            createdAt: editingTask?.createdAt ?? Date(),
            userId: Int(userId)
        )
        
        presenter?.saveTask(task)
        dismiss(animated: true, completion: nil) // ✅ Закрываем экран после успешного сохранения
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func dismissView() {
        navigationController?.popViewController(animated: true) // ✅ Закрываем экран через стек навигации
        
    }
}
