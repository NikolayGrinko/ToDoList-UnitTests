//
//  TaskListViewProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import UIKit

protocol TaskListViewProtocol: AnyObject {
    var presenter: TaskListPresenterProtocol? { get set }
    func showTasks(_ tasks: [TaskEntity])
}

class TaskListView: UIViewController, TaskListViewProtocol {
    
    // MARK: - Properties
    var presenter: TaskListPresenterProtocol?
    private var tasks: [TaskEntity] = []        // Полный список задач
    private var filteredTasks: [TaskEntity] = [] // Отфильтрованные задачи
    private var isSearching = false             // Флаг поиска
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        table.rowHeight = UITableView.automaticDimension
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Поиск задач..."
        return controller
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.text = "Задач: 0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLongPressGesture()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.fetchTasks()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "To-Do List"
        
        setupNavigationBar()
        setupTaskCountLabel()
        setupTableView()
        setupAddButton()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEditingMode)
        )
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: taskCountLabel.topAnchor, constant: -8)
        ])
    }
    
    private func setupTaskCountLabel() {
        view.addSubview(taskCountLabel)
        
        NSLayoutConstraint.activate([
            taskCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskCountLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            taskCountLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupAddButton() {
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTaskTapped)
        )
        navigationItem.rightBarButtonItems = [navigationItem.rightBarButtonItem!, addButton]
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Actions
    @objc private func addTaskTapped() {
        let addTaskVC = AddTaskRouter.createModule()
        navigationController?.pushViewController(addTaskVC, animated: true)
    }
    
    @objc private func toggleEditingMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItems?[0].title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
                showTaskOptions(for: task)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showTaskOptions(for task: TaskEntity) {
        let alert = UIAlertController(title: "Действия с задачей", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Редактировать", style: .default) { [weak self] _ in
            self?.openEditTaskScreen(task)
        })
        
        alert.addAction(UIAlertAction(title: "Поделиться", style: .default) { [weak self] _ in
            self?.shareTask(task)
        })
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.presenter?.deleteTask(task)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func openEditTaskScreen(_ task: TaskEntity) {
        let editVC = AddTaskRouter.createModule(editingTask: task)
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func shareTask(_ task: TaskEntity) {
        let taskInfo = "👤 User \(task.userId)\n📌 \(task.todo)\n📅 \(formatDate(task.createdAt))"
        let activityVC = UIActivityViewController(activityItems: [taskInfo], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
    
    private func updateTaskCount() {
        let taskCount = isSearching ? filteredTasks.count : tasks.count
        taskCountLabel.text = "Задач: \(taskCount)"
    }
    
    // MARK: - TaskListViewProtocol
    func showTasks(_ tasks: [TaskEntity]) {
        self.tasks = tasks
        self.filteredTasks = tasks
        updateTaskCount()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension TaskListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskCell.identifier,
            for: indexPath
        ) as? TaskCell else {
            return UITableViewCell()
        }
        
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        cell.configure(with: task, delegate: self)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        let detailVC = TaskDetailViewController()
        detailVC.task = task
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.presenter?.deleteTask(task)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UISearchResultsUpdating
extension TaskListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        isSearching = !searchText.isEmpty
        filteredTasks = isSearching ? tasks.filter { $0.todo.lowercased().contains(searchText) } : tasks
        
        updateTaskCount()
        tableView.reloadData()
    }
}

// MARK: - TaskCellDelegate
extension TaskListView: TaskCellDelegate {
    func didToggleCompletion(for task: TaskEntity) {
        presenter?.toggleTaskCompletion(task)
    }
}
