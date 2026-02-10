//
//  DiscoverViewController.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import UIKit

final class DiscoverViewController: UIViewController {

    private let viewModel = DiscoverViewModel.shared

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search anime..."
        sb.searchBarStyle = .minimal
        return sb
    }()

    private lazy var genreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(GenreFilterCell.self, forCellWithReuseIdentifier: GenreFilterCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.tag = 999
        return cv
    }()

    private lazy var mainScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView = UIView()
    private var categoryViews: [(label: UILabel, collectionView: UICollectionView)] = []
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
        cv.tag = 1000
        cv.isHidden = true
        return cv
    }()

    private lazy var filteredResultsTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(AnimeTableViewCell.self, forCellReuseIdentifier: AnimeTableViewCell.reuseIdentifier)
        tv.dataSource = self
        tv.isHidden = true
        return tv
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
        setupUI()
        setupBindings()
        loadData()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.theme.background
        navigationController?.navigationBar.prefersLargeTitles = false

        searchBar.delegate = self

        view.addSubview(searchBar)
        view.addSubview(genreCollectionView)
        view.addSubview(mainScrollView)
        view.addSubview(searchResultsCollectionView)
        view.addSubview(filteredResultsTableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        mainScrollView.addSubview(contentView)

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

        mainScrollView.anchor(
            top: genreCollectionView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )

        contentView.anchor(
            top: mainScrollView.topAnchor,
            leading: mainScrollView.leadingAnchor,
            bottom: mainScrollView.bottomAnchor,
            trailing: mainScrollView.trailingAnchor
        )
        contentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor).isActive = true

        var previousView: UIView? = nil

        for (index, category) in viewModel.categories.enumerated() {
            if category.id == 0 { continue }
            let label = createCategoryLabel(title: category.name)
            let collectionView = createCategoryCollectionView(tag: index)

            contentView.addSubview(label)
            contentView.addSubview(collectionView)

            categoryViews.append((label: label, collectionView: collectionView))

            if let previous = previousView {
                label.anchor(
                    top: previous.bottomAnchor,
                    leading: contentView.leadingAnchor,
                    trailing: contentView.trailingAnchor,
                    paddingTop: 24,
                    paddingLeading: 16,
                    paddingTrailing: 16
                )
            } else {
                label.anchor(
                    top: contentView.topAnchor,
                    leading: contentView.leadingAnchor,
                    trailing: contentView.trailingAnchor,
                    paddingTop: 8,
                    paddingLeading: 16,
                    paddingTrailing: 16
                )
            }

            collectionView.anchor(
                top: label.bottomAnchor,
                leading: contentView.leadingAnchor,
                trailing: contentView.trailingAnchor,
                paddingTop: 12,
                height: 240
            )

            previousView = collectionView
        }

        if let lastView = previousView {
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }

        searchResultsCollectionView.anchor(
            top: genreCollectionView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )

        filteredResultsTableView.anchor(
            top: genreCollectionView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )

        loadingIndicator.center(in: view)
        emptyStateLabel.center(in: view)
    }

    private func createCategoryLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        return label
    }

    private func createCategoryCollectionView(tag: Int) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 240)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(AnimeCollectionViewCell.self, forCellWithReuseIdentifier: AnimeCollectionViewCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.tag = tag
        return cv
    }

    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
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
        genreCollectionView.selectItem(at: IndexPath(item: selectedFilterIndex, section: 0), animated: false, scrollPosition: [])
        for categoryView in categoryViews {
            categoryView.collectionView.reloadData()
        }
        searchResultsCollectionView.reloadData()
        filteredResultsTableView.reloadData()

        let isSearching = viewModel.isSearching

        if isSearching {
            mainScrollView.isHidden = true
            filteredResultsTableView.isHidden = true
            searchResultsCollectionView.isHidden = false
        } else if isFiltering {
            mainScrollView.isHidden = true
            searchResultsCollectionView.isHidden = true
            filteredResultsTableView.isHidden = false
        } else {
            mainScrollView.isHidden = false
            searchResultsCollectionView.isHidden = true
            filteredResultsTableView.isHidden = true
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
        if collectionView.tag == 999 {
            return viewModel.categories.count
        }

        if collectionView.tag == 1000 {
            return viewModel.searchResults.count
        }

        let categoryId = viewModel.categories[collectionView.tag].id
        return viewModel.getAnime(for: categoryId).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 999 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreFilterCell.reuseIdentifier, for: indexPath) as! GenreFilterCell
            let category = viewModel.categories[indexPath.item]
            cell.configure(with: category.name)
            cell.isSelected = selectedFilterIndex == indexPath.item
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCollectionViewCell.reuseIdentifier, for: indexPath) as! AnimeCollectionViewCell

        let anime: Anime
        if collectionView.tag == 1000 {
            anime = viewModel.searchResults[indexPath.item]
        } else {
            let categoryId = viewModel.categories[collectionView.tag].id
            anime = viewModel.getAnime(for: categoryId)[indexPath.item]
        }

        cell.configure(with: anime)
        return cell
    }
}

extension DiscoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 999 {
            applyFilter(at: indexPath.item)
            return
        }

        let anime: Anime
        if collectionView.tag == 1000 {
            anime = viewModel.searchResults[indexPath.item]
        } else {
            let categoryId = viewModel.categories[collectionView.tag].id
            anime = viewModel.getAnime(for: categoryId)[indexPath.item]
        }

    }
}

extension DiscoverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoryId = viewModel.categories[selectedFilterIndex].id
        return viewModel.getAnime(for: categoryId).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnimeTableViewCell.reuseIdentifier, for: indexPath) as! AnimeTableViewCell
        let categoryId = viewModel.categories[selectedFilterIndex].id
        let anime = viewModel.getAnime(for: categoryId)[indexPath.row]
        cell.configure(with: anime)
        return cell
    }
}

