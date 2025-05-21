//
//  ViewController.swift
//  MapView
//
//  Created by 최원일 on 5/19/25.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var lblLocationInfo1: UILabel!
    @IBOutlet weak var lblLocationInfo2: UILabel!
    
    // 지도 보여 주기 (델리게이트 선언)
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblLocationInfo1.text = ""
        lblLocationInfo2.text = ""
        locationManager.delegate = self
        // 정확도를 최고로 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 위치 데이터를 추적하기 위해 사용자에게 승인을 요구
        locationManager.requestWhenInUseAuthorization()
        // 위치 업데이트 시작
        locationManager.startUpdatingLocation()
        // 위치 보기 값을 true로 설정
        myMap.showsUserLocation = true
    }

    func goLocation(latitudeValue: CLLocationDegrees, longitudeValue: CLLocationDegrees, delta span :Double) -> CLLocationCoordinate2D {
        // 위도 값과 경도 값을 매개변수로 함수를 호출, 리턴 값 pLocation
        let pLocation = CLLocationCoordinate2DMake(latitudeValue, longitudeValue)
        // 범위 값을 매개변수 함수 호출, 리턴 값 spanValue
        let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        // pLocation과 spanValue 값을 매개변수로 하여 함수 호출, 리턴 값 pRegion
        let pRegion = MKCoordinateRegion(center: pLocation, span: spanValue)
        // pRegion 값을 매개변수 myMap.setRegion 함수 호출
        myMap.setRegion(pRegion, animated: true)
        return pLocation
    }
    
    // 특정 위도와 경도에 핀 설치하고 핀에 타이틀과 서브 타이틀의 문자열 표시
    func setAnnotation(latitudeValue: CLLocationDegrees, longitudeValue : CLLocationDegrees, delta span :Double, title strTitle: String, subtitle strSubtitle:String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = goLocation(latitudeValue: latitudeValue, longitudeValue: longitudeValue, delta: span)
        annotation.title = strTitle
        annotation.subtitle = strSubtitle
        myMap.addAnnotation(annotation)
    }
    
    // 위치가 업데이트시 지도에 위치를 나타내기 위한 함수, 위치 정보에서 국가, 지역, 도로를 추출하여 레이블에 표시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 위치 업데이트시 먼저 마지막 위치 값 찾아냄
        let pLocation = locations.last
        _ = goLocation(latitudeValue: (pLocation?.coordinate.latitude)!, longitudeValue: (pLocation?.coordinate.longitude)!, delta: 0.01)
        // 마지막 위치의 위도와 경도 값을 가지고 앞에서 만든 goLocation 함수 호출 delta 지도의 크기(값이 작을수록 확대 효과) (0.01 = 100배 확대)
        // goLocation(latitudeValue: (pLocation?.coordinate.latitude)!, longitudeValue: (pLocation?.coordinate.longitude)!, delta: 0.01)
        // placemarks 첫 부분 pm 상수로 받기 -> 나라, 지역, 도로 값 추출
        CLGeocoder().reverseGeocodeLocation(pLocation!, completionHandler: {
            (placemarks, error) -> Void in
            let pm = placemarks!.first
            let country = pm!.country
            var address:String = country!
            if pm!.locality != nil {
                address += " "
                address += pm!.locality!
            }
            if pm!.thoroughfare != nil {
                address += " "
                address += pm!.thoroughfare!
            }
            
            self.lblLocationInfo1.text = "현재 위치"
            self.lblLocationInfo2.text = address
            
        })
        // 마지막 위치 업데이트 멈춤
        locationManager.stopUpdatingLocation()
    }
    
    // 세그먼트 컨트롤을 선택하였을 때 호출
    @IBAction func sgChangeLocation(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // 현재 위치 표시
            self.lblLocationInfo1.text = ""
            self.lblLocationInfo2.text = ""
            locationManager.startUpdatingLocation()
        } else if sender.selectedSegmentIndex == 1 {
            // 폴리텍대학 표시, 핀을 설치
            setAnnotation(latitudeValue: 37.751853, longitudeValue: 128.87605740000004, delta: 1, title: "한국폴리텍대학 강릉캠퍼스", subtitle: "강원도 강릉시 남산초교길121")
            self.lblLocationInfo1.text = "보고 계신 위치"
            self.lblLocationInfo2.text = "한국폴리텍대학 강릉캠퍼스"
        } else if sender.selectedSegmentIndex == 2 {
            // 이지스퍼블리싱 표시, 핀을 설치
            setAnnotation(latitudeValue: 37.556876, longitudeValue: 126.914066, delta: 0.1, title: "이지퍼블리싱", subtitle: "서울시 마포구 잔다리로 109 이지스 빌딩")
            self.lblLocationInfo1.text = "보고 계신 위치"
            self.lblLocationInfo2.text = "이지퍼블리싱 출판사"
        } else if sender.selectedSegmentIndex == 3{
            setAnnotation(latitudeValue: 37.059238, longitudeValue: 127.079095, delta: 0.01, title: "My Home", subtitle: "장안코오롱하늘채아파트")
            self.lblLocationInfo1.text = "보고 계신 위치"
            self.lblLocationInfo2.text = "My Home"
        }
        
    }
    
}

// Q. 지도가 제대로 나오지 않던 현상 발생
// A. Info,plist -> Information Property List + -> Privacy - Location When In Use Usage Description -> Value의 App needs location servers for stuff.

// self
// 보통 클래스나 구조체 자신을 가리킬 때 사용 / 자기 자신의 클래스 함수
// nil
// 값이 존재하지 않음
