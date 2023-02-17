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

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        // Register the custom cell view.
        let feedNib = UINib(nibName: viewModel.cellNibName, bundle: .main)
        tableView.register(feedNib, forCellReuseIdentifier: viewModel.cellReuseIdentifier)
        
        // Various stylistic options.
        tableView.isPagingEnabled = true
        tableView.rowHeight = view.bounds.inset(by: view.safeAreaInsets).height
        
        // Must be called once to populate the table view.
        viewModel.appendItems(fromPlaylist: Playlist.bpaManual)
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
    
    
    // MARK: UITableViewDelegate implementation
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PlayerItemCell else {
            return
        }
        
        // Pause a cell as it goes offscreen
        cell.playerView.player.pause()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PlayerItemCell else {
            return
        }
        
        // Play a cell as it becomes visible
        cell.playerView.player.play()

        // Add more rows to the data source when we hit the end.
        Task {
            if indexPath.row == viewModel.count - 1 {
                viewModel.appendItems(fromPlaylist: Playlist.bpaManual)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
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
