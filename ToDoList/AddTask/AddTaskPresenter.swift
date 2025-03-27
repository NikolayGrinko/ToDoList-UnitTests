//
//  AddTaskPresenterProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import Foundation

protocol AddTaskPresenterProtocol {
    func saveTask(_ task: TaskEntity)
}

class AddTaskPresenter: AddTaskPresenterProtocol {
    weak var view: AddTaskViewProtocol?
    var interactor: AddTaskInteractorProtocol?

    func saveTask(_ task: TaskEntity) {
        print("📡 AddTaskPresenter: передаём задачу \(task.todo)") // ✅ Должно появиться в консоли
        interactor?.saveTask(task)
        view?.dismissView()
    }
}
