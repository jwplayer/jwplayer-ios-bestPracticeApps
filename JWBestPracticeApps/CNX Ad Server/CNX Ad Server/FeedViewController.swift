//
//  FeedViewController.swift
//  CNX Ad Server
//

import UIKit
import JWPlayerKit

/**
 Pause-on-scroll (viewability): an article with a player in the middle of it.

 The player is set up with `autoPauseAdsOnViewability(true)`. Start an ad, then scroll until less
 than half of the player is on screen: the ad pauses. Scroll back and it resumes.

 The banner at the top shows the latest ad event, so you can watch the pause and resume happen.
 */
class FeedViewController: UIViewController {
    private let playerViewController = AdEventLogViewController()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Pause on scroll"

        layOutArticle()

        // Keep the player inline on rotation, so a player scrolled out of view stays out of view.
        playerViewController.forceFullScreenOnLandscape = false

        playerViewController.onLog = { [weak self] line in
            self?.statusLabel.text = "Last ad event: \(line)"
        }

        do {
            let config = try CNXPlayerConfiguration.make(scheduling: .manual,
                                                         autoPauseAdsOnViewability: true)
            playerViewController.player.configurePlayer(with: config)
        } catch {
            statusLabel.text = "Player setup failed: \(error.localizedDescription)"
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // viewDidDisappear, not viewWillDisappear: an interactive swipe-back that is cancelled calls
        // viewWillDisappear but leaves this screen showing.
        if isMovingFromParent {
            // Leaving the screen for good: stop playback so the ad does not keep running unseen.
            playerViewController.player.stop()
        }
    }

    // MARK: - Layout

    private func layOutArticle() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.backgroundColor = .secondarySystemBackground
        statusLabel.text = "Last ad event: none yet"
        statusLabel.accessibilityIdentifier = "adStatus"
        view.addSubview(statusLabel)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        scrollView.addSubview(stack)

        stack.addArrangedSubview(paragraphs(count: 3))

        addChild(playerViewController)
        let playerView = playerViewController.view!
        playerView.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(playerView)
        playerViewController.didMove(toParent: self)

        // Enough text below the player that it can be scrolled completely off screen.
        stack.addArrangedSubview(paragraphs(count: 12))

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),

            scrollView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0 / 16.0)
        ])
    }

    private func paragraphs(count: Int) -> UIView {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.text = Array(repeating: Self.loremIpsum, count: count).joined(separator: "\n\n")

        let container = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        return container
    }

    private static let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor "
        + "incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco "
        + "laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit "
        + "esse cillum dolore eu fugiat nulla pariatur."
}
