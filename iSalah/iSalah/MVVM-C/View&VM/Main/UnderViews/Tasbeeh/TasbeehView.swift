//
//  TasbeehView.swift
//  iSalah
//
//  Created by Mert Türedü on 10.03.2025.
//

import SwiftUI

struct TasbeehView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: TasbeehViewModel
    
    init(_ coordinator: MainCoordinatorPresenter) {
        _vm = StateObject(wrappedValue: TasbeehViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        VStack {
            SettingsHeaderView("Tasbeeh", back: vm.makeBackButton)
            if vm.tasbeehs.isEmpty {
                emptyDhikrView
            } else {
                tasbeehListView
            }
        }
        .overlay(alignment: .bottomTrailing) {
            addButtonView
                .padding(.trailing)
                .offset(y: dw(-0.1))
        }
        .fullScreenCover(isPresented: $vm.isOpenPaywall) {
            PaywallView($vm.isOpenPaywall)
        }
        .alert("Add New Dhikr", isPresented: $vm.showingAddAlert) {
            TextField("Dhikr Name", text: $vm.newDhikrName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                vm.saveDhikr()
            }
        } message: {
            Text("Enter the name of the dhikr you want to count")
        }
        .alert("Premium Required", isPresented: $vm.showingPremiumAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Get Premium") {
                vm.isOpenPaywall.toggle()
            }
        } message: {
            Text("You need a premium subscription to add more than 3 dhikrs")
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        TasbeehView(.init())
    }
    .environmentObject(mockSalah)
}

private extension TasbeehView {
    
    var emptyDhikrView: some View {
        VStack {
            Spacer()
            Text("Add New Dhikr")
                .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .l))
            Text("It seems your dhikr tank is empty.\nPress + for new dhikr.")
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .xs))
                .frame(width: dw(0.68))
            Spacer()
        }
        .multilineTextAlignment(.center)
    }
    
    var tasbeehListView: some View {
        List {
            ForEach(vm.tasbeehs) { tasbeeh in
                tasbeehCard(tasbeeh)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 6)
            }
            .onDelete(perform: vm.deleteTasbeeh)
        }
        .listStyle(PlainListStyle())
        .padding(.horizontal)
    }
    
    func tasbeehCard(_ tasbeeh: TasbeehModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tasbeeh.name)
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .m))
                    .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
                
                Text("Count: \(tasbeeh.pressed)")
                    .font(FontHandler.setNewYorkFont(weight: .semibold, size: .xs))
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            }
            Spacer()
            
            Button {
                vm.incrementCounter(for: tasbeeh)
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
                    Circle()
                        .stroke(ColorHandler.getColor(salah, for: .islam))
                    Text("+")
                        .font(FontHandler.setNewYorkFont(weight: .bold, size: .l))
                        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                }
                .frame(width: dw(0.12), height: dw(0.12))
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(ColorHandler.getColor(salah, for: .islam))
                .shadow(radius: 2)
        }
    }
    
    var addButtonView: some View {
        Button {
            vm.addNewDhikr(isPremium: salah.user.checkIsPremium())
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
                Circle()
                    .stroke(ColorHandler.getColor(salah, for: .islam))
                ImageHandler.getIcon(salah, image: .plusCircle)
                    .scaledToFit()
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .padding()
            }
            .scaledToFit()
            .frame(height: dw(0.19))
        }
    }
}
