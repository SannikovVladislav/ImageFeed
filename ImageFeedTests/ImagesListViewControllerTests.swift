//
//  ImagesListViewControllerTests.swift
//  ImageFeed
//
//  Created by Владислав on 25.09.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    var sut: ImagesListViewController!
    var presenterSpy: ImagesListViewPresenterSpy!
    
    override func setUp() {
        super.setUp()
        
        sut = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        _ = sut.view  // force loading view
        
        presenterSpy = ImagesListViewPresenterSpy(
            view: sut,
            imagesListService: ImagesListServiceStub()
        )
        
        sut.presenter = presenterSpy
    }
    
    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsPresenterViewDidLoad() {
        // given
        presenterSpy = ImagesListViewPresenterSpy(
            view: sut,
            imagesListService: ImagesListServiceStub()
        )
        sut.presenter = presenterSpy
        
        // when
        sut.viewDidLoad() // вручную вызываем до загрузки view
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testShowLikeErrorAlert_PresentsAlert() {
        // given
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        // when
        sut.showLikeErrorAlert()

        // then
        let exp = expectation(description: "Wait for alert")
        DispatchQueue.main.async {
            XCTAssertTrue(self.sut.presentedViewController is UIAlertController)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func testReloadCell_ReloadsCorrectIndexPath() {
        // given
        let tableViewSpy = ReloadTableViewSpy()
        tableViewSpy.dataSource = sut
        sut.setValue(tableViewSpy, forKey: "tableView")
        
        let indexPath = IndexPath(row: 0, section: 0)

        // when
        sut.reloadCell(at: indexPath)

        // then
        XCTAssertEqual(tableViewSpy.reloadedIndexPaths, [indexPath])
    }
}

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    func photo(at indexPath: IndexPath) -> ImageFeed.Photo {
        return photos[indexPath.row]
    }
    
    weak var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListServiceProtocol
    
    var viewDidLoadCalled = false
    var photos: [Photo] = []
    
    init(view: ImagesListViewControllerProtocol, imagesListService: ImagesListServiceProtocol) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        return photos[indexPath.row]
    }
    
    func willDisplayCell(at indexPath: IndexPath) {}
    func didTapLike(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {}
}

final class ImagesListServiceStub: ImagesListServiceProtocol {
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
    }
    
    func deleteImageList() {
    }
    
    var photos: [Photo] = []

    func fetchPhotosNextPage() {}
}

final class TableViewSpy: UITableView {
    private(set) var insertedIndexPaths: [IndexPath] = []

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertedIndexPaths.append(contentsOf: indexPaths)
        super.insertRows(at: indexPaths, with: animation)
    }
}

final class ReloadTableViewSpy: UITableView {
    var reloadedIndexPaths: [IndexPath] = []

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadedIndexPaths.append(contentsOf: indexPaths)
        super.reloadRows(at: indexPaths, with: animation)
    }
}


