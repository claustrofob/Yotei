//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import UIKit

final class DiffableDataStorage<Section: Identifiable, Item: Identifiable & Equatable> where Item.ID: Sendable, Section.ID: Sendable {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section.ID, Item.ID>

    private var items = [Item.ID: Item]()
    private var sections = [Section.ID: Section]()

    init() {}

    var isEmpty: Bool {
        items.isEmpty
    }

    func apply(data: [(section: Section, items: [Item])]) -> Snapshot {
        var newSections = [Section.ID: Section]()
        var newItems = [Item.ID: Item]()
        var updatedItemIDs = [Item.ID]()
        var snapshot = Snapshot()
        for value in data {
            newSections[value.section.id] = value.section
            let newItemIDs = value.items.map { newItem in
                newItems[newItem.id] = newItem
                if let item = items[newItem.id], item != newItem {
                    updatedItemIDs.append(newItem.id)
                }
                return newItem.id
            }
            snapshot.appendSections([value.section.id])
            snapshot.appendItems(newItemIDs, toSection: value.section.id)
        }

        snapshot.reconfigureItems(updatedItemIDs)

        items = newItems
        sections = newSections

        return snapshot
    }

    func item(for id: Item.ID) -> Item? {
        items[id]
    }

    func section(for id: Section.ID) -> Section? {
        sections[id]
    }

    func item(in snapshot: Snapshot, for indexPath: IndexPath) -> Item? {
        guard let sectionID = snapshot.sectionIdentifiers[safe: indexPath.section] else {
            return nil
        }
        let itemsIDsInSection = snapshot.itemIdentifiers(inSection: sectionID)
        return itemsIDsInSection[safe: indexPath.item].flatMap { item(for: $0) }
    }

    func section(in snapshot: Snapshot, for index: Int) -> Section? {
        guard let sectionID = snapshot.sectionIdentifiers[safe: index] else {
            return nil
        }
        return section(for: sectionID)
    }

    func numberOfItemsInSection(in snapshot: Snapshot, index: Int) -> Int {
        guard let sectionID = snapshot.sectionIdentifiers[safe: index] else {
            return 0
        }
        return snapshot.numberOfItems(inSection: sectionID)
    }
}
