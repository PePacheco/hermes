import UIKit
import Combine

class RepositoriesListViewController: UIViewController, Coordinating {

    var coordinator: Coordinator?
    private let viewModel = RepositoriesListViewModel()
    private var cancellables: [AnyCancellable] = []
    private var currentIndex = 1
    private var isFetching: Bool = false
    
    // MARK: - Outlets
    @IBOutlet weak var repositoriesTableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRefresh()
        bindViewModel()
        viewModel.search(phrase: "graphql")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private functions
    
    private func bindViewModel() {
        viewModel.$repositories.sink {[weak self] repositories in
            DispatchQueue.main.async {
                self?.repositoriesTableView.reloadData()
            }
        }.store(in: &cancellables)
        
        viewModel.$isLoading.sink {[weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.presentLoadingScreen(completion: nil)
                } else {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }.store(in: &cancellables)
        
        viewModel.$error.sink {[weak self] error in
            DispatchQueue.main.async {
                if !error.isEmpty {
                    self?.presentAlert(message: error)
                }
            }
        }.store(in: &cancellables)
        
        viewModel.$isFetchingForward.sink {[weak self] isFetching in
            self?.isFetching = isFetching
        }.store(in: &cancellables)
    }
    
    private func configureRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.repositoriesTableView.refreshControl = refresh
    }
    
    private func configureUI() {
        title = "Repositories List"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        repositoriesTableView.dataSource = self
        repositoriesTableView.delegate = self
    }
    
    @objc private func handleRefresh() {
        viewModel.search(phrase: "graphql")
    }
}

extension RepositoriesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Repositories-Cell", for: indexPath) as? RepositoriesListTableViewCell else {
            fatalError("Could not deque reusable cell and cast it correctly")
        }
        let cellViewModel = viewModel.fetchCellViewModel(indexPath: indexPath)
        cell.configureUI(cellViewModel: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.repositories.count - 3 && !isFetching {
            viewModel.searchForward(phrase: "graphql")
        }
    }
}
