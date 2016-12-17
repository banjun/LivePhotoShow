import UIKit
import PhotosUI
import NorthLayout
import Ikemen

class LivePhotoViewController: UIViewController, PHLivePhotoViewDelegate {
    let livephotoAssets: [PHAsset]
    private var unplayedAssets: [PHAsset]

    let livephotoView: PHLivePhotoView

    public init(livephotoAssets: [PHAsset]) {
        self.livephotoAssets = livephotoAssets
        self.unplayedAssets = livephotoAssets
        self.livephotoView = PHLivePhotoView()
        super.init(nibName: nil, bundle: nil)
        self.livephotoView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        let autolayout = northLayoutFormat([:], ["livephoto": livephotoView])
        autolayout("H:|[livephoto]|")
        autolayout("V:|[livephoto]|")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showNext()
    }

    func showNext() {
        guard let asset = unplayedAssets.first else { return }
        unplayedAssets.removeFirst()

        PHImageManager.default().requestLivePhoto(for: asset, targetSize: view.bounds.size, contentMode: .aspectFill, options: nil) { photo, d in
            DispatchQueue.main.async {
                if let snapshotView = self.livephotoView.snapshotView(afterScreenUpdates: false) {
                    snapshotView.frame = self.livephotoView.frame
                    self.view.addSubview(snapshotView)
                    UIView.animate(withDuration: 0.5, animations: {
                        snapshotView.alpha = 0.0
                    }) { finished in
                        snapshotView.removeFromSuperview()
                    }
                }
                self.livephotoView.livePhoto = photo

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.livephotoView.startPlayback(with: .full)
                }
            }
        }
    }

    // MARK: PHLivePhotoViewDelegate

    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {

    }

    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showNext()
            }
        }
    }
}
