//
//  SlangsManager.swift
//  Texty
//
//  Created by Jeslin Yeoh on 06/03/2022.
//

import Foundation
import NaturalLanguage

class SlangsManager {
    
    public static var shared = SlangsManager()
    
    public var aSlangs = [String: String]()
    public var bSlangs = [String: String]()
    public var cSlangs = [String: String]()
    public var dSlangs = [String: String]()
    public var eSlangs = [String: String]()
    public var fSlangs = [String: String]()
    public var gSlangs = [String: String]()
    public var hSlangs = [String: String]()
    public var iSlangs = [String: String]()
    public var jSlangs = [String: String]()
    public var kSlangs = [String: String]()
    public var lSlangs = [String: String]()
    public var mSlangs = [String: String]()
    public var nSlangs = [String: String]()
    public var oSlangs = [String: String]()
    public var pSlangs = [String: String]()
    public var qSlangs = [String: String]()
    public var rSlangs = [String: String]()
    public var sSlangs = [String: String]()
    public var tSlangs = [String: String]()
    public var uSlangs = [String: String]()
    public var vSlangs = [String: String]()
    public var wSlangs = [String: String]()
    public var xSlangs = [String: String]()
    public var ySlangs = [String: String]()
    public var zSlangs = [String: String]()

    
    init(){
        aSlangs = [
            "abuden": "what else do you expect?",
            "aduh": "why did this happen?",
            "ah nia weiy": "oh my god",
            "aiseh": "I'm impressed",
            "aiya": "too bad",
            "aiyo": "that's bad",
            "ajak": "invite",
            "alamak": "oh my goodness",
            "angmo": "westerner",
            "angmoh": "westerner",
            "apa": "what",
            "apani": "What's this?"
        ]
        
        bSlangs = [
            "ba": "then",
            "bah": "alright",
            "beh": "can't",
            "belanja": "treat",
            "belum": "haven't",
            "bobian": "no choice",
            "bojio": "didn't invite",
            "bosan": "boring",
            "btw": "by the way",
            "bungkus": "take away"
        ]
        
        cSlangs = [
            "cari": "look for",
            "chun": "on point",
            "cincai": "whatever",
            "cabut": "go off",
            "chio": "pretty",
            "chiobu": "pretty lady",
            "chotto": "wait",
            "ceh": "so what?",
            "cheh": "so what?",
            "chup": "I've got this",
            "chao": "go off",
            "ciao": "bye"
        ]
        
        dSlangs = [
            "dah": "already",
            "dapao": "takeaway",
            "dapau": "takeaway",
            "dei": "bro",
            "diam": "shut up",
            "diamlah": "shut up",
            "dulu": "first",
            "dunno": "don't know",
            "dunwan": "don't want",
            "dy": "already"
        ]
        
        eSlangs = [
            "eksyen": "show off"
        ]
        
        fSlangs = [
            "fuyoh": "I'm impressed",
            "fuiseh": "I'm impressed",
            "ffk": "backout last minute",
            "fong fai kei": "backout last minute",
            "fong fei kei": "backout last minute",
            "fyi": "for your information"
        ]
        
        gSlangs = [
            "gangho": "motivated",
            "gaodim": "complete",
            "gaolat": "gone",
            "gempak": "wow",
            "geng": "impressive",
            "geram": "frustrated",
            "gg": "so screwed",
            "ggwp": "good game well played",
            "glhf": "good luck have fun",
            "gostan": "reverse",
            "gua": "I think",
            "guailou": "westerner",
            "gungho": "motivated"
        ]
        
        hSlangs = [
            "habis": "gone",
            "hailat": "so screwed",
            "hoseih": "nice",
            "hoseh": "nice"
        ]
        
        iSlangs = [
            "ic": "I see",
            "icic": "I see I see"
        ]
        
        jSlangs = [
            "jaga": "take care",
            "jangan": "don't",
            "jap": "wait",
            "je": "only",
            "jialat": "so screwed",
            "jinjia": "very",
            "jio": "invite",
            "jom": "let's go"
        ]
        
        kSlangs = [
            "kacau": "disturb",
            "kah": "is it?",
            "kan": "right?",
            "kantoi": "busted",
            "kau": "you",
            "kautim": "completed",
            "kena": "get",
            "kiasi": "afraid to die",
            "kiasu": "afraid to losing out",
            "kisiao": "crazy",
            "kongsi": "share",
            "kut": "I think so"
        ]
        
        lSlangs = [
            "lagi": "also",
            "lang": "people",
            "lari": "run",
            "laugh die me": "so funny",
            "lemme": "let me",
            "lenglui": "pretty lady",
            "lengzai": "handsome guy",
            "liao": "already",
            "liddat": "like that",
            "liddis": "like this"
        ]
        
        mSlangs = [
            "macam": "like",
            "macha": "bro",
            "ma": "is it?",
            "mah": "is it?",
            "mamak": "indian food stall",
            "mampus": "in trouble",
            "mampos": "in trouble",
            "meh": "really?",
            "memang": "really",
            "mempersiasuikan": "embarass",
            "mou": "or not?"
        ]
        
        nSlangs = [
            "nani": "what?",
            "ni": "this",
            "njhl": "good for you then"
        ]
        
        oSlangs = [
            "oi": "hey you",
            "omai": "oh my",
            "omo": "oh my",
            "onz": "good to go",
            "otw": "on the way"
        ]
        
        pSlangs = [
            "paiseh": "it's shameful",
            "perasan": "flatter",
            "pokai": "broke"
        ]
        
        sSlangs = [
            "sape": "who",
            "syok": "amazing",
            "shiok": "amazing",
            "siam": "move away",
            "swee": "nice",
            "siao": "crazy",
            "sian": "boring",
            "sien": "boring",
            "sibei": "very",
            "sibeh": "very",
            "smh": "shake my head",
            "sot": "crazy",
            "sudah": "already",
            "sui": "nice",
            "sikit": "a little",
            "sempat": "in time",
            "siapa": "who"
        ]
        
        tSlangs = [
            "tabao": "takeaway",
            "tabau": "takeaway",
            "takleh": "cannot",
            "takpe": "it's okay",
            "tapao": "takeaway",
            "tapau": "takeaway",
            "tauke": "boss",
            "taukeh": "boss",
            "tbh": "to be honest",
            "tu": "that",
            "tahan": "endure",
            "tmi": "too much information",
            "ttyl": "talk to you later"
        ]
        
        uSlangs = [
            "ulu": "rural"
        ]
        
        vSlangs = [
            "veri": "very"
        ]
        
        wSlangs = [
            "walao": "seriously?",
            "walau": "seriously?"
        ]
        
        xSlangs = [
            "xiao": "small",
            "xleh": "cannot"
        ]
        
        ySlangs = [
            "yumcha": "hangout",
            "yer": "disgusting",
            "yakah": "really?"
        ]
        
        zSlangs = [
            "zomo": "why",
            "zomok": "why"
        ]
    }
    
    
    public func translateSlangs(word_array: [String]) -> String {
        
        var words = [String]()
        
        words = word_array
        
        var index = -1
        
        for word in words {
            // check if there's slangs
            
            index += 1
            
            if word.hasPrefix("a"){
                guard let translatedWord = aSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("b"){
                guard let translatedWord = bSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("c"){
                guard let translatedWord = cSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("d"){
                guard let translatedWord = dSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("e"){
                guard let translatedWord = eSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("f"){
                guard let translatedWord = fSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("g"){
                guard let translatedWord = gSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("h"){
                guard let translatedWord = hSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("i"){
                guard let translatedWord = iSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("j"){
                guard let translatedWord = jSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("k"){
                guard let translatedWord = kSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("l"){
                guard let translatedWord = lSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("m"){
                guard let translatedWord = mSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("n"){
                guard let translatedWord = nSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("o"){
                guard let translatedWord = oSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("p"){
                guard let translatedWord = pSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("q"){
                guard let translatedWord = qSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("r"){
                guard let translatedWord = rSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("s"){
                guard let translatedWord = sSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("t"){
                guard let translatedWord = tSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("u"){
                guard let translatedWord = uSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("v"){
                guard let translatedWord = vSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("w"){
                guard let translatedWord = wSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("x"){
                guard let translatedWord = xSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("y"){
                guard let translatedWord = ySlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            
            else if word.hasPrefix("z"){
                guard let translatedWord = zSlangs[word] else {
                    continue
                }
                words[index] = translatedWord
            }
            //print("\(word)->\(words[index])")
            
        }
        
        var translatedSentence = words.joined(separator: " ")
        
        print("translated_text:\(translatedSentence)")
        return translatedSentence
    }
    
    
    public func translate2Slangs(){
        
    }
    
}
