//
//  TextEditViewController.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/21.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift
import PKHUD
import FontAwesome_swift
import RealmSwift

#if !targetEnvironment(simulator)
import TesseractOCR
#endif

private let ContainerHeight = 50
typealias TextEditCompletion = (_ text: String) -> Void

class TextEditViewController<Digest: RealmWordDigest>: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var digest: Digest?
    private var editCompletion: TextEditCompletion?
    private var editingText: String?
    private var singleLine = false
    
    private var editorContainerNotEditingBottomConstraint: Constraint? = nil
    private var editorContainerEditingBottomConstraint: Constraint? = nil
    
    private lazy var buttonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.layoutMargins = UIEdgeInsets(horizontal: 10, vertical: 0)
        return view
    }()
    
    private lazy var btnConfirm = UIBarButtonItem(customView: {
        let btn = simpleButtonWithButtonFromAwesomefont(name: .check)
        btn.addTarget(self, action: #selector(actionConfirmEdit), for: .touchUpInside)
        return btn
    }())
    private lazy var btnPhotos = makeAFunctionalButtonFromAwesomeFont(name: .images, leadingInset: 30, topInset: 10)
    private lazy var btnCamera = makeAFunctionalButtonFromAwesomeFont(code: "fa-camera", leadingInset: 30, topInset: 10)
    
    private lazy var editor = KvasirEditor(noCarriageReturn: self.singleLine)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearupNotification()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(digest: Digest) {
        self.init(nibName: nil, bundle: nil)
        self.digest = digest
        self.singleLine = (Digest.self == RealmSentence.self)
    }
    
    convenience init(text: String, singleLine: Bool = false, editCompletion: @escaping TextEditCompletion) {
        self.init(nibName: nil, bundle: nil)
        self.editingText = text
        self.editCompletion = editCompletion
        self.singleLine = singleLine
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        HUD.show(.labeledProgress(title: "识别中", subtitle: nil))
        DispatchQueue.global(qos: .userInitiated).async {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.recognizeImage(image: image)
        }
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            DispatchQueue.main.async {
                self.editorContainerNotEditingBottomConstraint?.deactivate()
                if let editingBottomConstraint = self.editorContainerEditingBottomConstraint {
                    editingBottomConstraint.update(offset: -keyboardHeight)
                } else {
                    self.editor.snp.makeConstraints({ (make) in
                        self.editorContainerEditingBottomConstraint = make.bottom.equalTo(self.view).offset(-keyboardHeight).constraint
                    })
                }
                self.editorContainerEditingBottomConstraint?.activate()
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            DispatchQueue.main.async {
                self.editorContainerNotEditingBottomConstraint?.deactivate()
                if let editingBottomConstraint = self.editorContainerEditingBottomConstraint {
                    editingBottomConstraint.update(offset: -keyboardHeight)
                } else {
                    self.editor.snp.makeConstraints({ (make) in
                        self.editorContainerEditingBottomConstraint = make.bottom.equalTo(self.view).offset(-keyboardHeight).constraint
                    })
                }
                self.editorContainerEditingBottomConstraint?.activate()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        DispatchQueue.main.async {
            self.editorContainerEditingBottomConstraint?.deactivate()
            self.editorContainerNotEditingBottomConstraint?.activate()
        }
    }
    
    @objc func actionReadImageFromLibrary() {
        showImagePickerOfSource(source: .photoLibrary)
    }
    
    @objc func actionTakePhoto() {
        showImagePickerOfSource(source: .camera)
    }
    
    @objc func editorDidBeginEditing(notif: Notification) {
        // notif 的内容：
        // name = UITextViewTextDidBeginEditingNotification,
        // object = Optional(<UITextView: 0x7fc9d5863000; frame = (0 0; 375 553);
        // text = ''; clipsToBounds = YES;
        // tintColor = UIExtendedSRGBColorSpace 0 0 0 1;
        // gestureRecognizers = <NSArray: 0x600000621b60>;
        // layer = <CALayer: 0x600000831700>;
        // contentOffset: {0, 0}; contentSize: {375, 55};
        // adjustedContentInset: {0, 0, 0, 0}>),
        // userInfo = nil
    }
    
    @objc func actionConfirmEdit() {
        editCompletion?(editor.text)
    }
}

private extension TextEditViewController {
    func setupNavigationBar() {
        if editCompletion != nil {
            title = "修改"
            navigationItem.rightBarButtonItem = btnConfirm
        }
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        
        view.addSubview(editor)
        view.addSubview(buttonsContainer)
        
        let stackView = UIStackView(arrangedSubviews: [btnPhotos, btnCamera], axis: NSLayoutConstraint.Axis.horizontal, spacing: 10, alignment: UIStackView.Alignment.center, distribution: UIStackView.Distribution.equalSpacing)
        buttonsContainer.addSubview(stackView)
        
        buttonsContainer.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(ContainerHeight)
            make.trailing.equalTo(buttonsContainer.snp.trailing)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        editor.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            editorContainerNotEditingBottomConstraint = make.bottom.equalTo(buttonsContainer.snp.top).constraint
        }
        
        bindActions()
        
        if editCompletion != nil, let text = editingText {
            editor.text = text
        }
    }
    
    func bindActions() {
        btnPhotos.addTarget(self, action: #selector(actionReadImageFromLibrary), for: .touchUpInside)
        btnCamera.addTarget(self, action: #selector(actionTakePhoto), for: .touchUpInside)
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

//        NotificationCenter.default.addObserver(self, selector: #selector(editorDidBeginEditing(notif:)), name: UITextView.textDidBeginEditingNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(editorDidEndEditing(notif:)), name: UITextView.textDidEndEditingNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(editorDidChange(notif:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    func clearupNotification () {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TextEditViewController {
    func getValues() throws -> [String: Any] {
        guard !editor.text.isEmpty else {
            throw KvasirError.contentEmpty
        }
        
        return [
            "content": editor.text
        ]
    }
}

private extension TextEditViewController {
    func showImagePickerOfSource(source: UIImagePickerController.SourceType) {
        guardAccessToImagePickerSource(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = source
            
            HUD.show(.progress, onView: self.view)
            self.present(imagePicker, animated: true) {
                HUD.hide(animated: false)
            }
        }
    }
    
    func guardAccessToImagePickerSource(_ source: UIImagePickerController.SourceType, next: () -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            let alert = UIAlertController(title: "无法访问图片库或摄像头", message: "请检查图片或摄像头访问权限", preferredStyle: .alert)
            alert.view.tintColor = Color(hexString: ThemeConst.outlineColor)
            let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        next()
    }
    
    func recognizeImage(image: UIImage?) {
        #if !targetEnvironment(simulator)
        //        print("ocr version: \(G8Tesseract.version())") // 3.03
        guard let image = image else { return }
        // https://github.com/gali8/Tesseract-OCR-iOS/issues/299#issuecomment-267363981
        //        guard let ocr = G8Tesseract(language: "eng", engineMode: .tesseractCubeCombined) else { return }
        guard let ocr = G8Tesseract(language: "eng+chi_sim") else { return }
        
        ocr.engineMode = .tesseractOnly
        ocr.pageSegmentationMode = .auto
        //        ocr.image = image.g8_blackAndWhite()
        ocr.image = image.scaleImage(640)
        ocr.recognize()
        //        print(ocr.recognizedText)
        
        DispatchQueue.main.async {
            HUD.hide(animated: true)
            self.tvContent.text = ocr.recognizedText.trimmed
        }
        #endif
    }
}
