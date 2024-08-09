//
//  FeedTableViewController.swift
//  FeedTableViewController
//
//  Created by Amitai Blickstein on 6/26/22.
//

import UIKit

class FeedTableViewController: UITableViewController {
    /// Instantiated with our mock/hard-coded playlist.
    private var viewModel = FeedViewModel(withItems: Playlist.bpaManual)

    /// Helps to handle media playback when navigating through the feed.
    private var page: Int = -1 {
        didSet {
            guard page != oldValue else {
                return
            }

            let previousIndexPath = IndexPath(row: oldValue, section: 0)
            let indexPath = IndexPath(row: page, section: 0)

            if let cell = tableView.cellForRow(at: previousIndexPath) as? PlayerItemCell {
                cell.pausePlayback()
            }

            if let cell = tableView.cellForRow(at: indexPath) as? PlayerItemCell {
                cell.startPlayback()
            }

            // Add more rows to the data source when we hit the end.
            Task {
                if page == viewModel.count - 1 {
                    viewModel.appendItems(fromPlaylist: Playlist.bpaManual)
                }
            }
        }
    }

    var autostartFirstTime: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        // Register the custom cell view.
        let feedNib = UINib(nibName: viewModel.cellNibName, bundle: .main)
        tableView.register(feedNib, forCellReuseIdentifier: viewModel.cellReuseIdentifier)
        
        // Various stylistic options.
        tableView.scrollsToTop = false
        tableView.isPagingEnabled = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = view.bounds.inset(by: view.safeAreaInsets).height
        
        // Must be called once to populate the table view.
        viewModel.appendItems(fromPlaylist: Playlist.bpaManual)

        Task { @MainActor in
            calculateCurrentPage()
        }
    }

    
    // MARK: - UITableViewDataSource implementation
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellReuseIdentifier, for: indexPath)
        if let cell = cell as? PlayerItemCell {
            cell.item = viewModel.itemForVideoMetadata(at: indexPath.row)
            cell.descriptionLabel.text = "video #\(indexPath.row + 1)"
        }
        
        return cell
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateCurrentPage()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            calculateCurrentPage()
        }
    }

    func calculateCurrentPage() {
        let pageHeight = tableView.frame.height
        page = Int((tableView.contentOffset.y + pageHeight / 2) / pageHeight)
    }
    
}

extension FeedTableViewController: FeedViewModelDelegate {
    /// When new items are added to the data source, this will be called to reload the appropriate rows.
    func didAddNewItemsToViewModel(with newIndicesToReload: [Int]?) {
        let newIndexPaths = (newIndicesToReload ?? [])
            .map { IndexPath(row: $0, section: 0) }
        
        didAddNewRows(withIndexPaths: newIndexPaths)
    }
    
    @MainActor
    private func didAddNewRows(withIndexPaths newIndexPaths: [IndexPath]) {
        tableView.insertRows(at: newIndexPaths, with: .none)
    }
}
