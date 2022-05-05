//
//  LanguageManager.swift
//  Texty
//
//  Created by Jeslin Yeoh on 08/03/2022.
//  This class parses a sentence into a word array and translates those words to English if there are other languages (eg. Chinese, Malay, Indonesian, Tamil) identified.

import Foundation
import NaturalLanguage
import MLKitLanguageID
import MLKitTranslate

class LanguageManager {
    
    let tokenizer = NLTokenizer(unit: .word)
    
    let options = LanguageIdentificationOptions(confidenceThreshold: 0.4)
    let CNtoENoptions = TranslatorOptions(sourceLanguage: .chinese, targetLanguage: .english)
    let MStoENoptions = TranslatorOptions(sourceLanguage: .malay, targetLanguage: .english)
    let IDtoENoptions = TranslatorOptions(sourceLanguage: .indonesian, targetLanguage: .english)
    let TMtoENoptions = TranslatorOptions(sourceLanguage: .tamil, targetLanguage: .english)
    
    var chineseEnglishTranslator: Translator!
    var malayEnglishTranslator: Translator!
    var indonesianEnglishTranslator: Translator!
    var tamilEnglishTranslator: Translator!
    
    public static var shared = LanguageManager()
    
    init() {
        chineseEnglishTranslator = Translator.translator(options: CNtoENoptions)
        malayEnglishTranslator = Translator.translator(options: MStoENoptions)
        indonesianEnglishTranslator = Translator.translator(options: IDtoENoptions)
        tamilEnglishTranslator = Translator.translator(options: TMtoENoptions)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        
        chineseEnglishTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        
        malayEnglishTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        
        indonesianEnglishTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        
        tamilEnglishTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        
    }
    
    
    /// Tokenise the sentence into a word array
    public func tokeniseSentence(sentence: String) -> [String]{

        var words: [String] = []
        tokenizer.string = sentence
        
        tokenizer.enumerateTokens(in: sentence.startIndex..<sentence.endIndex) { tokenRange, _ in

            words.append(String(sentence[tokenRange]))
            return true
        }
        
        return words
    }
    
    /// Take an array of words as an input and output the language of each word
    private func getLanguage(words: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        
        let languageId = LanguageIdentification.languageIdentification(options: options)
        var languageIDs: [String] = []
        
        var count = 1
        
        for word in words {

            languageId.identifyLanguage(for: word) { (languageCode, error) in

                if let error = error {
                    print("Failed with error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let languageCode = languageCode, languageCode != "und" {
                    //print("\(word) - Identified Language: \(languageCode)")
                    languageIDs.append(languageCode)

                }
                
                else {
                    //print("\(word) - No language was identified")
                    languageIDs.append("NA")
                }
                
                
                if count == words.count {
                    completion(.success(languageIDs))
                }
                
                count += 1
            }
            
            print(languageIDs)
        }
 
    }
        
    
    /// Takes in an array of words and combines words with same language ID
    /// returns an array of combined words
    private func combineSameLanguageWords(words: [String], languageIDs: [String]) -> [String]{
        
        var temp = words[0]
        var words2 : [String] = []
        var count = 0
        
        for _ in words {
            
            if count == words.count - 1{
                words2.append(temp)
                break
            }

            
            if languageIDs[count] == languageIDs[count+1] {
                temp = temp + " " + words[count+1]
            }
            
            else {
                words2.append(temp)
                temp = words[count+1]
            }
            
            count += 1
        }
        
        return words2
    }
    
    
    /// Get language id for each word in the sentence
    public func translateLanguage(sentence: String, completion: @escaping (Result<[String], Error>) -> Void) {
        
        let words = tokeniseSentence(sentence: sentence)

        
        getLanguage(words: words, completion: { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            
            switch result {
            case.failure(let error):
                print("Language Translator error: \(error)")
                completion(.failure(error))
                
            case .success(let languageIDs):
                
                let checkedIDs = strongSelf.handleChineseInterjection(words: words, languageIDs: languageIDs)
                let combinedWords = strongSelf.combineSameLanguageWords(words: words, languageIDs: checkedIDs)
                //print("languageIDs : \(languageIDs)")
                //print("combinedWords: \(combinedWords)")
                
                
                strongSelf.getLanguage(words: combinedWords, completion: { [weak self] result in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    
                    switch result {
                    case.failure(let error):
                        print("Language Translator error 2: \(error)")
                        completion(.failure(error))
                        
                    case .success(let languageIDs2):

                        let combinedWords2 = strongSelf.combineSameLanguageWords(words: combinedWords, languageIDs: languageIDs2)
                        
                        //print("languageIDs 2: \(languageIDs2)")
                        //print("combinedWords 2: \(combinedWords2)")
                        
                        strongSelf.translateWords(words: combinedWords2, languageIDs: languageIDs2, completion: { translatedWords in
                            
                            completion(.success(translatedWords))
                        })

                    }
                })
            
            }
        })
        
    }
    
    
    /// Translates other language phrases in a word array to English
    private func translateWords(words: [String], languageIDs: [String], completion: @escaping ([String]) -> Void) {
                
        var count = 0
        var translatedWords: [String] = []
        
        
        for _ in words {

            //print("count: \(count), words.count: \(words.count)")
            //print("languageID for \(count): \(languageIDs[count])")
            
            if languageIDs[count] == "en" {
                translatedWords.append(words[count])
                count += 1
                
                if count == words.count {
                    completion(translatedWords)
                }
                
                continue
            }
            
            if languageIDs[count] == "zh" {
                translateChinese(word: words[count], completion: { translatedText in
                    translatedWords.append(translatedText)
                    //print("translated text (zh): \(translatedText)")
                    count += 1
                    
                    if count == words.count {
                        completion(translatedWords)
                    }
                })
            }
            
            else if languageIDs[count] == "ms" {
                translateMalay(word: words[count], completion: { translatedText in
                    translatedWords.append(translatedText)
                    //print("translated text (ms): \(translatedText)")
                    count += 1
                    
                    if count == words.count {
                        completion(translatedWords)
                    }
                })
            }
            
            else if languageIDs[count] == "id" {
                translateIndonesian(word: words[count], completion: { translatedText in
                    translatedWords.append(translatedText)
                    //print("translated text (id): \(translatedText)")
                    count += 1
                    
                    if count == words.count {
                        completion(translatedWords)
                    }
                })
            }
            
            else if languageIDs[count] == "ta" {
                translateTamil(word: words[count], completion: { translatedText in
                    translatedWords.append(translatedText)
                    //print("translated text (hi): \(translatedText)")
                    count += 1
                    
                    if count == words.count {
                        completion(translatedWords)
                    }
                })
            }
            
            else {
                translatedWords.append(words[count])
                count += 1
                
                if count == words.count {
                    completion(translatedWords)
                }
            }
            
        
        }
        
        
    }
    
    
    private func translateChinese(word: String, completion: @escaping (String) -> Void) {
        
        chineseEnglishTranslator.translate(word) { translatedText, error in
            guard error == nil, let translatedText = translatedText else { return }
            
            completion(translatedText)
        }
    }
    
    
    private func translateMalay(word: String, completion: @escaping (String) -> Void) {
        
        malayEnglishTranslator.translate(word) { translatedText, error in
            guard error == nil, let translatedText = translatedText else { return }
            
            completion(translatedText)
        }
    }
    
    
    private func translateIndonesian(word: String, completion: @escaping (String) -> Void) {
        
        indonesianEnglishTranslator.translate(word) { translatedText, error in
            guard error == nil, let translatedText = translatedText else { return }
            
            completion(translatedText)
        }
    }

    private func translateTamil(word: String, completion: @escaping (String) -> Void) {
        
        tamilEnglishTranslator.translate(word) { translatedText, error in
            guard error == nil, let translatedText = translatedText else { return }
            
            completion(translatedText)
        }
    }
    
    private func handleChineseInterjection(words: [String], languageIDs: [String]) -> [String]{
        
        var count = 0
        var langIDs = languageIDs
        
        for _ in words {
            
            if words[count] == "了" || words[count] == "么" || words[count] == "呢" || words[count] == "吧" || words[count] == "啊" || words[count] == "啦" || words[count] == "吗" || words[count] == "呀" || words[count] == "的" {
                
                langIDs[count] = "zh"
            }
            
            count += 1
        }

        return langIDs
    }
}
