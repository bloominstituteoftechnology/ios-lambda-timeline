//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImagePostDetailTableViewController: UITableViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
//        updateViews()
    }
    
    func updateViews() {
        
//        guard let imageData = imageData,
//            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil
        }
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.author.displayName
        
        return cell
    }
    
    // MARK: - Private Methods
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        

        let filterCIImage = motionBlurFilter(colorControlFilter(cgImage))
      
        let kaleidoscopeFilter = CIFilter.kaleidoscope()
        
        
        
        return UIImage(cgImage: filterCIImage)
    }
    
    private func colorControlFilter(_ image: CIImage) -> CIImage {
        
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = convertToCIImage(image)
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        colorControlsFilter.saturation = saturationSlider.value
        
        guard let outputCIImage = colorControlsFilter.outputImage else { return nil }
        
//        guard let outputImage = context.createCGImage(outputCIImage,
//                                                      from: CGRect(origin: .zero,
//                                                                   size: image.size)) else {
//                                                                    return nil
//        }
        return outputCIImage
    }
    
    private func motionBlurFilter(_ image: CIImage) -> CIImage {
        let motionBlurFilter = CIFilter.motionBlur()
        motionBlurFilter.inputImage = convertToCIImage(image)
        motionBlurFilter.angle = blurAngleSlider.value
        motionBlurFilter.radius = blurRadiusSlider.value
        
        guard let outputCIImage = motionBlurFilter.outputImage else { return nil }
        return outputCIImage
    }
    
    private func kaleidoscopeFilter(_ image: CIImage) -> CIImage {
        guard let originalImage = originalImage else { return CIImage() }
        
        let kaleidoscopeFilter = CIFilter.kaleidoscope()
        kaleidoscopeFilter.inputImage = image
        kaleidoscopeFilter.center = CGPoint(x: originalImage.size.width / 2,
                                            y: originalImage.size.height / 2)
        kaleidoscopeFilter.angle = kaleidoscopeAngleSlider.value
        kaleidoscopeFilter.count = kaleidoscopeCountSlider.value
        
        guard let outputCIImage = kaleidoscopeFilter.outputImage else { return nil }
        return outputCIImage
    }
    
    
    
    
    
    // MARK: - Properties
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    private var context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = UIImage(data: imageData) else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
           
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    // Filter Outlets
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var blurAngleSlider: UISlider!
    @IBOutlet weak var blurRadiusSlider: UISlider!
    @IBOutlet weak var kaleidoscopeAngleSlider: UISlider!
    @IBOutlet weak var kaleidoscopeCountSlider: UISlider!
    
    // MARK: Slider events
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        updateViews()
    }

    @IBAction func blurAngleChanged(_ sender: Any) {
           updateViews()
       }
    
    @IBAction func blurRadiusChanged(_ sender: Any) {
           updateViews()
       }
}
