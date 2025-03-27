//
//  TaskResponse.swift
//  ToDoList
//
//  Created by Николай Гринько on 26.03.2025.
//

import Foundation

struct TaskResponse: Codable {
    let todos: [TodoItem]
}

struct TodoItem: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int  // ✅ Добавили userId
}
