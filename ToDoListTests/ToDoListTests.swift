//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Николай Гринько on 25.03.2025.
//

import XCTest
@testable import ToDoList

class MockTaskListPresenter: TaskListPresenterProtocol {
    func viewDidLoad() {
        print(#function)
    }
    
    func fetchTasks() {
        print(#function)
    }
    
    func toggleTaskCompletion(_ task: ToDoList.TaskEntity) {
        print(#function)
    }
    
    var tasks: [TaskEntity] = []
    private(set) var loadTasksCalled = false
    private(set) var deleteTaskCalled = false
    private(set) var updateTaskCalled = false
    
    func loadTasks() {
        loadTasksCalled = true
    }
    
    func didLoadTasks(_ tasks: [TaskEntity]) {
        self.tasks = tasks
    }
    
    func deleteTask(_ task: TaskEntity) {
        deleteTaskCalled = true
        tasks.removeAll { $0.id == task.id }
    }
    
    func updateTask(_ task: TaskEntity) {
        updateTaskCalled = true
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
    }
}

final class ToDoListTests: XCTestCase {
    
    var sut: TaskListInteractor!
    var mockPresenter: MockTaskListPresenter!
    var mockTask: TaskEntity!
    var coreDataService: CoreDataService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize components
        mockPresenter = MockTaskListPresenter()
        sut = TaskListInteractor()
        sut.presenter = mockPresenter
        coreDataService = CoreDataService.shared
        
        // Create test data
        mockTask = TaskEntity(
            id: 1,
            todo: "Test Task",
            completed: false,
            createdAt: Date(),
            userId: 1
        )
        
        // Add mock task to presenter's tasks
        mockPresenter.tasks = [mockTask]
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockPresenter = nil
        mockTask = nil
        coreDataService = nil
        try super.tearDownWithError()
    }
    
    func testLoadTasks() throws {
        // Given
        XCTAssertFalse(mockPresenter.loadTasksCalled, "loadTasks should not be called before test")
        
    }
    
    func testDeleteTask() throws {
        // Given
        XCTAssertFalse(mockPresenter.deleteTaskCalled, "deleteTask should not be called before test")
        XCTAssertTrue(mockPresenter.tasks.contains { $0.id == mockTask.id }, "Task should exist before deletion")
        
        // When
        sut.deleteTask(mockTask)
        
    }
    
    func testUpdateTask() throws {
        // Given
        XCTAssertFalse(mockPresenter.updateTaskCalled, "updateTask should not be called before test")
        let updatedTask = TaskEntity(
            id: mockTask.id,
            todo: "Updated Task",
            completed: true,
            createdAt: mockTask.createdAt,
            userId: mockTask.userId
        )
        
        // When
        sut.updateTask(updatedTask)
        
        let updatedTaskFromArray = mockPresenter.tasks.first { $0.id == mockTask.id }
        XCTAssertNotNil(updatedTaskFromArray, "Updated task should exist")
        XCTAssertEqual(updatedTaskFromArray?.userId, mockTask.userId, "User ID should remain the same")
    }
}
