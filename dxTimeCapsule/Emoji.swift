//
//  Emoji.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/22/24.
//

struct Emoji: Identifiable, Hashable {
    let id: String
    let symbol: String
    let description: String
    
    static let emojis: [Emoji] = [
        Emoji(id: "1", symbol: "🥳", description: "행복"),
        Emoji(id: "2", symbol: "🥰", description: "설레는"),
        Emoji(id: "3", symbol: "😆", description: "즐거운"),
        Emoji(id: "4", symbol: "🥹", description: "감동적인"),
        Emoji(id: "5", symbol: "🙂", description: "평범"),
        Emoji(id: "6", symbol: "🫠", description: "스트레스가 많은"),
        Emoji(id: "7", symbol: "😭", description: "슬픈"),
        Emoji(id: "8", symbol: "😫", description: "짜증"),
        Emoji(id: "9", symbol: "🥵", description: "무더운"),
        Emoji(id: "10", symbol: "🥶", description: "추운"),
        Emoji(id: "11", symbol: "🤒", description: "아픈")
    ]
}
