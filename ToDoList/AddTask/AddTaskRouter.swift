//
//  AddTaskRouter.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import UIKit

class AddTaskRouter {
    static func createModule(editingTask: TaskEntity? = nil) -> UIViewController {
        let view = AddTaskViewController()
        let presenter = AddTaskPresenter()
        let interactor = AddTaskInteractor()

        view.presenter = presenter
        view.editingTask = editingTask // ✅ Передаём задачу при редактировании
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }
}
