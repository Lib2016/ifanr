//
//  HomeViewController.swift
//  ifanr
//
//  Created by 梁亦明 on 16/7/1.
//  Copyright © 2016年 ifanrOrg. All rights reserved.
//

import UIKit
import SnapKit
import Moya

class HomeViewController: BasePageController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        pullToRefresh.delegate = self
        tableView.sectionHeaderHeight = tableHeaderView.height
        tableView.tableHeaderView = tableHeaderView
        tableHeaderView.currentItemDidClick { [unowned self] in
            let ifDetailsController = IFDetailsController(model: self.headerModelArray![$0], naviTitle: "首页")
            self.navigationController?.pushViewController(ifDetailsController, animated: true)
        }
        getNormalData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("home 内存警告")
    }
    
    private var hotDataError: Error?
    private var latestDataError: Error?
    //MARK: --------------------------- Private Methods --------------------------
    /**
     获取默认数据   即初次加载的数据
     */
    private func getNormalData() {
        isRefreshing = true
        
        let group = dispatch_group_create()
        dispatch_group_enter(group)
        
        let type: CommonModel? = CommonModel(dict: [:])
        IFanrService.shareInstance.getData(APIConstant.NewsFlash_latest(page), t: type, keys: ["data"], successHandle: { (modelArray) in
            self.headerModelArray = modelArray
            dispatch_group_leave(group)
            }, errorHandle: { (error) in
                print(error)
                self.pullToRefresh.endRefresh()
                self.hotDataError = error
        })
            
//        IFanrService.shareInstance.getLatesModel(APIConstant.Home_hot_features(5), successHandle: { [unowned self](modelArray) in
//            self.headerModelArray = modelArray
//            dispatch_group_leave(group)
//            }, errorHandle: { (error) in
//                print(error)
//                self.pullToRefresh.endRefresh()
//                self.hotDataError = error
//        })
        
        page = 1
        dispatch_group_enter(group)
        
        IFanrService.shareInstance.getLatestLayout(APIConstant.Home_latest(page), successHandle: { [unowned self](layoutArray) in
            self.latestCellLayout.removeAll()
            layoutArray.forEach {
                self.latestCellLayout.append($0)
            }
            dispatch_group_leave(group)
            }, errorHandle: { (error) in
                print(error)
                self.pullToRefresh.endRefresh()
                self.latestDataError = error
        })
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            if self.hotDataError == nil && self.latestDataError == nil {
                self.tableHeaderView.modelArray = self.headerModelArray
                self.tableView.reloadData()
                // 请求成功让page+1
                self.page+=1
            } else {
                // 这里处理网络出现问题
                self.pullToRefresh.endRefresh()
            }
            
            self.isRefreshing = false
            self.pullToRefresh.endRefresh()
        }
        
    }
    
    
    //MARK: --------------------------- Getter and Setter --------------------------
    
    // 列表数据
    private var latestCellLayout = Array<HomePopularLayout>()
    private var headerModelArray: [CommonModel]?
    
    //MARK: --------------------------- ScrollViewControllerReusable --------------------------

    /**
     tableView HeaderView
     */
    private lazy var tableHeaderView: HomeHeaderView = {
        let headerView: HomeHeaderView = HomeHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.width*0.625+45))
        return headerView
    }()
}

// MARK: - 下拉刷新回调
extension HomeViewController: PullToRefreshDelegate {
    func pullToRefreshViewDidRefresh(pulllToRefreshView: PullToRefreshView) {
        getNormalData()
    }
}

// MARK: - 上拉加载更多
extension HomeViewController {
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if differY < happenY {
            if !isRefreshing {
                // 这里处理上拉加载更多
                IFanrService.shareInstance.getLatestLayout(APIConstant.Home_latest(page), successHandle: { (layoutArray) in
                    layoutArray.forEach{
                        self.latestCellLayout.append($0)
                    }
                    self.isRefreshing = false
                    self.tableView.reloadData()
                    }, errorHandle: { (error) in
                        print(error)
                })
                
                isRefreshing = true
            }
        }
    }
}

// MARK: - tableView代理
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestCellLayout.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cellModel = latestCellLayout[indexPath.row].model
        if cellModel.post_type == PostType.dasheng {
            let cell = cell as! HomeLatestTextCell
            cell.popularLayout = latestCellLayout[indexPath.row]
        } else if cellModel.post_type == PostType.data {
            let cell = cell as! HomeLatestDataCell
            cell.popularLayout = latestCellLayout[indexPath.row]
        } else {
            let cell = cell as! HomeLatestImageCell
            cell.popularLayout = latestCellLayout[indexPath.row]
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellModel = latestCellLayout[indexPath.row].model
        var cell : UITableViewCell!
        if cellModel.post_type == PostType.dasheng {
            cell = HomeLatestTextCell.cellWithTableView(tableView)
        } else if cellModel.post_type == PostType.data {
            cell = HomeLatestDataCell.cellWithTableView(tableView)
        } else {
            cell = HomeLatestImageCell.cellWithTableView(tableView)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return latestCellLayout[indexPath.row].cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let model: CommonModel = latestCellLayout[indexPath.row].model {
            let ifDetailsController = IFDetailsController(model: model, naviTitle: "首页")
            self.navigationController?.pushViewController(ifDetailsController, animated: true)
        }
    }
}
