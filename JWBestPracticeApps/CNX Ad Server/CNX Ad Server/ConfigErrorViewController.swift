//
//  ConfigErrorViewController.swift
//  CNX Ad Server
//

import UIKit

/**
 Shown instead of any player when `CNXConfig` is incomplete.

 Lists every problem by field name, so a developer knows exactly what to fix without contacting
 support. The same text is printed to the console.
 */
class ConfigErrorViewController: UIViewController {
    private let problems: [CNXConfig.Problem]

    init(problems: [CNXConfig.Problem]) {
        self.problems = problems
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let message = Self.message(for: problems)
        print(message)

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        textView.attributedText = Self.attributedMessage(for: problems)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    /// Plain-text form of the problems, for the console.
    static func message(for problems: [CNXConfig.Problem]) -> String {
        let lines = problems.map { "- \($0.field): \($0.detail)" }
        return (["CNX Ad Server config is incomplete — no player was set up:"] + lines).joined(separator: "\n")
    }

    private static func attributedMessage(for problems: [CNXConfig.Problem]) -> NSAttributedString {
        let text = NSMutableAttributedString(
            string: "CNX Ad Server config is incomplete\n\n",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .title2), .foregroundColor: UIColor.systemRed])
        text.append(NSAttributedString(
            string: "No player was set up. Fix the fields below in CNXConfig.swift, then run again.\n\n",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.label]))

        for problem in problems {
            text.append(NSAttributedString(
                string: problem.field + "\n",
                attributes: [.font: UIFont.preferredFont(forTextStyle: .headline), .foregroundColor: UIColor.label]))
            text.append(NSAttributedString(
                string: problem.detail + "\n\n",
                attributes: [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.secondaryLabel]))
        }
        return text
    }
}
