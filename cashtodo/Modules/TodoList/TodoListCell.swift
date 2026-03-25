import UIKit

final class TodoListCell: UITableViewCell {

    // MARK: - Constants

    static let reuseId = "TodoListCell"

    // MARK: - Callbacks

    var onCheckboxTapped: (() -> Void)?

    // MARK: - UI

    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentMode = .scaleAspectFit
        button.tintColor = .systemBlue
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.title)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.subtitle)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let linkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: Constants.Icon.link))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    override func prepareForReuse() {
        super.prepareForReuse()
        onCheckboxTapped = nil
    }

    func configure(with viewModel: TodoListCellViewModel) {
        let iconName = viewModel.isCompleted
            ? Constants.Icon.completed
            : Constants.Icon.incomplete
        checkboxButton.setImage(UIImage(systemName: iconName), for: .normal)
        checkboxButton.tintColor = viewModel.isCompleted ? .systemGreen : .systemBlue

        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.isCompleted ? .secondaryLabel : .label

        if let priceText = viewModel.priceText {
            priceLabel.text = priceText
            priceLabel.isHidden = false
        } else {
            priceLabel.text = nil
            priceLabel.isHidden = true
        }

        linkImageView.isHidden = !viewModel.hasLinkedOperations
    }

    // MARK: - Setup

    @objc private func checkboxTapped() {
        onCheckboxTapped?()
    }

    private func setupUI() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator

        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)

        contentView.addSubview(checkboxButton)
        checkboxButton.pinLeft(to: contentView, Constants.UI.smallPadding)
        checkboxButton.pinCenterY(to: contentView)
        checkboxButton.setWidth(Constants.UI.minTapSize)
        checkboxButton.setHeight(Constants.UI.minTapSize)

        contentView.addSubview(linkImageView)
        linkImageView.pinRight(to: contentView, Constants.UI.smallPadding)
        linkImageView.pinCenterY(to: contentView)
        linkImageView.setWidth(Constants.UI.iconSizeSmall)
        linkImageView.setHeight(Constants.UI.iconSizeSmall)

        contentView.addSubview(priceLabel)
        priceLabel.pinRight(to: linkImageView.leadingAnchor, Constants.UI.smallPadding)
        priceLabel.pinCenterY(to: contentView)

        contentView.addSubview(titleLabel)
        titleLabel.pinLeft(to: checkboxButton.trailingAnchor, Constants.UI.smallPadding)
        titleLabel.pinCenterY(to: contentView)
        titleLabel.pinRight(to: priceLabel.leadingAnchor, Constants.UI.smallPadding)
    }
}
