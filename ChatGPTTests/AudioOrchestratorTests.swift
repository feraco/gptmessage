//
//  AudioOrchestratorTests.swift
//  ChatGPTTests
//
//  Unit tests for AudioOrchestrator
//

import XCTest
@testable import ChatGPT

@available(iOS 13.0, macOS 10.15, *)
final class AudioOrchestratorTests: XCTestCase {
    
    var orchestrator: AudioOrchestrator!
    
    override func setUpWithError() throws {
        orchestrator = AudioOrchestrator()
    }
    
    override func tearDownWithError() throws {
        orchestrator = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsIdle() async throws {
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .idle)
    }
    
    // MARK: - State Transition Tests
    
    func testTransitionFromIdleToListening() async throws {
        let success = await orchestrator.requestListening()
        XCTAssertTrue(success)
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .listening)
    }
    
    func testTransitionFromListeningToProcessing() async throws {
        // First transition to listening
        await orchestrator.requestListening()
        
        // Then transition to processing
        let success = await orchestrator.requestProcessing()
        XCTAssertTrue(success)
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .processing)
    }
    
    func testTransitionFromProcessingToPlaying() async throws {
        // Setup: idle -> listening -> processing
        await orchestrator.requestListening()
        await orchestrator.requestProcessing()
        
        // Transition to playing
        let success = await orchestrator.requestPlaying()
        XCTAssertTrue(success)
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .playing)
    }
    
    func testTransitionFromPlayingToIdle() async throws {
        // Setup: idle -> listening -> processing -> playing
        await orchestrator.requestListening()
        await orchestrator.requestProcessing()
        await orchestrator.requestPlaying()
        
        // Transition to idle
        let success = await orchestrator.requestIdle()
        XCTAssertTrue(success)
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .idle)
    }
    
    // MARK: - Invalid Transition Tests
    
    func testInvalidTransitionFromIdleToPlaying() async throws {
        // Cannot go directly from idle to playing
        let success = await orchestrator.requestPlaying()
        XCTAssertFalse(success)
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .idle)
    }
    
    func testInvalidTransitionFromListeningToPlaying() async throws {
        await orchestrator.requestListening()
        
        // Cannot go directly from listening to playing
        let success = await orchestrator.requestPlaying()
        XCTAssertFalse(success)
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .listening)
    }
    
    // MARK: - Force Idle Tests
    
    func testForceIdleFromAnyState() async throws {
        // Transition to playing state
        await orchestrator.requestListening()
        await orchestrator.requestProcessing()
        await orchestrator.requestPlaying()
        
        // Force idle
        await orchestrator.forceIdle()
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .idle)
    }
    
    // MARK: - State Query Tests
    
    func testIsListening() async throws {
        XCTAssertFalse(await orchestrator.isListening())
        
        await orchestrator.requestListening()
        XCTAssertTrue(await orchestrator.isListening())
    }
    
    func testIsPlaying() async throws {
        XCTAssertFalse(await orchestrator.isPlaying())
        
        await orchestrator.requestListening()
        await orchestrator.requestProcessing()
        await orchestrator.requestPlaying()
        XCTAssertTrue(await orchestrator.isPlaying())
    }
    
    func testIsIdle() async throws {
        XCTAssertTrue(await orchestrator.isIdle())
        
        await orchestrator.requestListening()
        XCTAssertFalse(await orchestrator.isIdle())
    }
    
    func testIsProcessing() async throws {
        XCTAssertFalse(await orchestrator.isProcessing())
        
        await orchestrator.requestListening()
        await orchestrator.requestProcessing()
        XCTAssertTrue(await orchestrator.isProcessing())
    }
    
    // MARK: - Callback Tests
    
    func testCallbackExecutedOnStateEnter() async throws {
        let expectation = XCTestExpectation(description: "Callback executed")
        
        await orchestrator.onStateEnter(.listening) {
            expectation.fulfill()
        }
        
        await orchestrator.requestListening()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testMultipleCallbacksExecuted() async throws {
        let expectation1 = XCTestExpectation(description: "First callback executed")
        let expectation2 = XCTestExpectation(description: "Second callback executed")
        
        await orchestrator.onStateEnter(.listening) {
            expectation1.fulfill()
        }
        
        await orchestrator.onStateEnter(.listening) {
            expectation2.fulfill()
        }
        
        await orchestrator.requestListening()
        
        await fulfillment(of: [expectation1, expectation2], timeout: 2.0)
    }
    
    // MARK: - Cleanup Tests
    
    func testCleanupResetsToIdle() async throws {
        await orchestrator.requestListening()
        await orchestrator.requestProcessing()
        
        await orchestrator.cleanup()
        
        let state = await orchestrator.getState()
        XCTAssertEqual(state, .idle)
    }
    
    // MARK: - Complete Flow Tests
    
    func testCompleteConversationFlow() async throws {
        // Start idle
        XCTAssertTrue(await orchestrator.isIdle())
        
        // Start listening
        await orchestrator.requestListening()
        XCTAssertTrue(await orchestrator.isListening())
        
        // Process speech
        await orchestrator.requestProcessing()
        XCTAssertTrue(await orchestrator.isProcessing())
        
        // Play response
        await orchestrator.requestPlaying()
        XCTAssertTrue(await orchestrator.isPlaying())
        
        // Return to idle
        await orchestrator.requestIdle()
        XCTAssertTrue(await orchestrator.isIdle())
        
        // Can start listening again
        await orchestrator.requestListening()
        XCTAssertTrue(await orchestrator.isListening())
    }
}
