//
//  TaskListViewProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import UIKit

protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [TaskEntity])
}

class TaskListView: UIViewController, TaskListViewProtocol {
    
    private var tasks: [TaskEntity] = []        // ✅ Полный список задач
    private var filteredTasks: [TaskEntity] = [] // ✅ Отфильтрованные задачи
    private var isSearching = false             // ✅ Флаг поиска
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let addButton = UIButton() // ✅ Кнопка для добавления задачи
    
    var presenter: TaskListPresenterProtocol?
    
    private let taskCountLabel: UILabel = { // ✅ Добавляем label для количества задач
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.text = "Задач: 0"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension // ✅ Авто-высота
        setupUI()
        setupLongPressGesture() // ✅ Добавляем обработчик долгого нажатия
        print("✅ TaskListView загружен, вызываем fetchTasks()")
        setupSearchController()
        setupTaskCountLabel()
        presenter?.loadTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📡 TaskListView: загружаем задачи после возврата") // ✅ Должно появиться в консоли
        presenter?.loadTasks() // 🔥 Перезагружаем список при возврате
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        if gestureRecognizer.state == .began {
            let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
            showTaskOptions(for: task)
        }
    }
    
    private func showTaskOptions(for task: TaskEntity) {
        let alert = UIAlertController(title: "Действия с задачей", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Редактировать", style: .default, handler: { _ in
            self.openEditTaskScreen(task)
        }))
        
        alert.addAction(UIAlertAction(title: "Поделиться", style: .default, handler: { _ in
            self.shareTask(task)
        }))
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
            self.presenter?.deleteTask(task)
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск задач..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setupUI() {
        view.backgroundColor = .white
        title = "To-Do List"
        
        //navigationItem.rightBarButtonItem = editButtonItem // ✅ Добавляем кнопку редактирования
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditingMode)) // ✅ Добавляем кнопку Edit
        
        tableView.frame = CGRect(x: 0, y: 70, width: view.frame.size.width, height: view.frame.size.height - 180)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        setupAddButton() // ✅ Настраиваем кнопку
    }
    
    func setupAddButton() {
        addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addButton.imageView?.contentMode = .scaleAspectFill
        addButton.layer.cornerRadius = 25
        addButton.clipsToBounds = true
        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTaskCountLabel() {
        taskCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskCountLabel)
        
        NSLayoutConstraint.activate([
            taskCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskCountLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            taskCountLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc func addTaskTapped() {
        let addTaskVC = AddTaskRouter.createModule()
        navigationController?.pushViewController(addTaskVC, animated: true) // ✅ Теперь переход в стек навигации
    }
    
    
    // ✅ Добавляем метод для редактирования
    @objc func toggleEditingMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    func showTasks(_ tasks: [TaskEntity]) {
        self.tasks = tasks
        self.filteredTasks = tasks // ✅ Копируем, чтобы фильтрация работала
        updateTaskCount()
        print("✅ TaskListView: обновляем таблицу с \(tasks.count) задачами")
        tableView.reloadData()
    }
    
    private func updateTaskCount() { // ✅ Обновляем текст
        let taskCount = isSearching ? filteredTasks.count : tasks.count
        taskCountLabel.text = "Задач: \(taskCount)"
    }
    
    
    private func openEditTaskScreen(_ task: TaskEntity) {
        let editVC = AddTaskRouter.createModule(editingTask: task) // ✅ Передаём задачу
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
    
    private func shareTask(_ task: TaskEntity) {
        let taskInfo = "👤 User \(task.userId)\n📌 \(task.todo)\n📅 \(formatDate(task.createdAt))"
        let activityVC = UIActivityViewController(activityItems: [taskInfo], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
    
}

extension TaskListView: TaskCellDelegate {
    func didToggleCompletion(for task: TaskEntity) {
        presenter?.updateTask(task) // ✅ Обновляем в CoreData
    }
}

extension TaskListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 Количество строк в таблице: \(tasks.count)")
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        // ✅ Добавляем debug print
        print("📌 Настраиваем ячейку: \(task.todo), UserID: \(task.userId), Выполнено: \(task.completed)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        cell.configure(with: task, delegate: self) // ✅ Передаём делегат
        return cell
    }
}

// ✅ Делаем UITableViewDelegate, чтобы обрабатывать свайпы и выделение
extension TaskListView: UITableViewDelegate {
    
    // ✅ Удаление задачи свайпом влево
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let task = self.tasks[indexPath.row]
            self.presenter?.deleteTask(task) // 🔥 Удаляем через презентер
            self.tasks.remove(at: indexPath.row) // Убираем из списка
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // ✅ Выделение задачи (переключение статуса "выполнено/не выполнено")
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        task.completed.toggle() // 🔥 Переключаем статус
        
        tasks[indexPath.row] = task // ✅ Обновляем массив
        presenter?.updateTask(task) // ✅ Передаём в CoreData
        
        tableView.reloadRows(at: [indexPath], with: .automatic) // ✅ Обновляем UI
        let detailVC = TaskDetailViewController()
        detailVC.task = task
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// ✅ UISearchResultsUpdating
extension TaskListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        if searchText.isEmpty {
            isSearching = false
            filteredTasks = tasks
        } else {
            isSearching = true
            filteredTasks = tasks.filter { $0.todo.lowercased().contains(searchText) }
        }
        
        updateTaskCount()
        tableView.reloadData()
    }
}
