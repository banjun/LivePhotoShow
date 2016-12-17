import UIKit
import Photos
import PhotosUI
import NorthLayout
import Ikemen

class ViewController: UIViewController {
    let countTitleLabel = UILabel() ※ { l in
        l.text = "Live Photos in Photo Library"
        l.textAlignment = .center
    }
    let countLabel = UILabel() ※ { l in
        l.text = "(fetching...)"
        l.textAlignment = .center
    }
    private lazy var livePhotoView: PHLivePhotoView = PHLivePhotoView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "LivePhotoShow"
        view.backgroundColor = .white

        let autolayout = northLayoutFormat([:], [
            "countTitle": countTitleLabel,
            "count": countLabel,
            "livephoto": livePhotoView])
        autolayout("H:|[countTitle]|")
        autolayout("H:|[count]|")
        autolayout("H:|[livephoto]|")
        autolayout("V:|-[countTitle]-[count]-[livephoto]|")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) > 0 && pixelHeight == 1334", PHAssetMediaSubtype.photoLive.rawValue)
        let result = PHAsset.fetchAssets(with: .image, options: options)
        NSLog("%@", "count = \(result.count)")
        countLabel.text = "\(result.count) live photos"

        guard let asset = result.firstObject else { return }
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: view.bounds.size, contentMode: .aspectFill, options: nil) { photo, d in
            DispatchQueue.main.async {
                self.livePhotoView.livePhoto = photo
                self.livePhotoView.startPlayback(with: .full)
            }
        }
    }
}

