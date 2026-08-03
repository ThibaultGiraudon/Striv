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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Prochaine course")
                .font(.title.bold())
            
            Divider()
            
            Text("Rajoute la date de ta prochaine course.")
            Text("Un décompte sera visible sur l'accueil de l'application afin de booster ta motivation.")
            
            Divider()
                .padding(.vertical)
            
            VStack {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title)
                        .foregroundStyle(.customPink)
                        .cardStyle()
                    DatePicker(selection: $date, in: Date.now..., displayedComponents: .date) {
                        VStack(alignment: .leading) {
                            Text("Date")
                            Text("Choisis la date de ta course")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                HStack {
                    Image(systemName: "flag.fill")
                        .font(.title)
                        .foregroundStyle(.customPink)
                        .cardStyle()
                    VStack(alignment: .leading) {
                        Text("Intitulé")
                        Text("Optionnel")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    TextField("ex: Marathon de Paris", text: $title)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule()
                                .fill(.customPrimary.opacity(0.6))
                                .stroke(.customPrimary, lineWidth: 1)
                        }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.thinMaterial)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text(date.formatted(format: "dd MMMM yyyy"))
                    .foregroundStyle(.secondary)
                Text("\(title.isEmpty ? "Prochaine course" : title)")
                    .font(.title.bold())
                HStack(spacing: 0) {
                    Text("dans ")
                    Text(nextRaceVM.formatTime(for: date))
                        .foregroundStyle(.customPink)
                        .fontWeight(.bold)
                    Spacer()
                }
                .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .cardStyle()
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
                    .cardStyle(.customPink)
            }
            
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
            if nextRaceVM.date.timeIntervalSinceNow < 0 {
                self.date = .now
            }
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
