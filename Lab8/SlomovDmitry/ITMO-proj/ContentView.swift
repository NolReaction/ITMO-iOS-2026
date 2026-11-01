//
//  ContentView.swift
//  ITMO-proj
//
//  Created by Дмитрий Сломов on 10.09.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Лабораторные работы") {
                    NavigationLink("Лабораторная 1: Задания") { Lab1View() }
                    NavigationLink("Лабораторная 2: Случайное число") { Lab2View() }
                    NavigationLink("Лабораторная 3: MVVM") { Lab3View() }
                    NavigationLink("Лабораторная 4: Хранение данных") { Lab4View() }
                    NavigationLink("Lab 5: Многопоточность") { Lab5View() }
                    NavigationLink("Lab 6: Сеть") { Lab6View() }
                }

                Section("Проект") {
                    NavigationLink("WatchNext: Фильмы и сериалы") {
                        WatchNextView()
                    }
                }
            }
            .navigationTitle("Лабораторные и проект")
        }
    }
}
