//
//  TasbeehViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 10.03.2025.
//

import Foundation
import SwiftUI

class TasbeehViewModel: ObservableObject {
    
    @Published var tasbeehs: [TasbeehModel] = []
    @Published var isOpenPaywall: Bool = false
    @Published var showingAddAlert = false
    @Published var newDhikrName = ""
    @Published var showingPremiumAlert = false
    @Published var selectedTasbeeh: TasbeehModel?
    
    let coordinator: MainCoordinatorPresenter
    
    init(tasbeehs: [TasbeehModel] = [],
         coordinator: MainCoordinatorPresenter) {
        self.tasbeehs = tasbeehs
        self.coordinator = coordinator
        loadTasbeehs()
    }
    
    func addNewDhikr(isPremium: Bool ) {
        print("Checked premium: \(isPremium)")
        if isPremium {
            newDhikrName = ""
            showingAddAlert = true
        } else if tasbeehs.count >= 3 {
            showingPremiumAlert = true
        } else {
            newDhikrName = ""
            showingAddAlert = true
        }
    }
    
    func saveDhikr() {
        guard !newDhikrName.isEmpty else { return }
        
        let newId = (tasbeehs.map { $0.id }.max() ?? 0) + 1
        let newTasbeeh = TasbeehModel(id: newId, name: newDhikrName, pressed: 0)
        tasbeehs.append(newTasbeeh)
        saveTasbeehs()
    }
    
    func incrementCounter(for tasbeeh: TasbeehModel) {
        if let index = tasbeehs.firstIndex(where: { $0.id == tasbeeh.id }) {
            tasbeehs[index].pressed += 1
            saveTasbeehs()
        }
    }
    
    private func saveTasbeehs() {
        if let encoded = try? JSONEncoder().encode(tasbeehs) {
            UserDefaults.standard.set(encoded, forKey: "savedTasbeehs")
        }
    }
    
    private func loadTasbeehs() {
        if let savedTasbeehs = UserDefaults.standard.data(forKey: "savedTasbeehs"),
           let decodedTasbeehs = try? JSONDecoder().decode([TasbeehModel].self, from: savedTasbeehs) {
            tasbeehs = decodedTasbeehs
        }
    }
    
    func deleteTasbeeh(at indexSet: IndexSet) {
        tasbeehs.remove(atOffsets: indexSet)
        saveTasbeehs()
    }

    // veya ID ile silmek için alternatif bir fonksiyon:
    func deleteTasbeeh(with id: Int) {
        tasbeehs.removeAll(where: { $0.id == id })
        saveTasbeehs()
    }
}

extension TasbeehViewModel {
    func makeBackButton() {
        coordinator.navigate(to: .main)
    }
}
