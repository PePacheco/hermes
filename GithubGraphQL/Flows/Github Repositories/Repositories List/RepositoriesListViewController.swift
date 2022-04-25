import UIKit
import RxSwift
import RxCocoa

class RepositoriesListViewController: UIViewController, Coordinating {

    var coordinator: Coordinator?
    private let viewModel = RepositoriesListViewModel()
    private var cancellables: [AnyCancellable] = []
    private var currentIndex = 1
    private var isFetching: Bool = false
    private let disposeBag = DisposeBag()
    
    // MARK: - Outlets
    @IBOutlet weak var repositoriesTableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRefresh()
        configureTableView()
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
        viewModel.isLoadingObservable.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.presentLoadingScreen(completion: nil)
                } else {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }.disposed(by: disposeBag)

        
        viewModel.errorObservable.bind {[weak self] error in
            DispatchQueue.main.async {
                if !error.isEmpty {
                    self?.presentAlert(message: error)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.isFetchingForwardObservable.bind {[weak self] isFetching in
            self?.isFetching = isFetching
        }.disposed(by: disposeBag)
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
    }
    
    private func configureTableView() {
        viewModel.repositoriesObservable.bind(to: repositoriesTableView.rx.items(cellIdentifier: "Repositories-Cell", cellType: RepositoriesListTableViewCell.self)) { [weak self] row, model, cell in
            guard let self = self else { return }
            let cellViewModel = self.viewModel.fetchCellViewModel(at: IndexPath(row: row, section: 0))
            cell.configureUI(cellViewModel: cellViewModel)
        }.disposed(by: disposeBag)
        
        repositoriesTableView.rx.willDisplayCell.subscribe(onNext: {[weak self] cell, indexPath in
            guard let self = self else { return }
            if indexPath.row == self.viewModel.getRepositoriesCount() - 3 && !self.isFetching {
                self.viewModel.searchForward(phrase: "graphql")
            }
        }).disposed(by: disposeBag)
    }
    
    @objc private func handleRefresh() {
        viewModel.search(phrase: "graphql")
    }
}
