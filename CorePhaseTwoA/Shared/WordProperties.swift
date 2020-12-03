//
//  WordProperties.swift
//  CorePhaseTwoA
//
//  Created by Shajeel Yahya on 12/1/20.
//

import UIKit

struct WordProperties {
    let entrySeq: Int?
    let kanjiElement: [String]?
    let furiganaElement: [String]?
    let definition: [String]?
    
    func isValid() -> Bool {
        return (entrySeq != nil && kanjiElement != nil && furiganaElement != nil && definition != nil) ? true :  false
    }
    
    // The keys must have the same name as the attributes of the Word entity.
    var dictionary: [String: Any] {
        return ["ent_seq": entrySeq ?? 0,
                "k_ele": kanjiElement ?? "",
                "r_ele": furiganaElement ?? "",
                "sense": definition ?? ""]
    }
}

class KanjiArray: NSObject, XMLParserDelegate {
    var elementName: String = String()
    
    var kanjiEle = [String]()
    var furi = [String]()
    var def = [String]()
    var seq = Int()
    
    var kanjiDictionary = [[String: Any]]()
    
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == "entry" {
            kanjiEle = [String]()
            def = [String]()
            furi = [String]()
            seq = Int()
        }

        self.elementName = elementName
    }

    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "entry" {
        let eachKanji = WordProperties(entrySeq: seq, kanjiElement: kanjiEle, furiganaElement: furi, definition: def)
            kanjiDictionary.append(eachKanji.dictionary)
        }
    }

    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if (!data.isEmpty) {
            if self.elementName == "keb" {
                kanjiEle += [data]
            } else if self.elementName == "gloss" {
                def += [data]
            } else if self.elementName == "reb" {
                furi += [data]
            } else if self.elementName == "ent_seq" {
                seq = Int(data) ?? 000
            }
        }
    }
    
    // 4
    func getXMLData(){
    if let path = Bundle.main.url(forResource: "JMdict_e", withExtension: "xml"){
    if let parser = XMLParser(contentsOf: path) {
    parser.delegate = self
    parser.parse()
    }
    }
    }
    
    //5
    func startParsing(){
    //if kanjiDictionary.isEmpty == true {
    getXMLData()
    //}
    //return
    }
    
    
}
