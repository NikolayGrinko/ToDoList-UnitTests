//
//  TaskListInteractorProtocol.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import Foundation

protocol TaskListInteractorProtocol {
    func loadTasks()
    func deleteTask(_ task: TaskEntity)
    func updateTask(_ task: TaskEntity)
}

class TaskListInteractor: TaskListInteractorProtocol {
    var presenter: TaskListPresenterProtocol?
    let apiService = APIService()
    let coreDataService = CoreDataService()
    
    
    func loadTasks() {
        print("📡 Interactor: загружаем задачи из CoreData...")
        
        var localTasks = CoreDataService.shared.fetchTasks() // ✅ Загружаем из CoreData
        print("✅ Из CoreData загружено: \(localTasks.count) задач")
        
        // Загружаем API-данные и объединяем с локальными задачами
        apiService.fetchTasks { result in
            switch result {
            case .success(let apiTasks):
                print("✅ Из API загружено: \(apiTasks.count) задач")
                
                // Убираем дубликаты (если такая задача уже есть в CoreData)
                let apiTasksFiltered = apiTasks.filter { apiTask in
                    !localTasks.contains { $0.id == apiTask.id }
                }
                
                // Добавляем API-данные к локальным
                localTasks.append(contentsOf: apiTasksFiltered)
                
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(localTasks)
                }
                
            case .failure(let error):
                print("❌ Ошибка загрузки из API: \(error.localizedDescription)")
                
                // Если API не работает, показываем только локальные данные
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(localTasks)
                }
            }
        }
    }
    
    func deleteTask(_ task: TaskEntity) {
        coreDataService.deleteTask(task)
        loadTasks() // 🔥 Перезагружаем список
    }
    
    func updateTask(_ task: TaskEntity) {
        CoreDataService.shared.updateTask(task) // ✅ Сохраняем в CoreData
        loadTasks() // ✅ Перезагружаем список
        
    }
}
