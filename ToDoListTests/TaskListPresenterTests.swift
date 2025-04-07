//
//  TaskListPresenterTests.swift
//  ToDoList
//
//  Created by Николай Гринько on 27.03.2025.
//

import XCTest
@testable import ToDoList

final class TaskListPresenterTests: XCTestCase {
    
    var presenter: TaskListPresenter!
    var mockView: MockTaskListView!
    var mockInteractor: MockTaskListInteractor!
    
    override func setUp() {
        super.setUp()
        mockView = MockTaskListView()
        mockInteractor = MockTaskListInteractor()
        presenter = TaskListPresenter()
        presenter.view = mockView
        presenter.interactor = mockInteractor
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockInteractor = nil
        super.tearDown()
    }

    func testExample() {
           XCTAssertEqual(2 + 2, 4, "Математика сломалась ")
       }
    
    func testPresenter_WhenFetchingTasks_ViewShouldShowTasks() {
        // Given
        let task = [TaskEntity(id: 1, todo: "Test Task", completed: false, createdAt: Date(), userId: 1)]
        
        // When
        presenter.didLoadTasks(task)

        // Then
        XCTAssertEqual(mockView.tasks.count, 1)
        XCTAssertEqual(mockView.tasks.first?.todo, "Test Task")
    }
    
    func testPresenter_WhenTaskCompleted_ShouldUpdateTask() {
        // Given
        let task = TaskEntity(id: 1, todo: "Test Task", completed: false, createdAt: Date(), userId: 1)
        
        // When
        presenter.toggleTaskCompletion(task)
        
        // Then
        XCTAssertTrue(mockInteractor.updateTaskCalled)
    }
    
    func testPresenter_WhenTaskDeleted_ShouldRemoveTask() {
        // Given
        let task = TaskEntity(id: 1, todo: "Test Task", completed: false, createdAt: Date(), userId: 1)
        
        // When
        presenter.deleteTask(task)
        
        // Then
        XCTAssertTrue(mockInteractor.deleteTaskCalled)
    }
    
    func testPresenter_WhenViewLoaded_ShouldFetchTasks() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.fetchTasksCalled)
    }
}

// Mock Objects
final class MockTaskListView: TaskListViewProtocol {
    var presenter: TaskListPresenterProtocol?
    var tasks: [TaskEntity] = []
    
    func showTasks(_ tasks: [TaskEntity]) {
        self.tasks = tasks
    }
}

final class MockTaskListInteractor {
    var fetchTasksCalled = false
    var updateTaskCalled = false
    var deleteTaskCalled = false
    
    func fetchTasks() {
        fetchTasksCalled = true
    }
    
    func updateTask(_ task: TaskEntity) {
        updateTaskCalled = true
    }
    
    func deleteTask(_ task: TaskEntity) {
        deleteTaskCalled = true
    }
}

// Protocol conformance
extension MockTaskListInteractor: TaskListInteractorProtocol {}
