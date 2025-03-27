//
//  TaskListPresenterProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import Foundation

protocol TaskListPresenterProtocol {
    func loadTasks()
    func didLoadTasks(_ tasks: [TaskEntity])
    func deleteTask(_ task: TaskEntity)
    func updateTask(_ task: TaskEntity)
}

class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorProtocol?
    
    func loadTasks() {
        print("📡 Presenter: вызываем interactor.loadTasks()")
        interactor?.loadTasks()
    }
    
    func didLoadTasks(_ tasks: [TaskEntity]) {
        print("✅ Presenter получил задачи: \(tasks.count)")
        view?.showTasks(tasks) // 🔥 Передаём данные в View
    }
    
    
    func deleteTask(_ task: TaskEntity) {
        interactor?.deleteTask(task)
    }
    
    func updateTask(_ task: TaskEntity) {
        interactor?.updateTask(task)  // ✅ Передаём обновление в Interactor
    }
}
