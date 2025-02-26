//
//  SearchLocationView.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI
import CoreLocation

struct SearchLocationView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: SearchLocationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollPosition: Int?
    let result: (LocationSuggestion) -> ()
    
    init(result: @escaping (LocationSuggestion) -> ()) {
        _vm = StateObject(wrappedValue: SearchLocationViewModel())
        self.result = result
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 16) {
                headerView
                
                // Yükleniyor göstergesi
                if vm.isLoading {
                    VStack {
                        ProgressView()
                            .tint(ColorHandler.getColor(salah, for: .gold))
                            .scaleEffect(1.2)
                            .padding()
                        
                        Text("Searching locations...")
                            .font(FontHandler.setDubaiFont(weight: .medium, size: .xs))
                            .foregroundColor(ColorHandler.getColor(salah, for: .light))
                    }
                    .frame(height: 100)
                } else {
                    locationListView
                }
                
                Spacer()
            }
            .padding(.top)
          
        }
        .environmentObject(salah)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        SearchLocationView { _ in }
    }
        .environmentObject(mockSalah)
}

//MARK: Header
extension SearchLocationView {
    
    var headerView: some View {
        HStack {
            searchView
            getLocationView
        }
    }
    
    var searchView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke()
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))

            HStack {
                ImageHandler.getIcon(salah, image: .magnifyingGlass)
                    .scaledToFit()
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .opacity(vm.searchText.isEmpty ? 0.3 : 1)
                    .frame(height: dh(0.03))
                    .padding(.horizontal,10)
                    
                
                TextField("Search Country, City or District", text: $vm.searchText)
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .tint(ColorHandler.getColor(salah, for: .gold))
                    .font(FontHandler.setDubaiFont(weight: .regular, size: .s))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                
                if !vm.searchText.isEmpty {
                    Button(action: {
                        vm.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                            .opacity(0.6)
                    }
                    .padding(.trailing, 10)
                }
            }
        }
        .frame(width: dw(0.8), height: dh(0.05))
    }
 
    var getLocationView: some View {
        Button(action: {
            vm.getUserLocation()
        }) {
            Circle()
                .fill(ColorHandler.getColor(salah, for: .gold))
                .overlay {
                    ImageHandler.getIcon(salah, image: .location)
                        .scaledToFit()
                        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                        .padding(8)
                }
                .frame(width: dw(0.1))
        }
    }
}

//MARK: Location
extension SearchLocationView {
    
    var locationListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if let userLocation = vm.userCurrentLocation {
                        Section {
                            currentLocationRow(userLocation)
                                .id(0)
                        }
                    }
                    
                    if vm.filteredLocations.isEmpty && vm.searchText.isEmpty {
                        Section {
                            initialView
                        }
                    } else if vm.filteredLocations.isEmpty {
                        Section {
                            noResultsView
                        }
                    } else {
                        Section {
                            ForEach(Array(vm.filteredLocations.enumerated()), id: \.element.id) { index, location in
                                locationRow(location)
                                    .id(index + 1)
                                    .onAppear {
                                        if index == vm.filteredLocations.count - 3 && vm.hasMoreResults {
                                            vm.loadMoreResults()
                                        }
                                    }
                            }
                            
                            // Daha fazla sonuç yükleniyor göstergesi
                            if vm.hasMoreResults {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .tint(ColorHandler.getColor(salah, for: .gold))
                                        .scaleEffect(0.8)
                                    Spacer()
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .onChange(of: scrollPosition) { _, newValue in
                    if let position = newValue {
                        withAnimation(.smooth) {
                            proxy.scrollTo(position, anchor: .top)
                        }
                    }
                }
            }
            .frame(height: dh(0.6))
        }
    }
    
    // Başlangıç görünümü
    var initialView: some View {
        VStack(spacing: 16) {
            if vm.popularLocations.isEmpty {
                Image(systemName: "globe")
                    .font(.system(size: 50))
                    .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.3))
                    .padding(.top, 40)
                
                Text("Type to search")
                    .font(FontHandler.setDubaiFont(weight: .medium, size: .m))
                    .foregroundColor(ColorHandler.getColor(salah, for: .light))
                
                Text("Search for any country, city or district")
                    .font(FontHandler.setDubaiFont(weight: .light, size: .s))
                    .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("Popular Locations")
                    .font(FontHandler.setDubaiFont(weight: .bold, size: .m))
                    .foregroundColor(ColorHandler.getColor(salah, for: .gold))
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Popüler lokasyon listesi (mevcut ülkede veya dünya genelinde)
                ForEach(vm.popularLocations) { location in
                    locationRow(location)
                }
            }
        }
    }
    
    // Kullanıcının mevcut konum satırı
    func currentLocationRow(_ location: LocationInfo) -> some View {
        Button(action: {
            // Kullanıcının mevcut konumunu seç
            if let city = location.city, let country = location.country {
                let userLocation = LocationSuggestion(
                    country: country,
                    city: city,
                    district: location.district,
                    coordinate: location.coordinate
                )
                result(userLocation)
                dismiss()
            }
        }) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(ColorHandler.getColor(salah, for: .gold))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Location")
                        .font(FontHandler.setDubaiFont(weight: .bold, size: .s))
                        .foregroundColor(ColorHandler.getColor(salah, for: .gold))
                    
                    Text(formatCurrentLocation(location))
                        .font(FontHandler.setDubaiFont(weight: .regular, size: .xs))
                        .foregroundColor(ColorHandler.getColor(salah, for: .light))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.5))
            }
            .padding()
        }
        .background(ColorHandler.getColor(salah, for: .gold).opacity(0.3))
        .cornerRadius(8)
        .padding(.top, 8)
    }
    
    // Lokasyon satırı
    func locationRow(_ location: LocationSuggestion) -> some View {
        Button(action: {
            result(location)
            dismiss()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(location.city)
                            .font(FontHandler.setDubaiFont(weight: .medium, size: .m))
                            .foregroundColor(ColorHandler.getColor(salah, for: .light))
                        
                        if let district = location.district, !district.isEmpty {
                            Text("•")
                                .font(FontHandler.setDubaiFont(weight: .regular, size: .s))
                                .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.7))
                            
                            Text(district)
                                .font(FontHandler.setDubaiFont(weight: .regular, size: .s))
                                .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.7))
                        }
                    }
                    
                    Text(location.country)
                        .font(FontHandler.setDubaiFont(weight: .light, size: .xxs))
                        .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.5))
            }
            .padding()
        }
        .background(ColorHandler.getColor(salah, for: .gold).opacity(0.1))
        .cornerRadius(8)
        .padding(.vertical, 6)
    }
    
    // Sonuç bulunamadı görünümü
    var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.3))
                .padding(.top, 40)
            
            Text("No locations found")
                .font(FontHandler.setDubaiFont(weight: .medium, size: .m))
                .foregroundColor(ColorHandler.getColor(salah, for: .light))
            
            Text("Try searching for a different location")
                .font(FontHandler.setDubaiFont(weight: .light, size: .s))
                .foregroundColor(ColorHandler.getColor(salah, for: .light).opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 40)
        }
        .frame(height: dh(0.3))
    }
    
    // Mevcut konumu formatlama
    func formatCurrentLocation(_ location: LocationInfo) -> String {
        var components: [String] = []
        
        if let district = location.district, !district.isEmpty {
            components.append(district)
        }
        
        if let city = location.city, !city.isEmpty {
            components.append(city)
        }
        
        if let country = location.country, !country.isEmpty {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
}
