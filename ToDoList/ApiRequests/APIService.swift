//
//  APIService.swift
//  ToDoList
//
//  Created by Николай Гринько on 25.03.2025.
//

import Foundation

class APIService {
    func fetchTasks(completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("❌ Ошибка: неправильный URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        print("📡 Отправляем запрос: \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ Ошибка: пустой ответ от сервера")
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            // ✅ Выводим сырые данные из API
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Ответ от API:\n\(jsonString)")
            }
            
            do {
                let decodedData = try JSONDecoder().decode(TaskResponse.self, from: data)
                let tasks = decodedData.todos.map {
                    TaskEntity(id: Int64($0.id), todo: $0.todo, completed: $0.completed, createdAt: Date(), userId: Int(Int64($0.userId)))
                }
                
                print("✅ APIService: Загружено \(tasks.count) задач") // 🔥 Проверяем количество задач
                
                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            } catch {
                print("❌ Ошибка декодирования JSON: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
