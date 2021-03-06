//
//  Deinflector.swift
//  CorePhaseTwoA
//
//  Created by Shajeel Yahya on 11/28/20.
//

import Foundation

extension String {
    func substring(from: Int) -> String {
        return String(dropFirst(from))
    }

    func substring(to: Int) -> String {
        return String(dropLast(count - to))
    }
}

// swiftlint:disable type_body_length
class Deinflector {
    /// - Returns: Possible dictionary forms for a given verb including itself.
    /// - Note: Combine rules are not used.
    class func deinflect(_ verb: String) -> [String] {
        var forms = [verb]
        let verbLength = verb.count

        let keys = rules.keys.filter { $0 <= verbLength }
        
        for len in keys {
            let beginning = verb.substring(to: verbLength - len)
            let ending = verb.substring(from: verbLength - len)
            
            if let match = rules[len]![ending] {
                for x in match {
                forms.append(beginning + x)
                }
            }
        }

        return forms
    }

    // Deinflect Rules 20081220-0509 | by Jonathan Zarate | http://www.polarcloud.com
    static let rules: [Int: [String: [String]]] = [
        9: [
            "くありませんでした": ["い"]
        ],
        7: [
            "いませんでした": ["う"],
            "きませんでした": ["くる", "く"],
            "ぎませんでした": ["ぐ"],
            "しませんでした": ["す","する"],
            "ちませんでした": ["つ"],
            "にませんでした": ["ぬ"],
            "びませんでした": ["ぶ"],
            "みませんでした": ["む"],
            "りませんでした": ["る"]
        ],
        6: [
            "くありません": ["い"],
            "ませんでした": ["る"]
        ],
        5: [
            "いましょう": ["う"],
            "きましょう": ["く","くる"],
            "ぎましょう": ["ぐ"],
            "しましょう": ["す","する"],
            "ちましょう": ["つ"],
            "にましょう": ["ぬ"],
            "びましょう": ["ぶ"],
            "みましょう": ["む"],
            "りましょう": ["る"]
        ],
        4: [
            "いじゃう": ["ぐ"],
            "いすぎる": ["う"],
            "いちゃう": ["く"],
            "いなさい": ["う"],
            "いました": ["う"],
            "いません": ["う"],
            "かったら": ["い"],
            "かったり": ["い"],
            "きすぎる": ["く", "くる"],
            "ぎすぎる": ["ぐ"],
            "きちゃう": ["くる"],
            "きなさい": ["く", "くる"],
            "ぎなさい": ["ぐ"],
            "きました": ["く", "くる"],
            "ぎました": ["ぐ"],
            "きません": ["く", "くる"],
            "ぎません": ["ぐ"],
            "こさせる": ["くる"],
            "こられる": ["くる"],
            "しすぎる": ["す","する"],
            "しちゃう": ["す","する"],
            "しなさい": ["す", "する"],
            "しました": ["す", "する"],
            "しません": ["す", "する"],
            "ちすぎる": ["つ"],
            "ちなさい": ["つ"],
            "ちました": ["つ"],
            "ちません": ["つ"],
            "っちゃう": ["る","う","く","つ"],
            "にすぎる": ["ぬ"],
            "になさい": ["ぬ"],
            "にました": ["ぬ"],
            "にません": ["ぬ"],
            "びすぎる": ["ぶ"],
            "びなさい": ["ぶ"],
            "びました": ["ぶ"],
            "びません": ["ぶ"],
            "ましょう": ["る"],
            "みすぎる": ["む"],
            "みなさい": ["む"],
            "みました": ["む"],
            "みません": ["む"],
            "りすぎる": ["る"],
            "りなさい": ["る"],
            "りました": ["る"],
            "りません": ["る"],
            "んじゃう": ["ぬ","ぶ","む"]
        ],
        3: [
            "いそう": ["う"],
            "いたい": ["う"],
            "いたら": ["く"],
            "いだら": ["ぐ"],
            "いたり": ["く"],
            "いだり": ["ぐ"],
            "います": ["う"],
            "かせる": ["く"],
            "がせる": ["ぐ"],
            "かった": ["い"],
            "かない": ["く"],
            "がない": ["ぐ"],
            "かれる": ["く"],
            "がれる": ["ぐ"],
            "きそう": ["く","くる"],
            "ぎそう": ["ぐ"],
            "きたい": ["く","くる"],
            "ぎたい": ["ぐ"],
            "きたら": ["くる"],
            "きたり": ["くる"],
            "きます": ["く","くる"],
            "ぎます": ["ぐ"],
            "くない": ["い"],
            "ければ": ["い"],
            "こない": ["くる"],
            "こよう": ["くる"],
            "これる": ["くる"],
            "させる": ["する","る"],
            "さない": ["す"],
            "される": ["す","する"],
            "しそう": ["す","する"],
            "したい": ["す", "する"],
            "したら": ["す","する"],
            "したり": ["す", "する"],
            "しない": ["する"],
            "します": ["す","する"],
            "しよう": ["する"],
            "すぎる": ["い","る"],
            "たせる": ["つ"],
            "たない": ["つ"],
            "たれる": ["つ"],
            "ちそう": ["つ"],
            "ちたい": ["つ"],
            "ちます": ["つ"],
            "ちゃう": ["る"],
            "ったら": ["う", "つ", "る"],
            "ったり": ["う","つ","る"],
            "なさい": ["る"],
            "なせる": ["ぬ"],
            "なない": ["ぬ"],
            "なれる": ["ぬ"],
            "にそう": ["ぬ"],
            "にたい": ["ぬ"],
            "にます": ["ぬ"],
            "ばせる": ["ぶ"],
            "ばない": ["ぶ"],
            "ばれる": ["ぶ"],
            "びそう": ["ぶ"],
            "びたい": ["ぶ"],
            "びます": ["ぶ"],
            "ました": ["る"],
            "ませる": ["む"],
            "ません": ["る"],
            "まない": ["む"],
            "まれる": ["む"],
            "みそう": ["む"],
            "みたい": ["む"],
            "みます": ["む"],
            "らせる": ["る"],
            "らない": ["る"],
            "られる": ["る"],
            "りそう": ["る"],
            "りたい": ["る"],
            "ります": ["る"],
            "わせる": ["う"],
            "わない": ["う"],
            "われる": ["う"],
            "んだら": ["ぬ","ぶ","む"],
            "んだり": ["ぬ","ぶ","む"]
        ],
        2: [
            "いた": ["く"],
            "いだ": ["ぐ"],
            "いて": ["く"],
            "いで": ["ぐ"],
            "えば": ["う"],
            "える": ["う"],
            "おう": ["う"],
            "かず": ["く"],
            "がず": ["ぐ"],
            "きた": ["くる"],
            "きて": ["くる"],
            "くて": ["い"],
            "けば": ["く"],
            "げば": ["ぐ"],
            "ける": ["く"],
            "げる": ["ぐ"],
            "こい": ["くる"],
            "こう": ["く"],
            "ごう": ["ぐ"],
            "こず": ["くる"],
            "さず": ["す"],
            "した": ["す","する"],
            "して": ["す","する"],
            "しろ": ["する"],
            "せず": ["する"],
            "せば": ["す"],
            "せよ": ["する"],
            "せる": ["す"],
            "そう": ["い","す","る"],
            "たい": ["る"],
            "たず": ["つ"],
            "たら": ["る"],
            "たり": ["る"],
            "った": ["う","く","つ","る"],
            "って": ["う","く","つ","る"],
            "てば": ["つ"],
            "てる": ["つ"],
            "とう": ["つ"],
            "ない": ["る"],
            "なず": ["ぬ"],
            "ねば": ["ぬ"],
            "ねる": ["ぬ"],
            "のう": ["ぬ"],
            "ばず": ["ぶ"],
            "べば": ["ぶ"],
            "べる": ["ぶ"],
            "ぼう": ["ぶ"],
            "ます": ["る"],
            "まず": ["む"],
            "めば": ["む"],
            "める": ["む"],
            "もう": ["む"],
            "よう": ["る"],
            "らず": ["る"],
            "れば": ["る"],
            "れる": ["る"],
            "ろう": ["る"],
            "わず": ["う"],
            "んだ": ["ぬ","ぶ","む"],
            "んで": ["ぬ","ぶ","む"]
        ],
        1: [
            "い": ["いる","う","る"],
            "え": ["う","える"],
            "き": ["きる","く"],
            "ぎ": ["ぎる","ぐ"],
            "く": ["い"],
            "け": ["く","ける"],
            "げ": ["ぐ","げる"],
            "さ": ["い"],
            "し": ["す"],
            "じ": ["じる"],
            "ず": ["る"],
            "せ": ["す","せる"],
            "ぜ": ["ぜる"],
            "た": ["る"],
            "ち": ["ちる","つ"],
            "て": ["つ","てる","る"],
            "で": ["でる"],
            "な": [""],
            "に": ["にる","ぬ"],
            "ね": ["ぬ","ねる"],
            "ひ": ["ひる"],
            "び": ["びる","ぶ"],
            "へ": ["へる"],
            "べ": ["ぶ","べる"],
            "み": ["みる","む"],
            "め": ["む","める"],
            "よ": ["る"],
            "り": ["りる","る"],
            "れ": ["る","れる"],
            "ろ": ["る"]
        ]
    ]
}
