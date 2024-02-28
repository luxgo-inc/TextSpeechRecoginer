//
//  ViewController.swift
//  TextSpeechRecognizer
//
//  Created by Keigo Nakagawa on 2024/02/28.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    static let sampleText = """
Xcode15を使うと、すべてのAppleプラットフォーム向けにアプリを開発、テスト、配信できます。

コード補完機能やインタラクティブプレビュー、ライブアニメーションなどの強化により、アプリの開発とデザインをさらに迅速化できます。

Gitステージングでコーディング作業を中断せずに次のコミットを作成したり、デザインが一新され、録画ビデオを添付できるようになったテストレポートを活用して、テストの結果をさまざまな角度から分析できます。


Xcode CloudからTestFlightおよびAppStoreにアプリをシームレスにデプロイしましょう。
優れたアプリの開発がかつてないほど簡単になります。
"""

    @IBOutlet weak var textView: UITextView!

    // SSML変換済みのテキスト
    private var convertedText: String = ""
    private var textBundlesRanges: [NSRange] = []
    // キーは変換後のテキストのインデックス、値は元のテキストのインデックス
    private var mapping = [Int: Int]()

    // 既に発話された範囲を追跡するためのリストを追加
    private var spokenRanges: [NSRange] = []

    private var synthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupTextView()
        setupAVSpeechSynthesizer()
    }

    private func setupTextView() {
        textView.text = Self.sampleText
    
        textBundlesRanges = createMappingForTextBundles(text: Self.sampleText)
    }

    private func setupAVSpeechSynthesizer() {
        synthesizer.delegate = self

        var text = "<speak>\(Self.sampleText)</speak>"
        convertedText = convertTextToSSMLAndCreateMapping(originalText: text)
        loadSpeechFromText(text: convertedText)
    }


    func highlightText(in textView: UITextView, withRange range: NSRange) {
        guard let text = textView.text else { return }

        // 範囲がテキストの長さを超えていないことを確認
        let validRange = NSRange(location: 0, length: text.utf16.count)
        if NSIntersectionRange(range, validRange).length == range.length {
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
            textView.attributedText = attributedText
        } else {
            // 範囲が無効な場合の処理（例: ログ出力）
            print("指定された範囲がテキストの長さを超えています。")
        }
    }

    func createMappingForTextBundles(text: String) -> [NSRange] {
        var ranges: [NSRange] = []
        let components = text.components(separatedBy: "\n\n")
        var location = 0

        for component in components {
            let length = component.utf16.count
            if length > 0 {
                let range = NSRange(location: location, length: length)
                ranges.append(range)
            }
            // コンポーネントの長さ + 2つの改行の長さを次の位置の計算に加える
            location += length + 2
        }

        // 最後のコンポーネントの後に改行がない場合は、2を引く
        if location > text.utf16.count {
            location = text.utf16.count
        }

        return ranges
    }

    // SSML変換とマッピング情報の作成
    func convertTextToSSMLAndCreateMapping(originalText: String) -> String {
        var ssmlText = ""
        var originalIndex = 0 // 元のテキストのインデックス
        var ssmlIndex = 0 // 変換後のSSMLテキストのインデックス

        for character in originalText {
            ssmlText.append(character)
            // 元のインデックスとSSMLテキストのインデックスをマッピング
            mapping[ssmlIndex] = originalIndex

            if character == "。" {
                let tag = "<break time=\"2s\"/>"
                ssmlText.append(contentsOf: tag)
                // タグを追加した後、ssmlIndexを進める
                ssmlIndex += tag.count
            }

            originalIndex += 1 // 元のテキストのインデックスを進める
            ssmlIndex += 1 // SSMLテキストのインデックスを進める（文字を追加するたびに）
        }

        return ssmlText
    }

}

extension ViewController: AVSpeechSynthesizerDelegate {
    func loadSpeechFromText(text: String) {
        do {
            Self.setAudioSessions()

            guard let utterance = AVSpeechUtterance(ssmlRepresentation: text) else { return }
            let voice = AVSpeechSynthesisVoice(language: "ja")
            utterance.voice = voice

            utterance.volume = 1.0

            synthesizer.speak(utterance)

        } catch let error as NSError {
            print(error)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
                // characterRangeの有効性を確認
        guard characterRange.location != NSNotFound, characterRange.length > 0 else {
            print("Invalid character range")
            return
        }

        print("word speech range: \(characterRange)")

        // delegateで返された発話箇所から予めマッピングされたNSRangeを元にオリジナルテキストのrangeを取得し、
        // 改行コード毎にまとめられたテキストの該当するRangeを特定してハイライトするパターン
        let originalRange = convertRange(characterRange, withMapping: mapping)
        if let bundleRange = textBundlesRanges.first(where: { NSIntersectionRange($0, originalRange).length > 0 }) {
            DispatchQueue.main.async {
                // 該当するまとまりをハイライトする
                print("highlight mapped range: \(bundleRange)")
                self.highlightText(in: self.textView, withRange: bundleRange)
            }
        }
        return



        /*
        guard let speechRange = getOriginalRangeFromSSMLRange(ssmlText: convertedText, characterRange: characterRange) else { return }

        // 発話された範囲をリストに追加
        spokenRanges.append(speechRange)
        print("word speech range from original text: \(speechRange)")

        // 発話される範囲がどのまとまりに該当するかを特定
        if let bundleRange = textBundlesRanges.first(where: { range in
                        NSIntersectionRange(range, speechRange).length > 0 && !spokenRanges.contains(where: { spokenRange in
                            NSIntersectionRange(range, spokenRange).length > 0
                        })
                    }) {

        // delegateで返された発話箇所からテキストを取得し、SSML変換前のテキストから範囲を特定してハイライトするパターン
//        if let bundleRange = textBundlesRanges.first(where: { NSIntersectionRange($0, speechRange).length > 0 }) {

        // delegateで返された発話箇所をハイライトするパターン
//        if let bundleRange = textBundlesRanges.first(where: { NSIntersectionRange($0, characterRange).length > 0 }) {

            DispatchQueue.main.async {
                // 該当するまとまりをハイライトする
//                self.highlightText(in: self.textView, withRanges: [bundleRange])
                print("highlight bundled range: \(bundleRange)")
                self.highlightText(in: self.textView, withRange: bundleRange)
            }
        }
         */
    }

    // SSML変換されたテキストから発話対象のテキストを取得し、
    // そのテキストに対応するSSML変換前のテキストのNSRangeを取得する関数
    func getOriginalRangeFromSSMLRange(ssmlText: String, characterRange: NSRange) -> NSRange? {
        // SSML変換されたテキストから発話対象のテキストを取得
        let ssmlSubstring = (ssmlText as NSString).substring(with: characterRange)

        return findOriginalRangeForSpeakingText(originalText: Self.sampleText, speakingText: ssmlSubstring)
    }

    func findOriginalRangeForSpeakingText(originalText: String, speakingText: String) -> NSRange? {
        if let range = originalText.range(of: speakingText) {
            let startIndex = originalText.distance(from: originalText.startIndex, to: range.lowerBound)
            let length = speakingText.count
            return NSRange(location: startIndex, length: length)
        }
        return nil
    }

    func convertRange(_ range: NSRange, withMapping mapping: [Int: Int]) -> NSRange {
        let start = mapping[range.location] ?? 0
        let end = mapping[range.location + range.length] ?? 0
        return NSRange(location: start, length: end - start)
    }

}

extension ViewController {

    public static func setAudioSessions() {

        let categoryOption = getCategoryOption()

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                            mode: AVAudioSession.Mode.default,
                                                            options: [categoryOption])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
    }

    private static func getCategoryOption() -> AVAudioSession.CategoryOptions {
        var categoryOption = AVAudioSession.CategoryOptions.init(rawValue: UInt(0))
        return categoryOption
    }
}
