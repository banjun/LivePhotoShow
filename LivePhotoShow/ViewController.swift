import UIKit
import Photos
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
    private lazy var livePhotoButton: UIButton = UIButton(type: .system) ※ { b in
        b.setTitle("Show Live Photos", for: .normal)
        b.addTarget(self, action: #selector(showLivePhotos), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "LivePhotoShow"
        view.backgroundColor = .white

        let autolayout = northLayoutFormat([:], [
            "countTitle": countTitleLabel,
            "count": countLabel,
            "livephoto": livePhotoButton])
        autolayout("H:|[countTitle]|")
        autolayout("H:|[count]|")
        autolayout("H:|[livephoto]|")
        autolayout("V:|-[countTitle]-[count]-[livephoto]")
    }

    var livephotoAssets: [PHAsset] = []

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) > 0 && pixelHeight == %f", PHAssetMediaSubtype.photoLive.rawValue, UIScreen.main.bounds.height * UIScreen.main.scale)
        let result = PHAsset.fetchAssets(with: .image, options: options)
        NSLog("%@", "count = \(result.count)")
        countLabel.text = "\(result.count) live photos"

        let shuffledAssets = shuffled(result.objects(at: IndexSet(integersIn: 0..<result.count)))
        livephotoAssets = shuffledAssets
    }

    @objc private func showLivePhotos() {
        let lpvc = LivePhotoViewController(livephotoAssets: livephotoAssets)
        show(lpvc, sender: nil)
    }
}


// from http://qiita.com/satoshia/items/13d0842a784f0f91c018

func shuffle<T>(_ array: inout [T]) {
    for j in (0..<array.count).reversed() {
        let k = Int(arc4random_uniform(UInt32(j + 1))) // 0 <= k <= j
        guard k != j else { continue }
        swap(&array[k], &array[j])
    }
}

func shuffled<S: Sequence>(_ source: S) -> [S.Iterator.Element] {
    var copy = Array<S.Iterator.Element>(source)
    shuffle(&copy)
    return copy
}
