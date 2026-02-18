//
//  DiscoverViewController.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import UIKit

final class DiscoverViewController: UIViewController {

    private var viewModel: DiscoverViewModelProtocol = DiscoverViewModel()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search anime..."
        sb.searchBarStyle = .minimal
        return sb
    }()

    private lazy var genreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(GenreFilterCell.self, forCellWithReuseIdentifier: GenreFilterCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private lazy var mainTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        tv.register(AnimeTableViewCell.self, forCellReuseIdentifier: AnimeTableViewCell.reuseIdentifier)
        tv.delegate = self
        tv.dataSource = self
        tv.showsVerticalScrollIndicator = false
        return tv
    }()

    private var selectedFilterIndex: Int = 0
    private var isFiltering: Bool = false

    private lazy var searchResultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let width = (UIScreen.main.bounds.width - 48) / 3
        layout.itemSize = CGSize(width: width, height: width * 1.8)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(AnimeCollectionViewCell.self, forCellWithReuseIdentifier: AnimeCollectionViewCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.isHidden = true
        return cv
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor.theme.textSecondary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.clearSearch()
    }

    private func setUpUI() {
        view.backgroundColor = UIColor.theme.background
        navigationController?.navigationBar.prefersLargeTitles = false

        searchBar.delegate = self

        view.addSubview(searchBar)
        view.addSubview(genreCollectionView)
        view.addSubview(mainTableView)
        view.addSubview(searchResultsCollectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        searchBar.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingLeading: 8,
            paddingTrailing: 8
        )

        genreCollectionView.anchor(
            top: searchBar.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 8,
            height: 40
        )

        mainTableView.anchor(
            top: genreCollectionView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 8
        )

        searchResultsCollectionView.anchor(
            top: genreCollectionView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )

        loadingIndicator.center(in: view)
        emptyStateLabel.center(in: view)
    }

    private func bindViewModel() {
        viewModel.refreshUI = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }

        viewModel.showError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }

        viewModel.showLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
        }
    }

    private func loadData() {
        guard !viewModel.isDataLoaded else {
            updateUI()
            return
        }
        Task {
            await viewModel.loadInitialData()
        }
    }

    private func updateUI() {
        genreCollectionView.reloadData()
        mainTableView.reloadData()
        searchResultsCollectionView.reloadData()

        let isSearching = viewModel.isSearching

        if isSearching {
            mainTableView.isHidden = true
            searchResultsCollectionView.isHidden = false
        } else {
            mainTableView.isHidden = false
            searchResultsCollectionView.isHidden = true
        }

        if isSearching && viewModel.searchResults.isEmpty && !loadingIndicator.isAnimating {
            emptyStateLabel.isHidden = false
        } else {
            emptyStateLabel.isHidden = true
        }
    }

    private func applyFilter(at index: Int) {
        selectedFilterIndex = index
        isFiltering = index != 0
        genreCollectionView.reloadData()
        updateUI()
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension DiscoverViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.clearSearch()
    }
}

extension DiscoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == genreCollectionView {
            return viewModel.categories.count
        }
        return viewModel.searchResults.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == genreCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreFilterCell.reuseIdentifier, for: indexPath) as? GenreFilterCell else {
                return UICollectionViewCell()
            }
            let category = viewModel.categories[indexPath.item]
            cell.configure(with: category.name, isChosen: selectedFilterIndex == indexPath.item)
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCollectionViewCell.reuseIdentifier, for: indexPath) as? AnimeCollectionViewCell else {
            return UICollectionViewCell()
        }
        let anime = viewModel.searchResults[indexPath.item]
        cell.configure(with: anime)
        return cell
    }
}

extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == genreCollectionView {
            let name = viewModel.categories[indexPath.item].name
            let font = UIFont.systemFont(ofSize: 14, weight: .medium)
            let textWidth = ceil((name as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 32),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
            ).width)
            return CGSize(width: textWidth + 28, height: 32)
        }

        let width = (UIScreen.main.bounds.width - 48) / 3
        return CGSize(width: width, height: width * 1.8)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == genreCollectionView {
            applyFilter(at: indexPath.item)
            return
        }

        let anime = viewModel.searchResults[indexPath.item]
        let detailVC = AnimeDetailViewController(anime: anime)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension DiscoverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            let categoryId = viewModel.categories[selectedFilterIndex].id
            return viewModel.getAnime(for: categoryId).count
        }
        return viewModel.categories.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFiltering {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AnimeTableViewCell.reuseIdentifier, for: indexPath) as? AnimeTableViewCell else {
                return UITableViewCell()
            }
            let categoryId = viewModel.categories[selectedFilterIndex].id
            let anime = viewModel.getAnime(for: categoryId)[indexPath.row]
            cell.configure(with: anime)
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        let category = viewModel.categories[indexPath.row + 1]
        let animeList = viewModel.getAnime(for: category.id)
        cell.configure(with: category.name, animeList: animeList)
        cell.delegate = self
        return cell
    }
}

extension DiscoverViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isFiltering else { return }
        let categoryId = viewModel.categories[selectedFilterIndex].id
        let anime = viewModel.getAnime(for: categoryId)[indexPath.row]
        let detailVC = AnimeDetailViewController(anime: anime)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFiltering {
            return UITableView.automaticDimension
        }
        return 284
    }
}

extension DiscoverViewController: CategoryTableViewCellDelegate {
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelectAnime anime: Anime) {
        let detailVC = AnimeDetailViewController(anime: anime)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
