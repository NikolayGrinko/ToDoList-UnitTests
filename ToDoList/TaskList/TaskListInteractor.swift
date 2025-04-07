//
//  TaskListInteractorProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import Foundation

protocol TaskListInteractorProtocol {
    func fetchTasks()
    func updateTask(_ task: TaskEntity)
    func deleteTask(_ task: TaskEntity)
}

class TaskListInteractor: TaskListInteractorProtocol {
    weak var presenter: TaskListPresenterProtocol?
    private let apiService: APIService
    private let coreDataService: CoreDataService
    
    init(apiService: APIService = APIService(),
         coreDataService: CoreDataService = CoreDataService.shared) {
        self.apiService = apiService
        self.coreDataService = coreDataService
    }
    
    func fetchTasks() {
        print("📡 Interactor: загружаем задачи из CoreData...")
        
        var localTasks = coreDataService.fetchTasks()
        print("✅ Из CoreData загружено: \(localTasks.count) задач")
        
        apiService.fetchTasks { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiTasks):
                print("✅ Из API загружено: \(apiTasks.count) задач")
                
                let apiTasksFiltered = apiTasks.filter { apiTask in
                    !localTasks.contains { $0.id == apiTask.id }
                }
                
                apiTasksFiltered.forEach { task in
                    self.coreDataService.saveTask(task)
                }
                
                localTasks.append(contentsOf: apiTasksFiltered)
                
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(localTasks)
                }
                
            case .failure(let error):
                print("❌ Ошибка загрузки из API: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(localTasks)
                }
            }
        }
    }
    
    func deleteTask(_ task: TaskEntity) {
        coreDataService.deleteTask(task)
        fetchTasks()
    }
    
    func updateTask(_ task: TaskEntity) {
        coreDataService.updateTask(task)
        fetchTasks()
    }
}
