//
//  ViewController.swift
//  DatePicker_Alarm
//
//  Created by 최원일 on 5/8/25.
//

import UIKit

class ViewController: UIViewController {
    // 타이머가 구동되면 실행할 함수
    let timeSelector: Selector = #selector(ViewController.updateTime)
    // 타이머 간격. 1초
    let interval = 1.0
    // 타이머가 설정한 간격대로 실행되는지 확인하기 위한 변수
    var count = 0
    var alarmTime: String?
    var alertFlag = false       // 알람 기능 설정

    // 현재 시간 레이블의 아웃렛 변수
    @IBOutlet var lblCurrentTime: UILabel!
    // 선택 시간 레이블의 아웃렛 변수
    @IBOutlet var lblPickerTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // 타이머 설정
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: timeSelector, userInfo: nil, repeats: true)
    }

    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        // 전달된 인수 저장
        let datePickerView = sender
        
        // DateFormatter 클래스 상수 선언
        let formatter = DateFormatter()
        // formatter의 dateFormat 속성을 설정
        formatter.dateFormat = "yyyy-MM-dd HH:mm EEE"
        // 데이트 피커에서 선택한 날짜를 formatter의 dateFormat에서 설정한 포맷대로 string 메서드를 사용하여 문자열(String)로 변환
        lblPickerTime.text = "선택시간: " + formatter.string(from: datePickerView.date)
        
        formatter.dateFormat = "hh:mm aaa"
        alarmTime = formatter.string(from: datePickerView.date)
    }
    
    // 타이머가 구동된 후 정해진 시간이 되었을 때 실행할 함수
    @objc func updateTime() {
        // count 값을 문자열로 변환하여 lblCurrentTime.text에 출력
        // lblCurrentTime.text = String(count)
        // count = count + 1        // count 값을 1 증가
        
        // 현재 시간을 가져옴
        let date = NSDate()

        // 상수 formatter의 dateFormat 속성을 설정
        let formatter = DateFormatter()
        // 현재 날짜(date)를 formatter의 dateFormat에서 설정한 포맷대로 string 메서드를 사용하여 문자열(String)로 변환
        // 문자열로 변환한 date 값을 "현재시간:"이라는 문자열에 추가
        // 그리고 그 문자열을 lblCurrentTime의 text에 입력
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss EEE"
        lblCurrentTime.text = "현재시간 : " + formatter.string(from: date as Date)

        formatter.dateFormat = "hh:mm aaa"
        let currentTime = formatter.string(from: date as Date)
        
        if (alarmTime == currentTime) {
            if !alertFlag {
                let lampOnAlert = UIAlertController(title: "알림", message: "설정된 시간입니다.!!", preferredStyle: UIAlertController.Style.alert)
                let onAction = UIAlertAction(title: "네, 확인했습니다.", style: UIAlertAction.Style.default, handler: nil)
                lampOnAlert.addAction(onAction)
                present(lampOnAlert, animated: true, completion: nil)
                alertFlag = true
            }
            view.backgroundColor = UIColor.red
        }
        else {
            alertFlag = false
            view.backgroundColor = UIColor.white
        }
    }
}



