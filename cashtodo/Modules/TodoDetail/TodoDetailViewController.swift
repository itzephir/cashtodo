import UIKit

final class TodoDetailViewController: UIViewController, TodoDetailDisplayLogic {

    // MARK: - VIPER references

    var interactor: (TodoDetailBusinessLogic & TodoDetailDataStore)?
    var router: TodoDetailRoutingLogic?

    // MARK: - State

    private var isEditingMode = false {
        didSet { updateEditingState() }
    }

    private var isNewTodo: Bool {
        interactor?.todoId == nil
    }

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Constants.UI.standardPadding
        return sv
    }()

    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = L10n.labelName
        tf.font = .systemFont(ofSize: Constants.Font.largeTitle, weight: .bold)
        tf.borderStyle = .none
        tf.returnKeyType = .next
        return tf
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelDescription
        label.font = .systemFont(ofSize: Constants.Font.subtitle, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: Constants.Font.title)
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = Constants.UI.smallCornerRadius
        tv.textContainerInset = UIEdgeInsets(
            top: Constants.UI.smallPadding,
            left: Constants.UI.smallPadding,
            bottom: Constants.UI.smallPadding,
            right: Constants.UI.smallPadding
        )
        tv.isScrollEnabled = false
        return tv
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelPrice
        label.font = .systemFont(ofSize: Constants.Font.subtitle, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let priceTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = L10n.placeholderPrice
        tf.font = .systemFont(ofSize: Constants.Font.price)
        tf.keyboardType = .decimalPad
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let operationsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelLinkedOps
        label.font = .systemFont(ofSize: Constants.Font.title, weight: .semibold)
        return label
    }()

    private let operationsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Constants.UI.smallPadding
        return sv
    }()

    private let emptyOperationsLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyLinkedOps
        label.font = .systemFont(ofSize: Constants.Font.subtitle)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.buttonDelete, for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Font.title, weight: .medium)
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = Constants.UI.cornerRadius
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
        interactor?.loadTodo()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        scrollView.pinLeft(to: view.leadingAnchor)
        scrollView.pinRight(to: view.trailingAnchor)
        scrollView.pinBottom(to: view.bottomAnchor)

        scrollView.addSubview(contentStackView)
        contentStackView.pinTop(to: scrollView.contentLayoutGuide.topAnchor, Constants.UI.standardPadding)
        contentStackView.pinLeft(to: scrollView.contentLayoutGuide.leadingAnchor, Constants.UI.standardPadding)
        contentStackView.pinRight(to: scrollView.contentLayoutGuide.trailingAnchor, Constants.UI.standardPadding)
        contentStackView.pinBottom(to: scrollView.contentLayoutGuide.bottomAnchor, Constants.UI.standardPadding)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.widthAnchor.constraint(
            equalTo: scrollView.frameLayoutGuide.widthAnchor,
            constant: -2 * Constants.UI.standardPadding
        ).isActive = true

        contentStackView.addArrangedSubview(titleTextField)

        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(descriptionTextView)
        descriptionTextView.setHeight(mode: .grOE, 80)

        contentStackView.addArrangedSubview(priceLabel)
        contentStackView.addArrangedSubview(priceTextField)

        contentStackView.addArrangedSubview(operationsHeaderLabel)
        contentStackView.addArrangedSubview(operationsStackView)
        contentStackView.addArrangedSubview(emptyOperationsLabel)

        let spacer = UIView()
        contentStackView.addArrangedSubview(spacer)
        spacer.setHeight(mode: .grOE, Constants.UI.standardPadding)

        contentStackView.addArrangedSubview(deleteButton)
        deleteButton.setHeight(Constants.UI.buttonHeight)
    }

    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    // MARK: - Navigation bar

    private func updateEditingState() {
        titleTextField.isEnabled = isEditingMode
        descriptionTextView.isEditable = isEditingMode
        priceTextField.isEnabled = isEditingMode

        descriptionTextView.layer.borderColor = isEditingMode
            ? UIColor.separator.cgColor
            : UIColor.clear.cgColor

        if isEditingMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: L10n.buttonSave,
                style: .done,
                target: self,
                action: #selector(saveButtonTapped)
            )
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: L10n.buttonCancel,
                style: .plain,
                target: self,
                action: #selector(cancelButtonTapped)
            )
            deleteButton.isHidden = true
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: Constants.Icon.edit),
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
            navigationItem.leftBarButtonItem = nil
            deleteButton.isHidden = isNewTodo
        }
    }

    // MARK: - Actions

    @objc private func editButtonTapped() {
        isEditingMode = true
    }

    @objc private func saveButtonTapped() {
        let title = titleTextField.text ?? ""
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            displayError(L10n.errorEmptyTitle)
            return
        }
        let descriptionText = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let priceText = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        interactor?.saveTodo(
            title: title,
            descriptionText: descriptionText?.isEmpty == true ? nil : descriptionText,
            priceText: priceText?.isEmpty == true ? nil : priceText
        )
    }

    @objc private func cancelButtonTapped() {
        if isNewTodo {
            router?.dismiss()
        } else {
            isEditingMode = false
            interactor?.loadTodo()
        }
    }

    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: L10n.alertDeleteTask,
            message: L10n.alertCannotUndo,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.buttonCancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.buttonDelete, style: .destructive) { [weak self] _ in
            self?.interactor?.deleteTodo()
        })
        present(alert, animated: true)
    }

    // MARK: - TodoDetailDisplayLogic

    func displayTodo(_ viewModel: TodoDetailViewModel) {
        titleTextField.text = viewModel.title
        descriptionTextView.text = viewModel.descriptionText
        priceTextField.text = viewModel.priceText

        isEditingMode = false
        deleteButton.isHidden = false

        configureOperations(viewModel.linkedOperations)
    }

    func displayNewTodoForm() {
        titleTextField.text = ""
        descriptionTextView.text = ""
        priceTextField.text = ""
        title = L10n.todoNew

        operationsHeaderLabel.isHidden = true
        operationsStackView.isHidden = true
        emptyOperationsLabel.isHidden = true
        deleteButton.isHidden = true

        isEditingMode = true
    }

    func displaySaveSuccess() {
        router?.dismiss()
    }

    func displayDeleteSuccess() {
        router?.dismiss()
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(
            title: L10n.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.buttonOK, style: .default))
        present(alert, animated: true)
    }

    // MARK: - Operations list

    private func configureOperations(_ operations: [LinkedOperationViewModel]) {
        operationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if operations.isEmpty {
            operationsStackView.isHidden = true
            emptyOperationsLabel.isHidden = false
        } else {
            operationsStackView.isHidden = false
            emptyOperationsLabel.isHidden = true

            for operation in operations {
                let row = makeOperationRow(operation)
                operationsStackView.addArrangedSubview(row)
            }
        }
    }

    private func makeOperationRow(_ operation: LinkedOperationViewModel) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = Constants.UI.smallCornerRadius
        container.backgroundColor = .secondarySystemBackground

        let iconImageView = UIImageView(image: UIImage(systemName: operation.categoryIcon))
        iconImageView.tintColor = .label
        iconImageView.contentMode = .scaleAspectFit
        container.addSubview(iconImageView)
        iconImageView.pinLeft(to: container.leadingAnchor, Constants.UI.smallPadding)
        iconImageView.pinCenterY(to: container)
        iconImageView.setWidth(24)
        iconImageView.setHeight(24)

        let titleLabel = UILabel()
        titleLabel.text = operation.title
        titleLabel.font = .systemFont(ofSize: Constants.Font.title)
        container.addSubview(titleLabel)
        titleLabel.pinLeft(to: iconImageView.trailingAnchor, Constants.UI.smallPadding)
        titleLabel.pinCenterY(to: container)

        let amountLabel = UILabel()
        amountLabel.text = operation.amountText
        amountLabel.font = .systemFont(ofSize: Constants.Font.price, weight: .medium)
        amountLabel.textColor = .secondaryLabel
        container.addSubview(amountLabel)
        amountLabel.pinRight(to: container.trailingAnchor, Constants.UI.smallPadding)
        amountLabel.pinCenterY(to: container)
        titleLabel.pinRight(to: amountLabel.leadingAnchor, Constants.UI.smallPadding, .lsOE)

        container.setHeight(Constants.UI.cellHeight)

        return container
    }
}
