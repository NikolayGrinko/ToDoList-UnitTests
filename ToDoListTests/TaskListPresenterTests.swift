//
//  TaskListPresenterTests.swift
//  ToDoList
//
//  Created by Николай Гринько on 27.03.2025.
//

import XCTest
@testable import ToDoList // ✅ Подключаем код из приложения

final class TaskListPresenterTests: XCTestCase {
    
    var presenter: TaskListPresenter!
    var mockView: MockTaskListView!
    
    override func setUp() {
        super.setUp()
        mockView = MockTaskListView()
        presenter = TaskListPresenter()
        presenter.view = mockView
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        super.tearDown()
    }

    func testExample() {
           XCTAssertEqual(2 + 2, 4, "Математика сломалась 🤯")
       }
    
    func testPresenter_WhenFetchingTasks_ViewShouldShowTasks() {
        // ✅ Создаём тестовые данные
        let task = [TaskEntity(id: 1, todo: "Test Task", completed: false, createdAt: Date(), userId: 1)]

        // ✅ Вызываем метод у presenter
        presenter.didLoadTasks(task)

        // ✅ Проверяем, что View получила задачи
        XCTAssertEqual(mockView.tasks.count, 1)
        XCTAssertEqual(mockView.tasks.first?.todo, "Test Task")
    }
}

// ✅ Мок для TaskListView
final class MockTaskListView: TaskListViewProtocol {
    var presenter: TaskListPresenterProtocol?
    var tasks: [TaskEntity] = []

    func showTasks(_ tasks: [TaskEntity]) {
        self.tasks = tasks
    }
}
