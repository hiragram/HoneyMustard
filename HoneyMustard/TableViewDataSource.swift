//
//  TableViewDataSource.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/09.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TableViewDataSource<S: AnimatableSectionModelType>: TableViewSectionedDataSource<S> {
  
}

extension TableViewDataSource: RxTableViewDataSourceType {
  typealias Element = [S]

  func tableView(_ tableView: UITableView, observedEvent: Event<Array<S>>) {
    UIBindingObserver.init(UIElement: self) { (dataSource, newSections) in
      let oldSections = dataSource.sectionModels
      do {
        let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
        for difference in differences {
          dataSource.setSections(difference.finalSections)
          tableView.performBatchUpdates(difference, animationConfiguration: AnimationConfiguration.init(insertAnimation: .bottom, reloadAnimation: .none, deleteAnimation: .none))
        }
//        tableView.setContentOffset(.zero, animated: true)
      } catch let e {
        print(e)
      }
    }.on(observedEvent)
  }
}
