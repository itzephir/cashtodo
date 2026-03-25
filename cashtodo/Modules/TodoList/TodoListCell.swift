import UIKit

final class TodoListCell: UITableViewCell {

    // MARK: - Constants

    static let reuseId = "TodoListCell"

    // MARK: - UI

    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
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

    func configure(with viewModel: TodoListCellViewModel) {
        let iconName = viewModel.isCompleted
            ? Constants.Icon.completed
            : Constants.Icon.incomplete
        checkboxImageView.image = UIImage(systemName: iconName)
        checkboxImageView.tintColor = viewModel.isCompleted ? .systemGreen : .systemBlue

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

    private func setupUI() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator

        contentView.addSubview(checkboxImageView)
        checkboxImageView.pinLeft(to: contentView, Constants.UI.standardPadding)
        checkboxImageView.pinCenterY(to: contentView)
        checkboxImageView.setWidth(24)
        checkboxImageView.setHeight(24)

        contentView.addSubview(linkImageView)
        linkImageView.pinRight(to: contentView, Constants.UI.smallPadding)
        linkImageView.pinCenterY(to: contentView)
        linkImageView.setWidth(16)
        linkImageView.setHeight(16)

        contentView.addSubview(priceLabel)
        priceLabel.pinRight(to: linkImageView.leadingAnchor, Constants.UI.smallPadding)
        priceLabel.pinCenterY(to: contentView)

        contentView.addSubview(titleLabel)
        titleLabel.pinLeft(to: checkboxImageView.trailingAnchor, Constants.UI.smallPadding)
        titleLabel.pinCenterY(to: contentView)
        titleLabel.pinRight(to: priceLabel.leadingAnchor, Constants.UI.smallPadding)
    }
}
