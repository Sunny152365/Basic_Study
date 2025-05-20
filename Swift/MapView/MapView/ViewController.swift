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

    func goLocation(latitudeValue: CLLocationDegrees, longitudeValue: CLLocationDegrees, delta span :Double){
        // 위도 값과 경도 값을 매개변수로 함수를 호출, 리턴 값 pLocation
        let pLocation = CLLocationCoordinate2DMake(latitudeValue, longitudeValue)
        // 범위 값을 매개변수 함수 호출, 리턴 값 spanValue
        let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        // pLocation과 spanValue 값을 매개변수로 하여 함수 호출, 리턴 값 pRegion
        let pRegion = MKCoordinateRegion(center: pLocation, span: spanValue)
        // pRegion 값을 매개변수 myMap.setRegion 함수 호출
        myMap.setRegion(pRegion, animated: true)
    }
    
    // 위치가 업데이트시 지도에 위치를 나타내기 위한 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocatio]) {
        // 위치 업데이트시 먼저 마지막 위치 값 찾안냄
        let pLocation = locations.last
        // 마지막 위치의 위도와 경도 값을 가지고 앞에서 만든 goLocation 함수 호출 delta 지도의 크기(값이 작을수록 확대 효과) (0.01 = 100배 확대)
        goLocation(latitudeValue: (pLocation?.coordinate.latitude)!, longitudeValue: (pLocation?.coordinate.longitude)!, delta: 0.01)
    }
    
    @IBAction func sgChangeLocation(_ sender: UISegmentedControl) {
    }
    
}

