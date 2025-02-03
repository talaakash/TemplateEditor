//
//  UndoRedoManager.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import Foundation

class UndoRedoManager {
    
    static let shared = UndoRedoManager()
    static let undoManager = UndoManager()
    
    var canUndo: Bool {
        UndoRedoManager.undoManager.canUndo
    }
    
    var canRedo: Bool {
        UndoRedoManager.undoManager.canRedo
    }
    
    func registerUndo(target: AnyObject, handler: @escaping (AnyObject) -> ()) {
        UndoRedoManager.undoManager.registerUndo(withTarget: target) { target in
            handler(target)
        }
    }
    
    func registerRedo(target: AnyObject, handler: @escaping (AnyObject) -> ()) {
        UndoRedoManager.undoManager.registerUndo(withTarget: target) {  target in
            handler(target)
        }
    }
    
    func undo() {
        if UndoRedoManager.undoManager.canUndo {
            UndoRedoManager.undoManager.undo()
        }
    }
    
    func redo() {
        if UndoRedoManager.undoManager.canRedo {
            UndoRedoManager.undoManager.redo()
        }
    }
    
    func clearUndoRedoStack() {
        UndoRedoManager.undoManager.removeAllActions()
    }
}

extension UndoManager {
    func replace<T: Codable>(item oldItem: T, with newItem: T, title: String? = nil, handler: ((T) -> Void)?) {
        guard let oldItem = copy (item: oldItem) else { return }
        guard let newItem = copy (item: newItem) else { return }
        registerUndo (withTarget: self) {
            handler? (oldItem)
            $0.replace(item: newItem, with: oldItem, title: title, handler: handler)
        }
        guard let title = title else { return }
        setActionName (title)
    }
    
    private func copy<T: Codable> (item: T) -> T? {
        guard let data = try? JSONEncoder ().encode(item) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
