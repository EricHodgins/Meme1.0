//
//  ViewController.swift
//  Meme1.0
//
//  Created by Eric Hodgins on 2015-12-05.
//  Copyright © 2015 Eric Hodgins. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var memeTextAttributes = [String: AnyObject]()
    var topTextFieldEdited = false
    var bottomTextFieldEdited = false
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var shareMemeActivityButton: UIBarButtonItem!
    
    //MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        shareMemeActivityButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        setupTextAttributesWithFontName("HelveticaNeue-CondensedBlack")
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        unscribeToKeyboardNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    //MARK: Text Field Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == topTextField && !topTextFieldEdited {
            textField.text = ""
            topTextFieldEdited = true
        }
        
        if textField == bottomTextField && !bottomTextFieldEdited {
            textField.text = ""
            bottomTextFieldEdited = true
        }
    }
    
    func setupTextAttributesWithFontName(fontName: String) {
        memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: fontName, size: 40)!,
            NSStrokeWidthAttributeName : -5.0
        ]
        
        //topTextField.text = "TOP"
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        topTextField.adjustsFontSizeToFitWidth = true
        
        //bottomTextField.text = "BOTTOM"
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .Center
        bottomTextField.adjustsFontSizeToFitWidth = true
    }
    
    //MARK: Keyboard Notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.CGRectValue().height
    }
    
    func unscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }


    
    //MARK: Picking an image
    @IBAction func camerWasPicked(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }

    @IBAction func albumWasPicked(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            mainImageView.image = image
            shareMemeActivityButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Share meme
    @IBAction func shareMeme(sender: AnyObject) {
        
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage as UIImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            print("\(activity), \(success), \(items), \(error)")
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    func generateMemedImage() -> UIImage {
        // hide tool bar and nav bar
        toolBar.hidden = true
        navBar.hidden = true
        
        //Render view an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBar.hidden = false
        navBar.hidden = false
        
        return memedImage
    }

    //MARK: Save
    func save() {
        // save the meme
        //let meme = Meme(topTextField: topTextField.text!, bottomTextField: bottomTextField.text!, image: mainImageView.image!, memedImage: generateMemedImage())
    }
    
    //MARK: Cancel was pressed
    @IBAction func cancelWasPressed(sender: AnyObject) {
        mainImageView.image = nil
        shareMemeActivityButton.enabled = false
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        topTextFieldEdited = false
        bottomTextFieldEdited = false
    }
    
    
    //MARK: Action Options
    @IBAction func changeFont(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Font", preferredStyle: .ActionSheet)
        
        let copperFont = UIAlertAction(title: "Copperplate", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.setupTextAttributesWithFontName("Copperplate")
        }
        
        let helveticaNeue = UIAlertAction(title: "HelveticaNeue", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.setupTextAttributesWithFontName("HelveticaNeue-CondensedBlack")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        optionMenu.addAction(copperFont)
        optionMenu.addAction(helveticaNeue)
        optionMenu.addAction(cancel)
        
        presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func changePictureContentMode(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Content Mode", preferredStyle: .ActionSheet)
        let aspectFit = UIAlertAction(title: "Aspect Fit", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.mainImageView.contentMode = .ScaleAspectFit
        }
        
        let aspectFill = UIAlertAction(title: "Aspect Fill", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.mainImageView.contentMode = .ScaleAspectFill
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        optionMenu.addAction(aspectFit)
        optionMenu.addAction(aspectFill)
        optionMenu.addAction(cancel)
        
        presentViewController(optionMenu, animated: true, completion: nil)
    }

}

