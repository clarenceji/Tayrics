//
//  CollectionViewController.swift
//  Tayrics
//
//  Created by Clarence Ji on 6/23/20.
//

import UIKit

class CollectionViewController: UIViewController {
    
    var mediaService = MediaService()
    
    private enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
        case albumCovers, albumTitles
        
        var description: String {
            switch self {
            case .albumCovers:  return "Album Covers"
            case .albumTitles:  return "Album Titles"
            }
        }
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureNavCollectionListItem()
        configureDataSource()
        applyInitialDataSnapshot()
    }

}

private extension CollectionViewController {
    
    func configureNavCollectionListItem() {
        navigationItem.title = "Tayrics"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            
            let section: NSCollectionLayoutSection
            
            switch sectionKind {
            case .albumCovers:
                
                // Configure item and group sizes, ref:
                // https://docs-assets.developer.apple.com/published/2308306163/rendered2x-1585241228.png
                
                // Configure item size
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets.zero
                
                // Configure group size
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.4),
                    heightDimension: .fractionalWidth(0.4)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                // Configure section
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: self.view.layoutMargins.left, bottom: 10, trailing: self.view.layoutMargins.right)
                
            case .albumTitles:
                section = .list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
            }
            
            return section
        }
    }
    
    func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section ☹️") }
            
            switch section {
            case .albumCovers:
                guard let item = item as? CollectionAlbumCoverItem else { return nil }
                return collectionView.dequeueConfiguredReusableCell(using: self.configureGridCells(), for: indexPath, item: item)
                
            case .albumTitles:
                switch item {
                case let album as Album:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredTrackListHeaderCell(), for: indexPath, item: album)
                    
                case let song as Song:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredTrackListCell(), for: indexPath, item: song)
                    
                default:
                    return nil
                }
            }
        })
    }
    
    func applyInitialDataSnapshot() {
        
        // Set order of the sections
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        // Album covers
        var albumCoversSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        let albumCoverItems = mediaService.albums
            .compactMap {
                CollectionAlbumCoverItem(displayOrder: $0.order, coverImage: UIImage(named: $0.coverImageName))
            }
            .sorted { $0.displayOrder < $1.displayOrder }
        
        albumCoversSnapshot.append(albumCoverItems)
        dataSource.apply(albumCoversSnapshot, to: .albumCovers, animatingDifferences: false)
        
        // Track Lists
        var trackListsSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        for album in mediaService.albums {
            trackListsSnapshot.append([album])
            trackListsSnapshot.append(album.songs, to: album)
        }
        dataSource.apply(trackListsSnapshot, to: .albumTitles, animatingDifferences: false)
    }
    
    // MARK: Cell Layouts
    func configureGridCells() -> UICollectionView.CellRegistration<UICollectionViewCell, CollectionAlbumCoverItem> {
        .init { (cell, indexPath, item) in
            
            // Configure cell background
            let imageView = UIImageView(image: item.coverImage)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 8
            imageView.layer.masksToBounds = true
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.customView = imageView
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background
        }
    }
    
    func configuredTrackListHeaderCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, Album> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Album> { (cell, indexPath, album) in
            var content = cell.defaultContentConfiguration()
            content.text = album.name
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    func configuredTrackListCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, Song> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Song> { (cell, indexPath, song) in
            var content: UIListContentConfiguration = .valueCell()
            content.text = song.name
            content.textProperties.font = .preferredFont(forTextStyle: .subheadline)
            content.secondaryText = "\(song.length)"
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
            content.prefersSideBySideTextAndSecondaryText = true
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
            cell.indentationWidth = 0
        }
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectCollectionListItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
