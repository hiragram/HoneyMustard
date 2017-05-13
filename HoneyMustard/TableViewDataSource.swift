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
          UIView.setAnimationsEnabled(false)
          tableView.beginUpdates()
          // delete sections
          tableView.deleteSections(indexSet(difference.deletedSections), with: .automatic)

          // insert sections
          tableView.insertSections(indexSet(difference.insertedSections), with: .fade)

          // move sections
          difference.movedSections.forEach({ (from: Int, to: Int) in
            tableView.moveSection(from, to: to)
          })

          // delete items
          tableView.deleteItemsAtIndexPaths(
            difference.deletedItems.map { IndexPath.init(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: .automatic
          )

          // insert items
          tableView.insertItemsAtIndexPaths(
            difference.insertedItems.map { IndexPath.init(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: .fade
          )

          // reload items
          tableView.reloadItemsAtIndexPaths(
            difference.updatedItems.map { IndexPath.init(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: .automatic
          )

          // move items
          difference.movedItems.forEach({ (from: ItemPath, to: ItemPath) in
            tableView.moveItemAtIndexPath(
              IndexPath.init(item: from.itemIndex, section: from.sectionIndex),
              to: IndexPath.init(item: to.itemIndex, section: to.sectionIndex))
          })

          tableView.endUpdates()

          let contentInset = tableView.contentInset.top
          let newestCell = tableView.visibleCells.first as? TweetCell
          let newestCellHeight = newestCell?.bounds.height ?? 0
          let offset = newestCellHeight - contentInset

          UIView.setAnimationsEnabled(true)
          tableView.setContentOffset(CGPoint.init(x: 0, y: offset), animated: false)
          tableView.setContentOffset(CGPoint.init(x: 0, y: -contentInset), animated: true)
          tableView.setContentOffset(CGPoint.init(x: 0, y: -contentInset), animated: true)
        }
      } catch let e {
        print(e)
      }
    }.on(observedEvent)
  }
}

private func indexSet(_ sections: [Int]) -> IndexSet {
  let set = NSMutableIndexSet.init()
  sections.forEach { (i) in
    set.add(i)
  }
  return set as IndexSet
}
