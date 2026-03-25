import UIKit

final class DebtCell: UITableViewCell {

    // MARK: - UI

    private let todoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.title, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Font.price, weight: .semibold)
        label.textColor = .systemRed
        label.textAlignment = .right
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

    func configure(with viewModel: DebtCellViewModel) {
        todoTitleLabel.text = viewModel.title
        priceLabel.text = viewModel.priceText
    }

    // MARK: - Layout

    private func setupLayout() {
        let iconView = UIImageView(image: UIImage(systemName: Constants.Icon.debtSection))
        iconView.tintColor = .systemRed
        iconView.contentMode = .scaleAspectFit

        contentView.addSubview(iconView)
        iconView.pinLeft(to: contentView, Constants.UI.standardPadding)
        iconView.pinCenterY(to: contentView)
        iconView.setWidth(Constants.UI.iconSize)
        iconView.setHeight(Constants.UI.iconSize)

        contentView.addSubview(priceLabel)
        priceLabel.pinRight(to: contentView, Constants.UI.standardPadding)
        priceLabel.pinCenterY(to: contentView)
        priceLabel.setWidth(mode: .grOE, Constants.UI.minPriceWidth)

        contentView.addSubview(todoTitleLabel)
        todoTitleLabel.pinLeft(to: iconView.trailingAnchor, Constants.UI.smallPadding)
        todoTitleLabel.pinRight(to: priceLabel.leadingAnchor, Constants.UI.smallPadding)
        todoTitleLabel.pinCenterY(to: contentView)
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        todoTitleLabel.text = nil
        priceLabel.text = nil
    }
}
