//
//  ShareView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/06/2026.
//

import SwiftUI
import MapKit

enum ShareTab: String, CaseIterable {
    case path = "Carte"
    case data = "Données"
    case both = "Complet"
}

struct RunShareCarouselView: View {

    let workout: Workout

    @State private var selectedExport: ShareTab = .path
    @State private var selectedColor: Color = .white
    @State private var showColorPicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Exporter un rendu")
                            .font(.title.bold())
                        Text("Choisis le type de rendu à télécharger")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                // MARK: - CAROUSEL CARD
                
                SegmentedPicker(items: ShareTab.allCases, title: { $0.rawValue }, selection: $selectedExport, size: 10)
                
                VStack {
                    switch selectedExport {
                    case .path:
                        RunMapShareView(workout: workout, color: $selectedColor)
                    case .data:
                        RunStatsShareView(workout: workout, color: $selectedColor)
                    case .both:
                        RunMapAndStatShareView(workout: workout, color: $selectedColor)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.customPrimary)
                }
                
                // MARK: - ACTIONS
                VStack(spacing: 12) {
                    
                    ColorPicker("Couleur du rendu", selection: $selectedColor)
                    
                    Button {
                        exportCurrentPage()
                    } label: {
                        Label("Exporter en PNG", systemImage: "square.and.arrow.down")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(5)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("L'image sera enregistrée dans votre galerie")
                        .foregroundStyle(.secondary)
                        .font(.footnote)

                }
            }
        }
        .padding()
    }
}

extension RunShareCarouselView {

    @MainActor
    func exportCurrentPage() {

        let view = currentView().frame(width: 350, height: 500)

        let renderer = ImageRenderer(content: view)

        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = false

        savePngImage(originalImage: renderer.uiImage)
    }

    func savePngImage(originalImage: UIImage?) {
        guard let originalImage,
              let ciImage = CIImage(image: originalImage),
              let data = UIImage(ciImage: ciImage).pngData(),
              let saveImage = UIImage(data: data) else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil, nil)
    }
    
    @ViewBuilder
    func currentView() -> some View {
        switch selectedExport {
        case .path:
            RunMapShareView(workout: workout, color: $selectedColor)

        case .data:
            RunStatsShareView(workout: workout, color: $selectedColor)

        default:
            RunMapAndStatShareView(workout: workout, color: $selectedColor)
        }
    }
}


#Preview {
    RunShareCarouselView(workout: .init(id: UUID(), date: .now, duration: .init(3600)))
}
