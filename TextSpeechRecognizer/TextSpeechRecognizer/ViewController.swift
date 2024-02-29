//
//  ViewController.swift
//  TextSpeechRecognizer
//
//  Created by Keigo Nakagawa on 2024/02/28.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
//    static let sampleText = """
//Xcode15を使うと、すべてのAppleプラットフォーム向けにアプリを開発、テスト、配信できます。
//
//コード補完機能やインタラクティブプレビュー、ライブアニメーションなどの強化により、アプリの開発とデザインをさらに迅速化できます。
//
//Gitステージングでコーディング作業を中断せずに次のコミットを作成したり、デザインが一新され、録画ビデオを添付できるようになったテストレポートを活用して、テストの結果をさまざまな角度から分析できます。
//
//
//Xcode CloudからTestFlightおよびAppStoreにアプリをシームレスにデプロイしましょう。
//優れたアプリの開発がかつてないほど簡単になります。
//"""

    static let sampleText = """
アンサーダッシュ
(AnswerDash)
2014 年初頭のある冷たい雨の午後、アンサーダッシュ社の共同創業者兼 CEO(最高経営責任者)ジ ェイコブ・O・ウォブロック博士は、もう一人の共同創業者で CTO(最高技術責任者)のアンドリュ ー・J・コー博士と会社の将来について話し合っていた。アンサーダッシュ社が生み出した製品は、ユ ーザーが Web サイトを見ている時に感じた質問の答えを簡単に見つけられるという点において、ウォ ブロック自身まさに画期的と考えるものだった。さらに二人には、自社のイノベーションが多くの企 業にとって非常に魅力的なものになるという確信があった。売上高アップのほか、カスタマーサポー ト費用の削減や消費者の Web エクスペリエンス(訳注:Web 上でのユーザー体験)の向上が見込める からだ。2012 年 9 月の創業から 1 年半、アンサーダッシュ社は、自社の新技術をリリース初期に採用 した“アーリーアダプター”にどのようなメリットがもたらされたのか、その情報を丹念に集めてき た。ウォブロックとコーの期待通り、アンサーダッシュのセルフ式カスタマーサポート・ソリューショ ンによって、費用の掛かるカスタマーサポート・チケット(訳注:ベンダーへの問い合わせ票)処理を 削減できたと、顧客からの評判は大変に良いものだった。それは、カスタマーサポートに問い合わせな くても、ユーザーが自分で簡単に質問の答えを見つけられるようになったからであった。さらに、ユー ザーが購入決定に必要な情報を確実に得られるようになり、売上増加につながったという顧客もあっ た。ユーザーに先回りして情報を提示するセルフ型サービスが、ネット販売の拡大につながっていた のだ。
これらは心強い結果ではあったが、一方で顧客の新規獲得と既存顧客維持という点において、ビジ ネス規模の拡大をもたらすような市場開拓手法への戦略転換を促す状況が 2 つあった。1 つ目は、普及 促進を目指した価格戦略を採用したにもかかわらず、新規顧客の獲得率が期待を下回ったことだ。2014 年 4 月時点で実際に代金を支払ってくれている顧客の数は 4 件しかなく、そのほとんどがアンサーダ ッシュ社と仕事上のつながりがある顧客だった。ただし、そのような仕事上つながりのある顧客です ら、最初のコンタクト段階から実際に契約に至るまでには数カ月を要していた。
2 つ目は、最初の契約顧客だったベンブリッジ・ジュエラー社がここに来てサービスを打ち切ったことだった。これはショ ッキングな出来事だった。売り込み先のターゲットは今のままで良いのか、2 人の共同創業者たちは疑 念を抱いた。「非常ボタン」を押すまでにはぎりぎり至らなかったものの、今のままでは駄目だと 2 人 は悟った。
創業間もない新興企業である彼らは、これまで耳を貸してくれる人になら誰にでも話を持ちかけ、 同僚や友人からの紹介も含めどんな機会に対しても営業を掛けた。しかし、この「ショットガン方式」 のやり方にコーは疑問を感じ始めていた。「ターゲットをもっと明確にしなければなりません。そうす れば、どの様にこの製品を構築・改良し、市場とコミュニケーションし、値段をつけていくべきか、と いった戦略が出来上がってくるはずです」
ウォブロックは、これに賛同しながらも次のように指摘した。「アンサーダッシュは業界の枠を超え て E コマースとソフトウェアサービスの両方の企業に価値を生み出してきました。われわれの顧客は 皆、それぞれの業務に応じたアプリケーションを持っていますが、それでもアンサーダッシュには彼 らの最終利益を押し上げるだけの力があります。ターゲットを絞り込む前に、まずはわれわれ自身で 出来ることの選択肢を十分に吟味した方がいいのではないでしょうか。それに、ようやく契約にこぎ つけた大切な顧客をもう失いたくはないですからね」
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

        // SSML変換する場合
//        let text = "<speak>\(Self.sampleText)</speak>"
//        convertedText = convertTextToSSMLAndCreateMapping(originalText: text)
//        loadSpeechFromText(text: convertedText)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadSpeechFromText(text: Self.sampleText)
        }
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
//        let components = text.components(separatedBy: "\n\n")
        let components = text.components(separatedBy: "。")
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

//            guard let utterance = AVSpeechUtterance(ssmlRepresentation: text) else { return }
            let utterance = AVSpeechUtterance(string: text)
//            let voice = AVSpeechSynthesisVoice(language: "ja")
            let voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.voice = voice

            utterance.volume = 1.0
            // SSML変換する場合はrateが適用されない
            utterance.rate = 0.7

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

        // SSML変換する場合
        // delegateで返された発話箇所から予めマッピングされたNSRangeを元にオリジナルテキストのrangeを取得し、
        // 改行コード毎にまとめられたテキストの該当するRangeを特定してハイライトするパターン
//        let originalRange = convertRange(characterRange, withMapping: mapping)
//        if let bundleRange = textBundlesRanges.first(where: { NSIntersectionRange($0, originalRange).length > 0 }) {
//            DispatchQueue.main.async {
//                // 該当するまとまりをハイライトする
//                print("highlight mapped range: \(bundleRange)")
//                self.highlightText(in: self.textView, withRange: bundleRange)
//            }
//        }
//        return

        if let bundleRange = textBundlesRanges.first(where: { NSIntersectionRange($0, characterRange).length > 0 }) {
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
