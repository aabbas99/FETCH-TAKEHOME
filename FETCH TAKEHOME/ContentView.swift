//
//  ContentView.swift
//  FETCH TAKEHOME
//
//  Created by Abdul’s IPhone on 3/18/24.
//
import UIKit
import SwiftUI

struct Item: Codable, Identifiable {
    let id: Int
    let listId: Int
    let name: String?
}

struct ContentView: View {
    @State private var items: [Item] = []
    @State private var filteredItems: [Item] = []
    @State private var groupedItems: [Int: [Item]] = [:]
    @State private var isLoading = false
    @State private var errorMessage = ""
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage)
            } else {
                List(groupedItems.sorted(by: { $0.key < $1.key }), id: \.key) { listId, items in
                    Section(header: Text("listId: \(listId)")) {
                        ForEach(items.sorted(by: { $0.name?.localizedStandardCompare($1.name ?? "") == .orderedAscending }))  { item in Text(item.name ?? "")
                        }
                    }
                    
                }
            }
        }
        .onAppear {
            fetchData()
        }
    }
    
    private func fetchData() {
        isLoading = true
        errorMessage = ""

        guard let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Server responded with an error"
                    return
                }

                if let data = data {
                    do {
                        self.items = try JSONDecoder().decode([Item].self, from: data)
                        self.processData()
                    } catch {
                        self.errorMessage = "Error decoding JSON: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }
    
    private func processData() {
        filteredItems = items.filter { $0.name != nil && !$0.name!.isEmpty }
        groupedItems = Dictionary(grouping: filteredItems, by: { $0.listId })
    }
}




