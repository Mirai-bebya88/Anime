//
//  SeasonalViewController.swift
//  Anime
//
//  Created by elene malakmadze on 13.02.26.
//

import UIKit

final class SeasonalViewController: UIViewController {

    private let viewModel: SeasonalViewModelProtocol = SeasonalViewModel()

    private let daySelector = DaySelector()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(AnimeTableViewCell.self, forCellReuseIdentifier: AnimeTableViewCell.reuseIdentifier)
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 116
        return tv
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No anime airing on this day"
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

    private func setUpUI() {
        view.backgroundColor = UIColor.theme.background
        title = "Seasonal"

        daySelector.delegate = self

        view.addSubview(daySelector)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        daySelector.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 16,
            height: 36
        )

        tableView.anchor(
            top: daySelector.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )

        loadingIndicator.center(in: tableView)
        emptyStateLabel.center(in: tableView)
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
        viewModel.filterByDay(daySelector.selectedDay)
        Task {
            await viewModel.loadSeasonalAnime()
        }
    }

    private func updateUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !viewModel.filteredAnime.isEmpty
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SeasonalViewController: DaySelectorDelegate {
    func daySelector(_ selector: DaySelector, didSelectDay day: String) {
        viewModel.filterByDay(day)
    }
}

extension SeasonalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredAnime.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AnimeTableViewCell.reuseIdentifier, for: indexPath) as? AnimeTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.filteredAnime[indexPath.row])
        return cell
    }
}

extension SeasonalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let anime = viewModel.filteredAnime[indexPath.row]
        let detailVC = AnimeDetailViewController(anime: anime)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
