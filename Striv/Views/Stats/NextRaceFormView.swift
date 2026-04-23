//
//  NextRaceFormView.swift
//  Striv
//
//  Created by Thibault Giraudon on 20/04/2026.
//

import SwiftUI

struct NextRaceFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var nextRaceVM: NextRaceViewModel
    @State private var date: Date = .now
    @State private var title: String = "Marathon de Paris"
    
    var shouldDisable: Bool {
        title.isEmpty
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Prochaine course")
                .font(.title.bold())
            
            Divider()
            
            Text("Rajoute la date de ta prochaine course.")
            Text("Un décompte sera visible sur l'accueil de l'application afin de booster ta motivation.")
            
            Divider()
                .padding(.vertical)
            
            DatePicker("Date", selection: $date, in: Date.now..., displayedComponents: .date)
            TextField("Intitulé (ex: Marathon de....)", text: $title)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text(date.formatted(format: "dd MMMM yyyy"))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.title.bold())
                HStack(spacing: 0) {
                    Text("dans ")
                    Text(nextRaceVM.formatTime(for: date))
                        .foregroundStyle(.teal)
                        .fontWeight(.bold)
                    Spacer()
                }
                .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.customPrimary)
            }
            .foregroundStyle(Color.primaryText)
            
            Spacer()
            
            Button {
                nextRaceVM.setDate(date)
                nextRaceVM.setTitle(title)
                dismiss()
            } label: {
                Text("Enregistrer")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.teal.opacity(shouldDisable ? 0.5 : 1))
                    }
            }
            .disabled(shouldDisable)
            
            if !nextRaceVM.title.isEmpty {
                Button {
                    nextRaceVM.setDate(.now)
                    nextRaceVM.setTitle("")
                    date = .now
                    title = ""
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Supprimer")
                    }
                    .font(.title.bold())
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 2)
                            .fill(.red)
                    }
                }
            }
        }
        .onAppear {
            self.date = nextRaceVM.date
            self.title = nextRaceVM.title
        }
        .padding()
        .foregroundStyle(Color.primaryText)
        .background {
            Color.background
                .ignoresSafeArea()
        }
    }
}

#Preview {
    NextRaceFormView(nextRaceVM: .init())
}
