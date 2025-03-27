//
//  TaskListRouter.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import UIKit

class TaskListRouter {
    static func createModule() -> UIViewController {
        let view = TaskListView()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }
}
