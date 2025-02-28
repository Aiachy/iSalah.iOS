//
//  SearchLocationViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import Foundation
import CoreLocation
import Combine
import MapKit


// NSObject'ten türetilmeli
class SearchLocationViewModel: NSObject, ObservableObject {
    // MARK: - Published properties
    @Published var searchText: String = ""
    @Published var popularLocations: [LocationSuggestion] = []
    @Published var filteredLocations: [LocationSuggestion] = []
    @Published var isLoading: Bool = false
    @Published var userCurrentLocation: LocationInfo? = nil
    @Published var searchCompletions: [MKLocalSearchCompletion] = []
    @Published var hasMoreResults: Bool = false
    
    // MARK: - Private properties
    private let locationManager = LocationManager()
    private var searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var currentSearchQuery: String = ""
    private var allSearchResults: [LocationSuggestion] = []
    private var currentPageIndex: Int = 0
    private let pageSize: Int = 10
    private let debounceTime: TimeInterval = 0.75 // Arama için bekleme süresi (750ms)
    private var isSearchInProgress = false
    
    // Farklı dillerde ülke isimlerini tanımak için sözlük
    private let countryNameMap: [String: String] = [
        // Türkçe - İngilizce
        "türkiye": "Türkiye", "turkey": "Türkiye",
        "abd": "United States", "amerika": "United States", "amerika birleşik devletleri": "United States",
        "ingiltere": "United Kingdom", "birleşik krallık": "United Kingdom",
        "almanya": "Germany", "fransa": "France", "ispanya": "Spain", "italya": "Italy",
        "çin": "China", "japonya": "Japan", "hindistan": "India", "brezilya": "Brazil",
        "rusya": "Russia", "kanada": "Canada", "avustralya": "Australia", "mısır": "Egypt",
        "suudi arabistan": "Saudi Arabia", "birleşik arap emirlikleri": "United Arab Emirates", "bae": "United Arab Emirates",
        "güney afrika": "South Africa", "nijerya": "Nigeria", "meksika": "Mexico"
    ]
    
    private let popularCountries = [
        "Türkiye", "United States", "United Kingdom", "Germany", "France",
        "Spain", "Italy", "China", "Japan", "India", "Brazil", "Russia",
        "Canada", "Australia", "Egypt", "Saudi Arabia", "United Arab Emirates",
        "South Africa", "Nigeria", "Mexico"
    ]
    
    // MARK: - Init
    override init() {
        super.init()
        setupSearchCompleter()
        setupBindings()
        loadInitialData()
    }
    
    deinit {
        searchTask?.cancel()
    }
    
    // MARK: - Public methods
    
    func loadInitialData() {
        getUserLocation()
    }
    
    func getUserLocation() {
        isLoading = true
        
        locationManager.getUserLocation { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let locationInfo):
                    self.userCurrentLocation = locationInfo
                    
                    // Eğer özel bir arama yoksa, kullanıcının ülkesindeki popüler şehirleri getir
                    if self.searchText.isEmpty {
                        if let country = locationInfo.country {
                            self.loadPopularLocationsFor(country: country)
                        } else {
                            self.loadPopularLocations()
                        }
                    }
                case .failure(_):
                    // Hata mesajını gösterme, sadece konum bilgisi olmadan devam et
                    self.loadPopularLocations()
                }
            }
        }
    }
    
    func searchForCountry(_ countryName: String) {
        performSearch(query: countryName, isInitialLoad: true)
    }
    
    // Daha fazla sonuç yükleme (sonsuz kaydırma)
    func loadMoreResults() {
        guard hasMoreResults, !isSearchInProgress else { return }
        
        currentPageIndex += 1
        let startIndex = currentPageIndex * pageSize
        let endIndex = min(startIndex + pageSize, allSearchResults.count)
        
        guard startIndex < allSearchResults.count else {
            hasMoreResults = false
            return
        }
        
        let nextPageItems = Array(allSearchResults[startIndex..<endIndex])
        filteredLocations.append(contentsOf: nextPageItems)
        
        hasMoreResults = endIndex < allSearchResults.count
    }
    
    // MARK: - Private methods
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        
        // Daha geniş arama sonuçları için region'ı maximal tut
        searchCompleter.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        )
    }
    
    private func setupBindings() {
        // Arama metni değiştiğinde arama yapma (debounce ile)
        $searchText
            .removeDuplicates()
            .debounce(for: .seconds(debounceTime), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                
                if query.isEmpty {
                    self.resetSearch()
                    
                    // Kullanıcının konumu varsa ona göre, yoksa popüler lokasyonları göster
                    if let country = self.userCurrentLocation?.country {
                        self.loadPopularLocationsFor(country: country)
                    } else {
                        self.loadPopularLocations()
                    }
                    return
                }
                
                // Minimum 2 karakter varsa arama yap
                if query.count >= 2 {
                    self.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    private func resetSearch() {
        searchTask?.cancel()
        currentPageIndex = 0
        allSearchResults = []
        filteredLocations = []
        searchCompletions = []
        isSearchInProgress = false
        hasMoreResults = false
    }
    
    // Popüler lokasyonları yükle (ülkesiz)
    private func loadPopularLocations() {
        isLoading = true
        
        // Dünya genelinden popüler şehirler için aramalar yap
        let popularCities = ["Istanbul", "New York", "London", "Paris", "Tokyo", "Dubai"]
        
        let randomCities = popularCities.shuffled().prefix(3)
        
        var allResults: [LocationSuggestion] = []
        let dispatchGroup = DispatchGroup()
        
        for city in randomCities {
            dispatchGroup.enter()
            
            simpleCitySearch(city) { results in
                allResults.append(contentsOf: results.prefix(3))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if !allResults.isEmpty {
                self.allSearchResults = allResults.shuffled()
                self.updateFilteredLocations()
            } else {
                // Son çare - sabit gömülü veriler
                self.loadHardcodedLocations()
            }
        }
    }
    
    // Belirli bir ülke için popüler lokasyonları yükle
    private func loadPopularLocationsFor(country: String) {
        isLoading = true
        
        // Ülke araması yap
        simpleCitySearch(country) { [weak self] results in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if !results.isEmpty {
                    let cityResults = results.filter { $0.country == country }
                    if !cityResults.isEmpty {
                        self.allSearchResults = cityResults
                    } else {
                        self.allSearchResults = results
                    }
                    self.updateFilteredLocations()
                } else {
                    // Popüler lokasyonları yükle
                    self.loadPopularLocations()
                }
            }
        }
    }
    
    // Son çare: Sabit kodlanmış lokasyonlar
    private func loadHardcodedLocations() {
        let hardcodedLocations: [LocationSuggestion] = [
            LocationSuggestion(
                country: "Türkiye",
                city: "Istanbul",
                district: "nil",
                coordinate: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
            ),
            LocationSuggestion(
                country: "Türkiye",
                city: "Ankara",
                district: "nil",
                coordinate: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597)
            ),
            LocationSuggestion(
                country: "Türkiye",
                city: "Izmir",
                district: "nil",
                coordinate: CLLocationCoordinate2D(latitude: 38.4192, longitude: 27.1287)
            ),
            LocationSuggestion(
                country: "United States",
                city: "New York",
                district: "Manhattan",
                coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            ),
            LocationSuggestion(
                country: "United Kingdom",
                city: "London",
                district: "nil",
                coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
            )
        ]
        
        self.allSearchResults = hardcodedLocations
        self.updateFilteredLocations()
    }
    
    // Basit şehir araması (hata ayıklama ve güvenlik için optimize edildi)
    private func simpleCitySearch(_ query: String, completion: @escaping ([LocationSuggestion]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Global region ile arama yapalım
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            var results: [LocationSuggestion] = []
            
            guard let response = response, !response.mapItems.isEmpty else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            for item in response.mapItems {
                let placemark = item.placemark
                
                // Güvenli veri çıkarımı
                let country = placemark.country ?? "Unknown"
                
                var city = "Unknown"
                if let adminArea = placemark.administrativeArea, !adminArea.isEmpty {
                    city = adminArea
                } else if let locality = placemark.locality, !locality.isEmpty {
                    city = locality
                }
                
                var district: String? = nil
                if let locality = placemark.locality,
                   !locality.isEmpty,
                   locality != placemark.administrativeArea {
                    district = locality
                } else if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                    district = subLocality
                }
                
                // Geçerli sonuç ise ekle
                if country != "Unknown" && city != "Unknown" {
                    let suggestion = LocationSuggestion(
                        country: country,
                        city: city,
                        district: district ?? "",
                        coordinate: placemark.coordinate
                    )
                    
                    if !results.contains(suggestion) {
                        results.append(suggestion)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    private func performSearch(query: String, isInitialLoad: Bool = false) {
        guard !isSearchInProgress else { return }
        
        // Mevcut arama iptal edilir
        searchTask?.cancel()
        isSearchInProgress = true
        isLoading = true
        
        if isInitialLoad {
            resetSearch()
        }
        
        currentSearchQuery = query
        
        // Arama başlatılır
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                // Geniş bir arama yapalım
                let results = await self.searchWithQuery(query: query)
                
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.isLoading = false
                    self.isSearchInProgress = false
                    
                    if !results.isEmpty {
                        self.allSearchResults = results
                        self.updateFilteredLocations()
                    } else {
                        // Hiç sonuç yoksa, benzer terimlerle aramayı dene
                        self.searchForSimilarTerms(query: query)
                    }
                }
            } catch {
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.isLoading = false
                    self.isSearchInProgress = false
                    self.loadHardcodedLocations()
                    print("performSearch error: \(error)")
                }
            }
        }
    }
    
    private func searchWithQuery(query: String) async -> [LocationSuggestion] {
        // Farklı dilde yazılmış olabilecek ülke isimlerini kontrol et
        var searchQuery = query
        let queryLower = query.lowercased()
        
        if let mappedCountry = countryNameMap[queryLower] {
            searchQuery = mappedCountry
        }
        
        return await withCheckedContinuation { continuation in
            simpleCitySearch(searchQuery) { results in
                continuation.resume(returning: results)
            }
        }
    }
    
    private func searchForSimilarTerms(query: String) {
        // Benzer ülke isimleri için popüler ülkeleri kontrol et
        let queryLower = query.lowercased()
        var matchingCountries: [String] = []
        
        // Her popüler ülkeyi kontrol et
        for country in self.popularCountries {
            if country.lowercased().contains(queryLower) {
                matchingCountries.append(country)
            }
        }
        
        // Eşleşen ülkelerin popüler şehirlerini ekle
        if !matchingCountries.isEmpty {
            var allResults: [LocationSuggestion] = []
            let group = DispatchGroup()
            
            for country in matchingCountries.prefix(2) {
                group.enter()
                
                // Her ülke için popüler şehirleri bul
                simpleCitySearch(country) { results in
                    allResults.append(contentsOf: results.prefix(5))
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                
                if !allResults.isEmpty {
                    self.allSearchResults = allResults
                    self.updateFilteredLocations()
                } else {
                    self.loadHardcodedLocations()
                }
            }
        } else {
            // Son çare - sabit gömülü veriler
            loadHardcodedLocations()
        }
    }
    
    private func updateFilteredLocations() {
        let endIndex = min(pageSize, allSearchResults.count)
        
        if endIndex > 0 {
            filteredLocations = Array(allSearchResults[0..<endIndex])
            hasMoreResults = allSearchResults.count > pageSize
        } else {
            filteredLocations = []
            hasMoreResults = false
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension SearchLocationViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completion error: \(error.localizedDescription)")
    }
}
