
import Foundation

extension Bundle {
    private class AHTest {}

    public class var unitTest: Bundle {
        return Bundle(for: AHTest.self)
    }

    func urlSchemes(with urlName: String) -> [String] {
        let urlTypes = infoDictionary?["CFBundleURLTypes"] as? [Any]
        let urlSchema = urlTypes?.first(where: { (element) -> Bool in
            guard let urlDict = element as? [String: Any] else {
                return false
            }
            return urlDict["CFBundleURLName"] as? String == urlName
        }) as? [String: Any]

        return urlSchema?["CFBundleURLSchemes"] as? [String] ?? []
    }

}
