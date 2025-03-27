//
//  TaskDetailViewController.swift
//  ToDoList
//
//  Created by Николай Гринько on 26.03.2025.
//

import UIKit

class TaskDetailViewController: UIViewController {
    var task: TaskEntity? // ✅ Передаём задачу
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayTaskDetails()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Детали задачи"
        
        let stackView = UIStackView(arrangedSubviews: [userLabel, titleLabel, dateLabel])
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
    
    private func displayTaskDetails() {
        guard let task = task else { return }
        
        userLabel.text = "👤 User \(task.userId)"
        titleLabel.text = "📌 \(task.todo)"
        dateLabel.text = "📅 \(formatDate(task.createdAt))"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}
