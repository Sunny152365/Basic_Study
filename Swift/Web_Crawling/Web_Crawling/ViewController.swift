//
//  ViewController.swift
//  Web_Crawling
//
//  Created by 최원일 on 6/13/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}


// way 1 : SerpAPI (구글 차단 안됨)
pip install google-search-results

from serpapi import GoogleSearch

params = {
    "q": "uikit storyboard",
    "hl": "en",
    "gl": "us",
    "api_key": "YOUR_SERPAPI_KEY"  # 여기에 본인의 SerpAPI 키를 입력하세요
}

search = GoogleSearch(params)
results = search.get_dict()
for i, result in enumerate(results.get("organic_results", []), 1):
    print(f"{i}. {result['title']}")
    print(result['link'])
    print()

// way 2 : BeautifulSoup + requests (구글 우회 필요, DuckDuckGo 권장)
pip install requests beautifulsoup4

import requests
from bs4 import BeautifulSoup
import urllib.parse

query = "uikit storyboard"
url = f"https://html.duckduckgo.com/html/?q={urllib.parse.quote(query)}"

headers = {
    "User-Agent": "Mozilla/5.0"
}

response = requests.get(url, headers=headers)
soup = BeautifulSoup(response.text, "html.parser")

results = soup.select(".result__title a")

for i, a in enumerate(results, 1):
    print(f"{i}. {a.text.strip()}")
    print(a['href'])
    print()

// way 3 :
