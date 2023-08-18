//
//  ContentView.swift
//  WordScramble
//
//  Created by Dominique Strachan on 8/15/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorShown = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            Form {
                VStack(spacing: 20) {
                    
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    List {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                    .foregroundColor(.teal)
                                Text(word)
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.teal)
                                
                                Spacer()
                            }
                        }
                        
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Score: \(score)")
                            .font(.title2)
                        
                        Spacer()
                    }
                }
            }
            
            .navigationTitle(rootWord)
            .toolbar {
                Button("restart", action: restartGame)
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $errorShown) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Type a new word!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell \(answer) from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Must be a real word.")
            return
        }
        
        guard isNotStartWord(word: answer)  else {
            wordError(title: "Same as start word", message: "Can not use start word as an answer")
            return
        }
        
        guard isNotOneLetter(word: answer) else {
            wordError(title: "Not long enough", message: "Can not submit one letter words")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        determineScore(word: answer)
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "word"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        //usedWords does not contain word then return true
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let letterAtIndex = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: letterAtIndex)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        //convert string as comparable to Objective-C string
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        //NSNotFound means no misspelled words found
        return misspelledRange.location == NSNotFound
    }
    
    func isNotStartWord(word: String) -> Bool {
        word != rootWord
    }
    
    func isNotOneLetter(word: String) -> Bool {
        word.count != 1
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        errorShown = true
    }
    
    func determineScore(word: String) {
        score += 1
        
        if word.count == 2 {
            score += 1
        } else if word.count <= 4 {
            score += 2
        } else {
            score += 3
        }
    }
    
    func restartGame() {
        startGame()
        usedWords = []
        score = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
