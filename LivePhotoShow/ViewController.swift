import UIKit
import Photos

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white


        let lib = PHPhotoLibrary.shared()

        var options = PHFetchOptions()
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) > 0", PHAssetMediaSubtype.photoLive.rawValue)
        let result = PHAsset.fetchAssets(with: .image, options: options)
        NSLog("%@", "count = \(result.count)")
    }
}

