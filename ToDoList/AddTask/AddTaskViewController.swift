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

final class AddTaskViewController: UIViewController, AddTaskViewProtocol {
    // Properties
    internal var presenter: AddTaskPresenterProtocol?
    internal var editingTask: TaskEntity?
    
    // UI Elements
    private let userIdTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите User ID - цифры"
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("✅ AddTaskViewController открыт через \(presentingViewController != nil ? "present" : "push")")
        if let task = editingTask {
            loadTaskData(task)
        }
    }
    
    // MARK: - Setup
    @inline(__always) private func setupUI() {
        configureView()
        setupStackView()
        setupNavigationItems()
    }
    
    @inline(__always) private func configureView() {
        view.backgroundColor = .white
        title = editingTask == nil ? "Новая задача" : "Редактирование"
        navigationItem.title = "Добавить задачу"
    }
    
    @inline(__always) private func setupStackView() {
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
    }
    
    @inline(__always) private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    // MARK: - Data handling
    @inline(__always) private func loadTaskData(_ task: TaskEntity) {
        userIdTextField.text = "\(task.userId)"
        titleTextField.text = task.todo
        completedSwitch.isOn = task.completed
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespaces),
              !title.isEmpty,
              let userIdText = userIdTextField.text,
              let userId = Int(userIdText) else {
            showAlert(title: "Ошибка", message: "Введите корректные данные!")
            return
        }
        
        let task = TaskEntity(
            id: editingTask?.id ?? Int64(Date().timeIntervalSince1970),
            todo: title,
            completed: completedSwitch.isOn,
            createdAt: editingTask?.createdAt ?? Date(),
            userId: userId
        )
        
        presenter?.saveTask(task)
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    @inline(__always) private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - AddTaskViewProtocol
    func dismissView() {
        navigationController?.popViewController(animated: true)
    }
    
    final func presentAddTaskScreen(from view: UIViewController) {
        let addTaskVC = AddTaskViewController()
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        view.present(navigationController, animated: true, completion: nil) // Используем present
    }
}
