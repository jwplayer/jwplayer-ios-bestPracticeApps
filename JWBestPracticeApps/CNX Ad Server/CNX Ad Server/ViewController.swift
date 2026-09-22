//
//  ViewController.swift
//  CNX Ad Server
//

import UIKit
import JWPlayerKit

/**
 The launch screen: the simplest CNX Ad Server setup, with a live ad event log underneath so the
 screen doubles as a debugging aid.

 The segmented control switches between manual and dynamic ad scheduling. "Feed" opens the
 pause-on-scroll (viewability) example.
 */
class ViewController: UIViewController {
    private let playerViewController = AdEventLogViewController()
    private let eventLog = UITextView()
    private let schedulingControl = UISegmentedControl(items: ["Manual", "Dynamic"])

    private var scheduling: AdScheduling = .manual

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "CNX Ad Server"

        schedulingControl.selectedSegmentIndex = 0
        schedulingControl.addTarget(self, action: #selector(schedulingChanged), for: .valueChanged)
        navigationItem.titleView = schedulingControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Feed", style: .plain, target: self, action: #selector(openFeed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Clear", style: .plain, target: self, action: #selector(clearLog))

        layOutPlayerAndLog()

        playerViewController.onLog = { [weak self] line in self?.append(line) }
        playerViewController.onSetupFinished = { [weak self] in self?.schedulingControl.isEnabled = true }
        CNXConfig.warnings().forEach { append("Warning: \($0)") }
        setUpPlayer()
    }

    private func setUpPlayer() {
        append(scheduling == .manual
               ? "MANUAL scheduling: pre-roll, mid-roll at 30s, post-roll."
               : "DYNAMIC scheduling: pre-roll, then mid-rolls placed by the ad scheduler — the first after "
                 + "\(Int(CNXPlayerConfiguration.dynamicFirstMidrollAfter))s of content, then at most one every "
                 + "\(Int(CNXPlayerConfiguration.dynamicSecondsBetweenMidrolls))s — and a post-roll.")
        // A configuration supplied while the previous one is still loading is rejected, so the control
        // stays disabled until this setup finishes.
        schedulingControl.isEnabled = false
        do {
            let config = try CNXPlayerConfiguration.make(scheduling: scheduling)
            playerViewController.player.configurePlayer(with: config)
        } catch {
            // A builder throws only for a programming error in the configuration above.
            append("Player setup failed: \(error.localizedDescription)")
            schedulingControl.isEnabled = true
        }
    }

    // MARK: - Actions

    @objc private func schedulingChanged() {
        scheduling = schedulingControl.selectedSegmentIndex == 0 ? .manual : .dynamic
        // Configuring the same player again replaces its current setup, so no restart is needed.
        setUpPlayer()
    }

    @objc private func openFeed() {
        playerViewController.player.pause()
        navigationController?.pushViewController(FeedViewController(), animated: true)
    }

    @objc private func clearLog() {
        eventLog.text = ""
    }

    // MARK: - Layout and log

    private func layOutPlayerAndLog() {
        addChild(playerViewController)
        let playerView = playerViewController.view!
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        playerViewController.didMove(toParent: self)

        eventLog.translatesAutoresizingMaskIntoConstraints = false
        eventLog.isEditable = false
        eventLog.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        eventLog.accessibilityIdentifier = "adEventLog"
        view.addSubview(eventLog)

        // 16:9 where it fits; in landscape the height cap wins so the player never runs off screen and the
        // log keeps some room.
        let aspectRatio = playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0 / 16.0)
        aspectRatio.priority = .defaultHigh

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            aspectRatio,
            playerView.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.6),

            eventLog.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            eventLog.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            eventLog.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            eventLog.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func append(_ line: String) {
        let timestamp = Self.timeFormatter.string(from: Date())
        eventLog.text += "\(timestamp)  \(line)\n"
        eventLog.scrollRangeToVisible(NSRange(location: eventLog.text.utf16.count, length: 0))
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
