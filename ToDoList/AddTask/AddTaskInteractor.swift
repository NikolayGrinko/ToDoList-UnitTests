//
//  AddTaskInteractorProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import Foundation

protocol AddTaskInteractorProtocol {
    func saveTask(_ task: TaskEntity)
}

class AddTaskInteractor: AddTaskInteractorProtocol {
    var presenter: AddTaskPresenterProtocol?

    func saveTask(_ task: TaskEntity) {
        
    print("📡 AddTaskInteractor: сохраняем задачу \(task.todo)") // ✅ Должно появиться в консоли
        CoreDataService.shared.saveTask(task)
    }
}
