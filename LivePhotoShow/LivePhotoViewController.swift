import UIKit
import PhotosUI
import NorthLayout
import Ikemen

class LivePhotoViewController: UIViewController, PHLivePhotoViewDelegate {
    let livephotoAssets: [PHAsset]
    private var unplayedAssets: [PHAsset]

    let livephotoView: PHLivePhotoView
    let snapshotView1 = UIImageView()
    let snapshotView2 = UIImageView()

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

        let autolayout = northLayoutFormat([:], [
            "livephoto": livephotoView,
            "snapshotView1": snapshotView1,
            "snapshotView2": snapshotView2,
            ])
        autolayout("H:|[livephoto]|")
        autolayout("V:|[livephoto]|")
        autolayout("H:|[snapshotView1]|")
        autolayout("V:|[snapshotView1]|")
        autolayout("H:|[snapshotView2]|")
        autolayout("V:|[snapshotView2]|")
        view.bringSubview(toFront: snapshotView1)
        view.bringSubview(toFront: snapshotView2)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showNext()
    }

    func showNext() {
        guard let asset = unplayedAssets.first else { return }
        unplayedAssets.removeFirst()

        let opt1 = PHImageRequestOptions()
        opt1.deliveryMode = .highQualityFormat
        opt1.isNetworkAccessAllowed = true
//        opt1.isSynchronous = true

        PHImageManager.default().requestImage(for: asset, targetSize: view.bounds.size, contentMode: .aspectFill, options: opt1) { image, d in

            PHImageManager.default().requestLivePhoto(for: asset, targetSize: self.view.bounds.size, contentMode: .aspectFill, options: nil) { photo, d in
                DispatchQueue.main.async {
//                    self.snapshotView1.image = self.snapshotView2.image
                    self.snapshotView2.image = image
                    self.snapshotView2.alpha = 0

//                    self.snapshotView1.isHidden = false
                    self.snapshotView2.isHidden = false
//                    self.view.bringSubview(toFront: self.snapshotView2)

                    NSLog("%@", "\(self.snapshotView1.image?.size), \(self.snapshotView2.image?.size)")

                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5, delay: 0.1, options: [], animations: {
                            self.snapshotView2.alpha = 0.5
                        }) { finished in
//                            self.livephotoView.isHidden = false
//                            self.snapshotView1.isHidden = true
                            self.snapshotView2.isHidden = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.livephotoView.livePhoto = photo
//                                self.livephotoView.isHidden = false
                                self.livephotoView.startPlayback(with: .full)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: PHLivePhotoViewDelegate

    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {

    }

    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showNext()
            }
        }
    }
}
