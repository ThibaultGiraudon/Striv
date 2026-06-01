//
//  OnBoardingView.swift
//  Striv
//
//  Created by Thibault Giraudon on 31/05/2026.
//

import SwiftUI

struct OnBoardingPage: Identifiable, Hashable {
    let id = UUID()
    
    var image: String
    var title: String
    var description: String
}

extension OnBoardingPage {
    static let pages: [OnBoardingPage] = [
        .init(
            image: "figure.run",
            title: "Bienvenue sur Striv",
            description: "Analyse tes courses, comprends tes performances et atteins tes objectifs."
        ),
        .init(
            image: "chart.line.uptrend.xyaxis",
            title: "Comprends chacune de tes sorties",
            description: "Découvre ton allure, ton volume d'entraînement, tes records et leur évolution dans le temps."
        ),
        .init(
            image: "target",
            title: "Cours vers ton prochain objectif",
            description: "Définis un temps cible sur 5 km, 10 km, semi-marathon ou marathon et suis ta progression."
        ),
        .init(
            image: "brain",
            title: "Des données enfin compréhensibles",
            description: "Grâce aux info-bulles et à l'analyse intelligente, comprends réellement ce que racontent tes performances."
        )
    ]
}

struct OnBoardingView: View {
    
    @AppStorage("hasSeenOnBoarding")
    var hasSeenOnBoarding = false
    
    @State private var currentPage: Int = 0
    private let pages = OnBoardingPage.pages
    
    var body: some View {
        VStack {
            
            header
            
            Spacer()
            
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingCard(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 400)
            cursor

            Spacer()
            
            footer
        }
        .padding()
        .foregroundStyle(.primaryText)
        .background {
            Color.background.ignoresSafeArea()
        }
    }
}

struct OnboardingCard: View {

    let page: OnBoardingPage

    var body: some View {
        VStack(spacing: 32) {

            Image(systemName: page.image)
                .font(.system(size: 100))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 16) {

                Text(page.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

extension OnBoardingView {
    var header: some View {
        HStack {
            Button {
                guard currentPage > 0 else { return }
                
                withAnimation {
                    currentPage -= 1
                }
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title)
            }
            .opacity(currentPage > 0 ? 1 : 0)
            .foregroundStyle(.primaryText)
            
            Spacer()
            
            Button("Passer") {
                hasSeenOnBoarding = true
            }
            .foregroundStyle(.primaryText)
        }
    }
    
    var cursor: some View {
        HStack {
            Spacer()
            ForEach(0..<pages.count, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .foregroundStyle(.teal)
                        .frame(width: 30, height: 10)
                } else {
                    Circle()
                        .foregroundStyle(.secondary)
                        .frame(width: 10, height: 10)
                }
            }
            Spacer()
        }
    }
    
    var footer: some View {
        VStack {
            Button {
                guard currentPage < pages.count - 1 else {
                    hasSeenOnBoarding = true
                    return
                }
                
                withAnimation {
                    currentPage += 1
                }
            } label: {
                HStack {
                    Text(currentPage == pages.count - 1 ? "Terminer" : "Suivant")
                    Image(systemName: "arrow.right")
                }
                    .foregroundStyle(Color.background)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        Capsule()
                            .foregroundStyle(.primaryText)
                    }
            }
        }
    }
}

#Preview {
    OnBoardingView()
}
