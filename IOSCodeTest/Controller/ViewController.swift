//
//  ViewController.swift
//  IOSCodeTest
//
//  Created by iMyanmarHouse on 11/1/23.
//

import UIKit
import Alamofire
import ImageSlideshow

class ViewController: UIViewController {
    
    var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5OTRiYjkwZC1lYjRhLTRmOTMtYmNhMS0wZDcyZjllM2FiZTMiLCJqdGkiOiI4Y2E1OTI5MGE1NTI2Y2M1MjllNzI3YmJhNDkwZDNlNThiZTM0YTgyNDMwNDhhMzE5MzY1YjNmYTczMzkxOTU0N2JkMmQ3ZTY5YzNkNGU3ZiIsImlhdCI6MTY5ODkwMjA0My4xNzg0NTUsIm5iZiI6MTY5ODkwMjA0My4xNzg0NTcsImV4cCI6MTczMDUyNDQ0My4xNzMxNDQsInN1YiI6IjI1ODA1MTU4NDc3Njk2MCIsInNjb3BlcyI6W119.Ol1zOPTPbdsIuqHHE6MluMjbPJtFc-q0xYx_tKgDUsGPuyc-6Jk5HWC3HS2WN3cElDrvN_KcJNE4w7ERAYYvdMUMogspFCU-kMBQcAakgIDC2Tx6oF0UKYXiUGcloyIA2oy0oSEWNEHYAigUl2WbSr6-TzlThybt596h1YoIBPYCwE_lUit7iHwKqr7sEz6nWKyi2f8b2-tDusAGtpjFtRRJz7JeOlG2OYbwAsInDnDir7JVEm3sXmRhoLsX6fWND-TjbFU96572rDRtOQcYP_H6bZMNr89JUEg2LcidUpSdBMU4MVD-DJ0DGmsHrTNN4WfAwq9oq4Att8wIJw8T6DfonRSapwMlnW4LjpexjGPNYnpQX9sx79fxFgo8Ez2MySic0M-m5jqfXWBKLLpArOMwSE5oBfKdEuWY4iigik9BTy3PMEJjrRrsYjna81wktOCs9MaVOihTn8775ZkJmzSeYpM_sbcVK-WzmNGR1mJe0txbKHKcBRvE9ldq2xinFVDFJdcc74uhaA0TuOjI76mhnzcoaAqbInzPeiobTI_vXKxPzthP6Dh2pWS7hcuPPbqKHp2PygsHKd9G9eoZq9e2I6uX3U1I2Eff32z7l9yj0UupNaymITnSmceIgHbfNvIuOXjjNqZrcI8igfHaomeZC2Kz3Jb4b0-WpcruUus"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var secondStackView: UIView!
    @IBOutlet weak var secondStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var arrowUpButton: UIButton!
    @IBOutlet weak var promotionViewButton: UIButton!
    @IBOutlet weak var promotionCollectionView: UICollectionView!
    @IBOutlet weak var announcementTBView: UITableView!
    @IBOutlet weak var newsletterCollectionView: UICollectionView!
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    var articleList = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpDesign()
        setUpAPI()
    }
    
    //This is the selector method that is called upon tapping the image
    @objc func didTap() {
        slideShow.presentFullScreenController(from: self)
    }
    
    func setUpDesign() {
        //userInfo View
        userInfoView.layer.cornerRadius = 8
        userInfoView.dropShadow()
        secondStackView.isHidden = true
        secondStackViewHeight.constant = 0
        arrowUpButton.layer.cornerRadius = 5
        arrowUpButton.layer.masksToBounds = true
        arrowUpButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        searchTextField.layer.cornerRadius = 35.0
        
        // Pormotion collection view setup
        self.promotionCollectionView.delegate = self
        self.promotionCollectionView.dataSource = self
        self.promotionCollectionView.register(UINib(nibName: "PromotionCell",bundle: nil),forCellWithReuseIdentifier: "PromotionCell")
        
        // announcement table view setup
        self.announcementTBView.delegate = self
        self.announcementTBView.dataSource = self
        self.announcementTBView.register(UINib(nibName: "AnnouncementTBCell",bundle: nil),forCellReuseIdentifier: "AnnouncementTBCell")
        
        // Newsletter collection view setup
        self.newsletterCollectionView.delegate = self
        self.newsletterCollectionView.dataSource = self
        self.newsletterCollectionView.register(UINib(nibName: "NewsletterCell", bundle: nil),forCellWithReuseIdentifier: "NewsletterCell")
        
        //image slideshow setup
        slideShow.setImageInputs(
            [
                //The below asset names has to be updated to your image asset names
                ImageSource(image: UIImage(named: "Home.png" )!),
                ImageSource(image: UIImage(named: "Home.png")!),
                ImageSource(image: UIImage(named: "Home.png")!)
            ]
        )
        
        //Create the pageIndicator
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
        pageIndicator.pageIndicatorTintColor = UIColor.black
        slideShow.pageIndicator = pageIndicator
        
        //Label the pae indicator showing the page number e.g. 2/5
        slideShow.pageIndicator = LabelPageIndicator()
        slideShow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .left(padding: 20), vertical: .bottom)

        //Enable the fullscreen view upon tapping the image
        let gestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(ViewController.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    func setUpAPI() {
        let headers: HTTPHeaders = ["AUthorization": "Bearer \(token)"]
        AF.request( "https://codetest.onenex.dev/api/articles", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let responseData):
                let articleData = responseData as? [String: Any]
                let articleArray: [String: Any] = articleData?["data"] as? [String: Any] ?? [:]
                
                for (key,value) in articleArray {
                    let decoder = JSONDecoder()
                    do{
                        let jsonData = try? JSONSerialization.data(withJSONObject: value as? [String : AnyObject])
                        let decodedData = try decoder.decode(Article.self, from: jsonData!)
                        self.articleList.append(decodedData)
                    }
                    catch{
                        print(error)
                        return
                    }
               }
                self.promotionCollectionView.reloadData()
                self.announcementTBView.reloadData()
                self.newsletterCollectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func clickArrowUpButton(_ sender: Any) {
        secondStackView.isHidden = !secondStackView.isHidden
        secondStackViewHeight.constant = secondStackView.isHidden ? 0 : 100
        let changeImage = secondStackView.isHidden ?  "arrowtriangle.up.fill" :  "arrowtriangle.down.fill"
        arrowUpButton.setImage(UIImage(systemName: changeImage),for: .normal)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == promotionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromotionCell",for: indexPath) as! PromotionCell
            cell.promotionCellImg.layer.cornerRadius = 15
            if articleList.count > 0 {
                cell.promotionCellTitle.text = articleList[indexPath.row].title
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsletterCell",for: indexPath) as! NewsletterCell
            if articleList.count > 0 {
                cell.title.text = articleList[indexPath.row].title
            }
            return cell
        }
    }
    
    @objc func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.size.width * 0.8,
            height: CGFloat(200)
        )
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "AnnouncementTBCell") as! AnnouncementTBCell
        if articleList.count > 0 {
            print(articleList[indexPath.row].title)
            cell.title.text = articleList[indexPath.row].title
        }
        return cell
    }
}
