import UIKit

final class TodoListViewController: UIViewController {

    // MARK: - VIPER

    var interactor: TodoListBusinessLogic?
    var router: TodoListRoutingLogic?

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(systemName: Constants.Icon.emptyState)
        )
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyTodos
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: Constants.Font.title)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Data

    private var viewModels: [TodoListCellViewModel] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        configureEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.loadTodos()
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        navigationItem.title = L10n.todoTitle
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.Icon.add),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.reuseId)
        tableView.rowHeight = Constants.UI.cellHeight

        view.addSubview(tableView)
        tableView.pin(to: view)
    }

    private func configureEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.pinCenterX(to: view)
        emptyStateView.pinCenterY(to: view)

        emptyStateView.addSubview(emptyImageView)
        emptyImageView.pinTop(to: emptyStateView)
        emptyImageView.pinCenterX(to: emptyStateView)
        emptyImageView.setWidth(Constants.UI.iconSizeLarge)
        emptyImageView.setHeight(Constants.UI.iconSizeLarge)

        emptyStateView.addSubview(emptyLabel)
        emptyLabel.pinTop(to: emptyImageView.bottomAnchor, Constants.UI.smallPadding)
        emptyLabel.pinHorizontal(to: emptyStateView)
        emptyLabel.pinBottom(to: emptyStateView)
    }

    // MARK: - Actions

    @objc
    private func addTapped() {
        router?.navigateToCreate()
    }

    private func updateEmptyState() {
        emptyStateView.isHidden = !viewModels.isEmpty
        tableView.isHidden = viewModels.isEmpty
    }
}

// MARK: - TodoListDisplayLogic

extension TodoListViewController: TodoListDisplayLogic {
    func displayTodos(_ viewModels: [TodoListCellViewModel]) {
        self.viewModels = viewModels
        tableView.reloadData()
        updateEmptyState()
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(title: L10n.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.buttonOK, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoListCell.reuseId,
            for: indexPath
        ) as? TodoListCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        cell.onCheckboxTapped = { [weak self] in
            self?.interactor?.toggleCompletion(at: indexPath.row)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewModel = viewModels[indexPath.row]
        router?.navigateToDetail(todoId: viewModel.id)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: L10n.buttonDelete
        ) { [weak self] _, _, completionHandler in
            self?.interactor?.deleteTodo(at: indexPath.row)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: Constants.Icon.delete)

        let toggleAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { [weak self] _, _, completionHandler in
            self?.interactor?.toggleCompletion(at: indexPath.row)
            completionHandler(true)
        }
        let isCompleted = viewModels[indexPath.row].isCompleted
        toggleAction.image = UIImage(
            systemName: isCompleted ? Constants.Icon.incomplete : Constants.Icon.completed
        )
        toggleAction.backgroundColor = .systemGreen

        return UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
    }
}
