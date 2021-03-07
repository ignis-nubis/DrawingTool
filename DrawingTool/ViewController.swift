//
//  ViewController.swift
//  DrawingTool
//
//  Created by Ignis Nubis on 3/6/21.
//
// 거의 모든 앱 개발에서 사용됨.
import UIKit
// 2019 그림 라이브러리. iOS 13 이후 가능. 14 후엔 손글씨 가능
// 앱 개발에만 집중 할 수 있어 선택함.
import PencilKit
// 사진 저장 기능
import PhotosUI // 저장 안하면 필요없다. 사진 라이브러리

@available(iOS 14.0, *)
class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    // iOS 14 이후 필요없음.
    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
        
    let canvasWidth: CGFloat = UIScreen.main.bounds.width
    // 커질수록 화면이 더 많이 늘어남.
    let canvasOverscroll: CGFloat = 500
      
    var drawing = PKDrawing()
    var toolPicker: PKToolPicker!
    
    // 그림을 불러옴.
    // DataFrame 이 있다면 이전에 그리던 그림을 불러올 수 있슴.
    override func viewDidLoad() {
        // superclass 에서 다 불러옴.
        super.viewDidLoad()
        // delegate 해야 그림 불러올때 맞는 그림이 불러짐.
        canvasView.delegate = self
        canvasView.drawing = drawing
        // 고무줄.
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        //set up toolpicker
        toolPicker = PKToolPicker()
        // 툴들이 보이게 함. false로 정하면 안보임.
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        // canvasView가 툴 선택이 바뀌었는지 앎.알지 못하면 툴 기능이 바뀌지 못함
        toolPicker.addObserver(canvasView)
        // viewController 에서 선택이 바뀌었는지 앎.
        toolPicker.addObserver(self)
        // canvasView에서  toolpicker 사용가능
        canvasView.becomeFirstResponder()
    }
    
    // 아이폰 SE 출시 이후 홈버튼이 사라진후 아래 뜨는 일자 선이 그림보다 후에 인식. 선이 안보이게 함.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // 손가락을 사용하는지 연필을 사용하는지 정함.
    // 손가락은 스크롤, 연필은 그림 및 다른 도구들.
    @IBAction func toogleFingerOrPencil (_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    // 새 도화지
    @IBAction func clear(_ sender: Any) {
        canvasView.drawing = PKDrawing()
    }
    
    //화면 크기 자동 조절. 그릴 때마다 불러진다.
    func updateContentSizeForDrawing() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        let contentWidth: CGFloat
        
        //항상 화면이 그림보다 크게 유지함.
        if !drawing.bounds.isNull {
            // 아래로 스크린 확장
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscroll) * canvasView.zoomScale)
            // 우측으로 스크린 확장
            contentWidth = max(canvasView.bounds.width, (drawing.bounds.maxX + self.canvasOverscroll) * canvasView.zoomScale)
            
        }else{
            contentHeight = canvasView.bounds.height
            contentWidth = canvasView.bounds.width
        }
        // 계산대로 업데이트
        canvasView.contentSize = CGSize(width: contentWidth, height: contentHeight)//CGSize(width: canvasWidth  * canvasView.zoomScale, height: contentHeight)
    }
    
    //그림이 바뀌었다고 알려줌. 그릴때마다 화면 업데이트.
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    
    // 시뮬레이터 무사용
    // 화면 크기 조정시 지정된 canvasWidth에 맞춰 스케일됨.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSizeForDrawing()
        // 맨 위로 스크롤
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    // 사진 기능, 저장 기능, export 공유 기능, import 다른 그림 파일 불러오기 기능,
    // text recognition 기능 모두 가능.
}

