//
//  CoreDataMenegaer.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 01/05/21.
//

import UIKit
import CoreData

struct CoreDataMenegaer {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    /// Fetch all Core Data contents for the given type.
    public func fetchAllData<T: NSManagedObject>(ofType type: T.Type, with sort: [NSSortDescriptor]? = nil) -> [T]? {
        // Create the request
        let request = T.fetchRequest()
        if let sort = sort {
            request.sortDescriptors = sort
        }
        
        // Fetch the request
        do {
            let results = try context.fetch(request) as? [T]
            return results
        } catch {
            print("Unable to fetch all data: \(error)")
            return nil
        }
    }
    
    /// Fetch the first data of the given type that matches the given predicate.
    public func fetchData<T: NSManagedObject>(ofType type: T.Type, with predicate: NSPredicate) -> T? {
        // Create the request and set up the predicate
        let request = T.fetchRequest()
        request.predicate = predicate
        
        // Fetch the request
        do {
            let results = try context.fetch(request) as? [T]
            return results?.first
        } catch {
            print("Unable to fetch data: \(error)")
            return nil
        }
    }
    
    /// Delete the specified object from Core Data.
    public func deleteSpecificData<T: NSManagedObject>(ofType type: T.Type, with predicate: NSPredicate, completion: ((Bool) -> Void)?) {
        do {
            guard let data = fetchData(ofType: T.self, with: predicate) else {
                completion?(false)
                return
            }
            self.context.delete(data)
            try self.context.save()
            completion?(true)
        } catch {
            completion?(false)
        }
    }
    
   
    
}

//MARK: - BookmarkManager
extension CoreDataMenegaer {
    
    /// add an bookmark to core data
    public func addBookmark(news: NewsDetail, completion: ((Bool) -> Void)?) {
        
        let pred = NSPredicate(format: "id == %@", String(news.id))
        guard fetchData(ofType: Bookmark.self, with: pred) == nil else {
            completion?(true)
            return
        }
        
        let bookmark = Bookmark(context: self.context)
        bookmark.id = String(news.id)
        bookmark.title = news.title
        bookmark.publishTime = Int64(news.publishTime)
        bookmark.subCategory = news.subcategory
        bookmark.desc = news.description
        bookmark.coverPic = news.coverPic.first
        bookmark.detailUrl = news.detailUrl
        bookmark.page = news.pages.first?.pageContent
        bookmark.date = Date()
        do{
            try self.context.save()
            completion?(true)
        } catch {
            completion?(false)
        }
    }
}
