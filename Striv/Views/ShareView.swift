//
//  ShareView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/06/2026.
//

import SwiftUI
import MapKit

import SwiftUI

struct RunShareCarouselView: View {

    let workout: Workout

    @State private var selectedPage = 0
    @State private var selectedColor: Color = .white
    @State private var showColorPicker = false

    var body: some View {

        VStack(spacing: 16) {

            // MARK: - CAROUSEL CARD
            TabView(selection: $selectedPage) {

                RunMapShareView(workout: workout, color: .constant(.primaryText))
                    .tag(0)
                    .frame(width: 350, height: 500)

                RunStatsShareView(workout: workout, color: .constant(.primaryText))
                    .tag(1)
                    .frame(width: 350, height: 500)

                RunMapAndStatShareView(workout: workout, color: .constant(.primaryText))
                    .tag(2)
                    .frame(width: 350, height: 500)
            }
            .frame(width: 350, height: 500)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.customPrimary)
            }
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

            // MARK: - ACTIONS
            VStack(spacing: 12) {

                Button {
                    exportCurrentPage()
                } label: {
                    Text("Exporter le rendu")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(5)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)


                // MARK: - EXPANDED COLOR PICKER
                ColorPicker("Couleur du rendu", selection: $selectedColor)
            }
            .padding(.horizontal)
        }
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
        switch selectedPage {
        case 0:
            RunMapShareView(workout: workout, color: $selectedColor)

        case 1:
            RunStatsShareView(workout: workout, color: $selectedColor)

        default:
            RunMapAndStatShareView(workout: workout, color: $selectedColor)
        }
    }
}


#Preview {
    RunShareCarouselView(workout: .init(id: UUID(), date: .now, duration: .init(3600)))
}
