import UIKit

final class OperationListCell: UITableViewCell {

    // MARK: - UI

    private let categoryIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.title, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.price, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.caption)
        label.textColor = .secondaryLabel
        return label
    }()

    private let linkedTodoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.caption)
        label.textColor = .systemBlue
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with viewModel: OperationListCellViewModel) {
        categoryIconView.image = UIImage(systemName: viewModel.categoryIcon)
        titleLabel.text = viewModel.title
        amountLabel.text = viewModel.amountText
        dateLabel.text = viewModel.dateText

        if let todoTitle = viewModel.linkedTodoTitle {
            linkedTodoLabel.text = "\(Constants.Icon.link) \(todoTitle)"
            linkedTodoLabel.isHidden = false
        } else {
            linkedTodoLabel.isHidden = true
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        let iconSize: Double = 28

        contentView.addSubview(categoryIconView)
        categoryIconView.pinLeft(to: contentView, Constants.UI.standardPadding)
        categoryIconView.pinCenterY(to: contentView)
        categoryIconView.setWidth(iconSize)
        categoryIconView.setHeight(iconSize)

        contentView.addSubview(amountLabel)
        amountLabel.pinRight(to: contentView, Constants.UI.standardPadding)
        amountLabel.pinCenterY(to: contentView)
        amountLabel.setWidth(mode: .grOE, Constants.UI.minPriceWidth)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, linkedTodoLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        contentView.addSubview(textStack)
        textStack.pinLeft(to: categoryIconView.trailingAnchor, Constants.UI.smallPadding)
        textStack.pinRight(to: amountLabel.leadingAnchor, Constants.UI.smallPadding)
        textStack.pinTop(to: contentView, Constants.UI.smallPadding)
        textStack.pinBottom(to: contentView, Constants.UI.smallPadding)
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryIconView.image = nil
        titleLabel.text = nil
        amountLabel.text = nil
        dateLabel.text = nil
        linkedTodoLabel.text = nil
        linkedTodoLabel.isHidden = true
    }
}
