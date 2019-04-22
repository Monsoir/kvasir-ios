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

class TextEditViewController: UIViewController {
    
    private var digestType = DigestType.sentence
    private var digest: RealmWordDigest?
    private var creating = true
    
    private var editorContainerNotEditingBottomConstraint: Constraint? = nil
    private var editorContainerEditingBottomConstraint: Constraint? = nil
    
    fileprivate lazy var editorContainer: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceHorizontal = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private lazy var buttonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.layoutMargins = UIEdgeInsets(horizontal: 10, vertical: 0)
        return view
    }()
    
//    private lazy var btnMoreInfo = makeAFunctionalButtonFromAwesomeFont(title: String.fontAwesomeIcon(name: .infoCircle), leadingInset: 30, topInset: 10)
    
    private lazy var btnPhotos = makeAFunctionalButtonFromAwesomeFont(name: .images, leadingInset: 30, topInset: 10)
    private lazy var btnCamera = makeAFunctionalButtonFromAwesomeFont(code: "fa-camera", leadingInset: 30, topInset: 10)
    
    private lazy var endEditingBarItem = UIBarButtonItem(title: "结束输入", style: .done, target: self, action: #selector(actionStopEditing))
    private lazy var submitBarItem = UIBarButtonItem(title: "提交", style: .done, target: self, action: #selector(actionSubmit))
    private lazy var nextBarItem = UIBarButtonItem(title: "编辑信息", style: .done, target: self, action: #selector(actionNext))
    
    private lazy var tvContent: UITextView = {
        [unowned self] in
        let view = UITextView()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.font = UIFont.init(name: TextEditorFontName, size: 25)
        view.bounces = true
        view.tintColor = Color(hexString: ThemeConst.outlineColor)
        view.textContainerInset = UIEdgeInsets(horizontal: 20, vertical: 20)
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        
        setupNotification()
        
        fillBlanks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    init(digestType: DigestType = .sentence, digest: RealmWordDigest, creating: Bool = true) {
        self.digestType = digestType
        self.digest = digest
        self.creating = creating
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
        clearupNotification()
    }
}

private extension TextEditViewController {
    func setupNavigationBar() {
        title = "正文"
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = creating ? submitBarItem : nextBarItem
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        
        view.addSubview(editorContainer)
        view.addSubview(buttonsContainer)
        
        let stackView = UIStackView(arrangedSubviews: [btnPhotos, btnCamera], axis: NSLayoutConstraint.Axis.horizontal, spacing: 10, alignment: UIStackView.Alignment.center, distribution: UIStackView.Distribution.equalSpacing)
        buttonsContainer.addSubview(stackView)
        editorContainer.addSubview(tvContent)
        
        buttonsContainer.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(ThemeConst.functionalButtonContainerHeight)
            make.trailing.equalTo(buttonsContainer.snp.trailing)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        editorContainer.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            editorContainerNotEditingBottomConstraint = make.bottom.equalTo(buttonsContainer.snp.top).constraint
        }
        
        tvContent.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(editorContainer)
        }
        
        bindActions()
        
        if let content = digest?.content {
            if creating {
                submitBarItem.isEnabled = !content.isEmpty
            } else {
                nextBarItem.isEnabled = !content.isEmpty
            }
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
    }
    
    func clearupNotification () {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TextEditViewController: UINavigationControllerDelegate {
}

extension TextEditViewController: UIImagePickerControllerDelegate {
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
}

private extension TextEditViewController {
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            DispatchQueue.main.async {
                self.editorContainerNotEditingBottomConstraint?.deactivate()
                if let editingBottomConstraint = self.editorContainerEditingBottomConstraint {
                    editingBottomConstraint.update(offset: -keyboardHeight)
                } else {
                    self.editorContainer.snp.makeConstraints({ (make) in
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
                    self.editorContainer.snp.makeConstraints({ (make) in
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
    
    @objc func actionStopEditing() {
        view.endEditing(true)
    }
    
    func putContentToModel() -> Bool {
        let content = tvContent.text.trimmed
        guard !content.isEmpty else {
            let alert = UIAlertController(title: "提示", message: "请填写内容", defaultActionButtonTitle: "好的", tintColor: Color(hexString: ThemeConst.outlineColor))
            present(alert, animated: true, completion: nil)
            return false
        }
        
        digest?.content = content
        return true
    }
    
    @objc func actionSubmit(){
        guard putContentToModel() else { return }
        
        var savedResult = false
        switch digestType {
        case .sentence:
            savedResult = (digest as! RealmSentence).save()
        case .paragraph:
            savedResult = (digest as! RealmParagraph).save()
        }
        guard savedResult else { return }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionNext() {
        guard putContentToModel() else { return }
        
        let nextVC = WordDigestInfoViewController(digestType: digestType, digest: digest!, creating: creating)
        navigationController?.pushViewController(nextVC)
    }
    
    @objc func actionReadImageFromLibrary() {
        showImagePickerOfSource(source: .photoLibrary)
    }
    
    @objc func actionTakePhoto() {
        showImagePickerOfSource(source: .camera)
    }
    
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

extension TextEditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == tvContent else { return }
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = self.endEditingBarItem
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == tvContent else { return }
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = self.creating ? self.submitBarItem : self.nextBarItem
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == tvContent else { return }
        DispatchQueue.main.async {
            if self.creating {
                self.submitBarItem.isEnabled = !textView.text.isEmpty
            } else {
                self.nextBarItem.isEnabled = !textView.text.isEmpty
            }
        }
    }
}

private extension TextEditViewController {
    func fillBlanks() {
        tvContent.text = digest?.content
    }
}
