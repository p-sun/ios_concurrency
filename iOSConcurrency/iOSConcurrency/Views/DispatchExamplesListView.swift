import Foundation
import SwiftUI

struct DispatchQueueExamples_Previews: PreviewProvider {
    static var previews: some View {
        DispatchQueueExamples()
    }
}

struct DispatchQueueExamples: View {
    @State var longerWorkItems = false

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 30) {
            Toggle("Run Longer Work Items", isOn: $longerWorkItems).tint(.accentColor).padding(.trailing, 2)

            VStack(alignment: .leading) {
                RunButton("Main Thread to Main Queue - async", testMainThread_to_MainQueue_async)
                RunButton("Main Thread to Main Queue - sync (CRASH)", testMainThread_to_MainQueue_sync)
            }
            VStack(alignment: .leading) {
                RunButton("Main Thread to Serial Queue - async", testMainThread_to_SerialQueue_async)
                RunButton("Main Thread to Serial Queue - sync", testMainThread_to_SerialQueue_sync)
            }
            VStack(alignment: .leading) {
                RunButton("Main Thread to Concurrent Queue - async", testMainThread_to_ConcurrentQueue_async)
                RunButton("Main Thread to Concurrent Queue - sync", testMainThread_to_ConcurrentQueue_sync)
            }
            VStack(alignment: .leading) {
                Text("DispatchQueue.global() has a pool of concurrent threads.")
                RunButton("DispatchQueue.global().async", testMainThread_to_ConcurrentGlobal_async)
                RunButton("DispatchQueue.global().sync", testMainThread_to_ConcurrentGlobal_sync)
            }
        }
    }
    
    // # MARK: Helpers
    
    let serialQueue = DispatchQueue(label: "paige.serial.queue")
    let concurrentQueue = DispatchQueue(label: "paige.concurrent.queue", attributes: .concurrent)
    
    func RunButton(_ title: String, _ fn: @escaping (_ title: String) -> Void) -> some View {
        return Button(title) {
            ThreadLogger.log("(1) \(title) START")
            fn(title)
        }.buttonStyle(.borderedProminent)
    }
    
    func longWorkTask(_ title: String) {
        for i in 10...(longerWorkItems ? 1000 : 20) {
            ThreadLogger.log("\(i) | \(title)")
        }
    }
    
    // # MARK: Tests
    
    func testMainThread_to_MainQueue_async(_ title: String) {
        DispatchQueue.main.async {
            longWorkTask("(3) 🥝 \(title) main.async")
        }
        DispatchQueue.main.async {
            longWorkTask("(3) 🍊 \(title) main.async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func testMainThread_to_MainQueue_sync(_ title: String) {
        // EXC_BAD_INSTRUCTION Crash.
        // Calling `sync` and targeting the current queue results in deadlock,
        // because 'sync' blocks current thread until pending items has finished.
        DispatchQueue.main.sync { // 2
            ThreadLogger.log("(never) \(title) main.sync")
        }
        ThreadLogger.log("(never) \(title) END")
    }
    
    func testMainThread_to_SerialQueue_async(_ title: String) {
        serialQueue.async {
            longWorkTask("(3) 🥝 \(title) serialQueue.async")
        }
        serialQueue.async {
            longWorkTask("(3) 🍊 \(title) serialQueue.async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func testMainThread_to_SerialQueue_sync(_ title: String) {
        serialQueue.sync {
            longWorkTask("(2) 🥝 \(title) serialQueue.sync")
        }
        serialQueue.sync {
            longWorkTask("(2) 🍊 \(title) serialQueue.sync")
        }
        //        serialQueue.sync {
        //            ThreadLogger.log("(2) \(title) serialQueue.sync")
        //            //            queue.sync { // DISPATCH_WAIT_FOR_QUEUE here
        //            //                ThreadLogger.log("3 testAsyncOps_blocking")
        //            //            }
        //        }
        ThreadLogger.log("(3) \(title) END")
    }
    
    func testMainThread_to_ConcurrentQueue_async(_ title: String) {
        concurrentQueue.async {
            longWorkTask("(3) 🍊 \(title) concurrentQueue.async")
        }
        concurrentQueue.async {
            longWorkTask("(3) 🥝 \(title) concurrentQueue.async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func testMainThread_to_ConcurrentQueue_sync(_ title: String) {
        concurrentQueue.sync {
            longWorkTask("(2) 🍊 \(title) concurrentQueue.sync")
        }
        concurrentQueue.sync {
            longWorkTask("(2) 🥝 \(title) concurrentQueue.sync")
        }
        ThreadLogger.log("(3) \(title) END")
    }
    
    func testMainThread_to_ConcurrentGlobal_async(_ title: String) {
        DispatchQueue.global().async {
            longWorkTask("(2) 🍊 \(title) DispatchQueue.global().async")
        }
        DispatchQueue.global().async {
            longWorkTask("(2) 🥝 \(title) DispatchQueue.global().async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func testMainThread_to_ConcurrentGlobal_sync(_ title: String) {
        DispatchQueue.global().sync {
            longWorkTask("(3) 🍊 \(title) DispatchQueue.global().sync")
        }
        DispatchQueue.global().sync {
            longWorkTask("(3) 🥝 \(title) DispatchQueue.global().sync")
        }
        ThreadLogger.log("(2) \(title) END")
    }
}
