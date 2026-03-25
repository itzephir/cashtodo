import UIKit

final class DecimalTextFieldDelegate: NSObject, UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty { return true }

        let allowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".,"))
        guard string.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return false
        }

        let current = textField.text ?? ""
        guard let swiftRange = Range(range, in: current) else { return false }
        let proposed = current.replacingCharacters(in: swiftRange, with: string)

        let normalized = proposed.replacingOccurrences(of: ",", with: ".")

        let parts = normalized.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        if parts.count > 2 { return false }
        if parts.count == 2, parts[1].count > 2 { return false }

        return true
    }
}
