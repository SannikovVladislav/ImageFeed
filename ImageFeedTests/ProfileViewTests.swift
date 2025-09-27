//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Владислав on 27.09.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewDidLoadCallsConfigureViewsAndUpdateProfile() {
        // given
        let view = ProfileViewControllerSpy()
        let profileResult = ProfileResult(
                    username: "testuser",
                    firstName: "Test",
                    lastName: "User",
                    bio: "Bio text"
                )
        let profile = Profile(profileResult: profileResult)
                let profileService = ProfileServiceStub(profile: profile)
                let imageService = ProfileImageServiceStub(avatarURL: "https://example.com/avatar.jpg")
                
                let presenter = ProfileViewPresenter(
                    profileService: profileService,
                    profileImageService: imageService,
                    profileLogoutService: ProfileLogoutServiceStub()
                )
                presenter.view = view
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(view.configureViewsCalled)
        XCTAssertTrue(view.updateProfileDetailsCalled)
    }
    
    func testUpdateProfileWithNoProfileCallsShowDefault() {
        // given
        let view = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub(profile: nil)
        let profileImageService = ProfileImageServiceStub(avatarURL: nil)
        let logoutService = ProfileLogoutServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileService,
                                             profileImageService: profileImageService,
                                             profileLogoutService: logoutService)
        presenter.view = view
        
        // when
        presenter.updateProfile()
        
        // then
        XCTAssertTrue(view.showDefaultProfileCalled)
    }
    
    func testUpdateAvatarWithURLCallsSetAvatar() {
        // given
        let view = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub(profile: nil)
        let profileImageService = ProfileImageServiceStub(avatarURL: "https://test.com/avatar.png")
        let logoutService = ProfileLogoutServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileService,
                                             profileImageService: profileImageService,
                                             profileLogoutService: logoutService)
        presenter.view = view
        
        // when
        presenter.updateAvatar()
        
        // then
        XCTAssertTrue(view.setAvatarCalled)
        XCTAssertEqual(view.avatarURL?.absoluteString, "https://test.com/avatar.png")
    }
    
    func testUpdateAvatarWithNilURLCallsSetAvatarNil() {
        // given
        let view = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub(profile: nil)
        let profileImageService = ProfileImageServiceStub(avatarURL: nil)
        let logoutService = ProfileLogoutServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileService,
                                             profileImageService: profileImageService,
                                             profileLogoutService: logoutService)
        presenter.view = view
        
        // when
        presenter.updateAvatar()
        
        // then
        XCTAssertTrue(view.setAvatarCalled)
        XCTAssertNil(view.avatarURL)
    }
    
    func testDidTapLogoutCallsShowLogoutConfiguration() {
        // given
        let view = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub(profile: nil)
        let profileImageService = ProfileImageServiceStub(avatarURL: nil)
        let logoutService = ProfileLogoutServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileService,
                                             profileImageService: profileImageService,
                                             profileLogoutService: logoutService)
        presenter.view = view
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(view.showLogoutConfigurationCalled)
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var configureViewsCalled = false
    var updateProfileDetailsCalled = false
    var showDefaultProfileCalled = false
    var setAvatarCalled = false
    var showLogoutConfigurationCalled = false
    var avatarURL: URL?

    func configureViews() {
        configureViewsCalled = true
    }

    func updateProfileDetails(profile: Profile) {
        updateProfileDetailsCalled = true
    }

    func showDefaultProfile() {
        showDefaultProfileCalled = true
    }

    func setAvatar(url: URL?) {
        setAvatarCalled = true
        avatarURL = url
    }

    func showLogoutConfiguration() {
        showLogoutConfigurationCalled = true
    }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    func fetchProfile(token: String, completion: @escaping (Result<ImageFeed.Profile, any Error>) -> Void) { }
    
    func deleteProfile() { }
    
    var profile: Profile?

    init(profile: Profile?) {
        self.profile = profile
    }
}

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    func deleteProfileImage() { }
    
    var avatarURL: String?

    init(avatarURL: String?) {
        self.avatarURL = avatarURL
    }

    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let url = avatarURL {
            completion(.success(url))
        } else {
            completion(.failure(NSError(domain: "", code: 1)))
        }
    }
}

final class ProfileLogoutServiceStub: ProfileLogoutServiceProtocol {
    func logout() { }
}
