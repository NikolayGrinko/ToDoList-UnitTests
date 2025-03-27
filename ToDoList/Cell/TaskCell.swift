//
//  TaskCell.swift
//  ToDoList
//
//  Created by Николай Гринько on 26.03.2025.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
    func didToggleCompletion(for task: TaskEntity)
}

class TaskCell: UITableViewCell {
    static let identifier = "TaskCell"
    
    weak var delegate: TaskCellDelegate? // ✅ Делегат для обновления статуса
    private var task: TaskEntity?
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var checkmarkButton: UIButton = { // ✅ Кнопка для отметки выполнения
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.tintColor = .systemGreen
        button.addTarget(self, action: #selector(toggleCompletion), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [userLabel, titleLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        contentView.addSubview(checkmarkButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            checkmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with task: TaskEntity, delegate: TaskCellDelegate) {
        self.task = task
        self.delegate = delegate
        
        userLabel.text = "User \(task.userId)"
        titleLabel.text = task.todo
        dateLabel.text = formatDate(task.createdAt)
        checkmarkButton.isSelected = task.completed // ✅ Отображаем статус
    }
    
    @objc private func toggleCompletion() {
        guard var task = task else { return }
        task.completed.toggle() // ✅ Переключаем статус
        delegate?.didToggleCompletion(for: task) // ✅ Сообщаем делегату
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}
