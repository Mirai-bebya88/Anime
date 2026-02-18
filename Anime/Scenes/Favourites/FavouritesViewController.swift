//
//  FavouritesViewController.swift
//  Anime
//
//  Created by elene malakmadze on 17.02.26.
//

import UIKit
import Kingfisher

final class FavouritesViewController: UIViewController {

    private let viewModel: FavouritesViewModelProtocol = FavouritesViewModel()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(FavouriteAnimeCell.self, forCellReuseIdentifier: FavouriteAnimeCell.reuseIdentifier)
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 120
        return tv
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No favourite anime yet.\nTap the heart on an anime to add it!"
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor.theme.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadSavedAnime()
    }

    private func setUpUI() {
        view.backgroundColor = UIColor.theme.background
        title = "Favourites"

        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        tableView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )

        emptyStateLabel.center(in: tableView)
        emptyStateLabel.anchor(
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingLeading: 32,
            paddingTrailing: 32
        )
    }

    private func bindViewModel() {
        viewModel.refreshUI = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }

    private func updateUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !viewModel.savedAnime.isEmpty
    }
}

extension FavouritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.savedAnime.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteAnimeCell.reuseIdentifier, for: indexPath) as? FavouriteAnimeCell else {
            return UITableViewCell()
        }
        let anime = viewModel.savedAnime[indexPath.row]
        cell.configure(with: anime, statusColor: viewModel.getStatusColor(for: anime.watchStatus ?? ""))
        return cell
    }
}

extension FavouritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let savedAnime = viewModel.savedAnime[indexPath.row]
        let anime = Anime(
            malId: Int(savedAnime.malId),
            images: nil,
            title: savedAnime.title ?? "",
            titleEnglish: savedAnime.title,
            type: nil,
            episodes: Int(savedAnime.episodes),
            score: savedAnime.score,
            trailer: nil,
            year: Int(savedAnime.year),
            synopsis: savedAnime.synopsis,
            broadcast: nil
        )
        let detailVC = AnimeDetailViewController(anime: anime)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            self?.viewModel.removeAnime(at: indexPath.row)
            completion(true)
        }
        deleteAction.backgroundColor = UIColor.theme.error
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
