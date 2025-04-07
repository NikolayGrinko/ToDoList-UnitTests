//
//  TaskListPresenterProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import Foundation

// Обновляем протокол с необходимыми методами
protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func fetchTasks()
    func deleteTask(_ task: TaskEntity)
    func toggleTaskCompletion(_ task: TaskEntity)
    func didLoadTasks(_ tasks: [TaskEntity])
}

class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorProtocol?
    
    func viewDidLoad() {
        fetchTasks()
    }
    
    func fetchTasks() {
        interactor?.fetchTasks()
    }
    
    func didLoadTasks(_ tasks: [TaskEntity]) {
        view?.showTasks(tasks)
    }
    
    func toggleTaskCompletion(_ task: TaskEntity) {
        var updatedTask = task
        updatedTask.completed = !task.completed
        interactor?.updateTask(updatedTask)
    }
    
    func deleteTask(_ task: TaskEntity) {
        interactor?.deleteTask(task)
    }
}
