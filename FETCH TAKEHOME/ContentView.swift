//
//  ContentView.swift
//  FETCH TAKEHOME
//
//  Created by Abdul’s IPhone on 3/18/24.
//
import UIKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct Item: Codable {
    let id: Int
    let listId: Int
    let name: String?
}

class ViewController: UIViewController {
    
    var jsonData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchJSONData()
    }
    
    func fetchJSONData() {
        let urlString = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server responded with an error")
                return
            }
            
            if let data = data {
                self.jsonData = data
                self.processJSONData()
            }
        }.resume()
    }
    
    func processJSONData() {
        guard let jsonData = jsonData else {
            print("No data available")
            return
        }
        
        do {
            let items = try JSONDecoder().decode([Item].self, from: jsonData)
            let filteredItems = items.filter { $0.name != nil && !$0.name!.isEmpty }
            let groupedItems = Dictionary(grouping: filteredItems, by: { $0.listId })
            
            var output = ""
            for (listId, items) in groupedItems.sorted(by: { $0.key < $1.key }) {
                output += "listId: \(listId)\n"
                for item in items.sorted(by: { $0.name! < $1.name! }) {
                    output += "- \(item.name!)\n"
                }
                output += "\n"
            }
            
            print(output)
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
