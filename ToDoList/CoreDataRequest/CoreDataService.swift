//
//  CoreDataService.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import CoreData
import UIKit

class CoreDataService {
    static let shared = CoreDataService()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveTask(_ task: TaskEntity) {
        let newTask = Task(context: context)
        newTask.id = task.id
        newTask.title = task.todo
        newTask.isCompleted = task.completed
        newTask.createdAt = task.createdAt
        newTask.userId = Int64(task.userId) // ✅ Теперь userId точно сохраняется
        
        print("✅ CoreDataService: Сохраняем User ID: \(task.userId)")
        
        saveContext()
    }
    
    func updateTask(_ task: TaskEntity) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        
        do {
            let results = try context.fetch(request)
            if let objectToUpdate = results.first {
                objectToUpdate.isCompleted = task.completed // ✅ Сохраняем новый статус
                saveContext()
            }
        } catch {
            print("❌ Ошибка обновления задачи: \(error.localizedDescription)")
        }
    }
    
    func fetchTasks() -> [TaskEntity] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let results = try context.fetch(request)
            print("✅ CoreDataService: найдено \(results.count) задач")
            
            return results.map {
                TaskEntity(
                    id: $0.id,
                    todo: $0.title ?? "",
                    completed: $0.isCompleted,
                    createdAt: $0.createdAt ?? Date(),
                    userId: Int($0.userId) // ✅ Теперь загружается правильный userId
                )
            }
        } catch {
            print("❌ Ошибка загрузки из CoreData: \(error)")
            return []
        }
    }
    
    func deleteTask(_ task: TaskEntity) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        if let result = try? context.fetch(request), let objectToDelete = result.first {
            context.delete(objectToDelete)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save CoreData: \(error)")
        }
    }
}
