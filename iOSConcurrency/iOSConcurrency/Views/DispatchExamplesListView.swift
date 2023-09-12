import Foundation
import SwiftUI

struct DispatchQueueExamples_Previews: PreviewProvider {
    static var previews: some View {
        DispatchQueueExamples()
    }
}

class Counter {
    private (set) var count = 0
    
    func increment() {
        count += 1
    }
}

struct DispatchQueueExamples: View {
    @State var longerWorkItems = false
    var spawnCounter = Counter()
    
    // # MARK: Helpers
    
    let serialQueue = DispatchQueue(label: "paige.serial.queue")
    let concurrentQueue = DispatchQueue(label: "paige.concurrent.queue", attributes: .concurrent)

    func RunButton(_ title: String, _ action: @escaping (_ title: String) -> Void) -> some View {
        return Button(action: {
            ThreadLogger.log("(1) \(title) START")
            action(title)
        }) {
            HStack {
                Text(title).multilineTextAlignment(.leading)
                Spacer()
            }
        }.buttonStyle(.borderedProminent)
    }
    
    func longWorkTask(_ title: String) {
        for i in 10...(longerWorkItems ? 1000 : 20) {
            ThreadLogger.log("\(i) | \(title)")
        }
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 30) {

            
            VStack(alignment: .leading) {
                Text("queue.async{ doWork() }").bold().dynamicTypeSize(.xxLarge)
                Text("executes work on that queue.")
                RunButton("From Main: DispatchQueue.main.async", {(title: String) -> Void in
                    DispatchQueue.main.async {
                        longWorkTask("(3) 🥝 \(title) main.async")
                    }
                    DispatchQueue.main.async {
                        longWorkTask("(4) 🍊 \(title) main.async")
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
                Text("Serial queue executes one work item at a time.")
                RunButton("From Main: serialQueue.async", { (title: String) -> Void in
                    serialQueue.async {
                        longWorkTask("(3) 🥝 \(title) serialQueue.async")
                    }
                    serialQueue.async {
                        longWorkTask("(4) 🍊 \(title) serialQueue.async")
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
                Text("Concurrent queue can execute multiple work items at once.")
                RunButton("From Main: concurrentQueue.async", { (title: String) -> Void in
                    concurrentQueue.async {
                        longWorkTask("(3) 🍊 \(title) concurrentQueue.async")
                    }
                    concurrentQueue.async {
                        longWorkTask("(3) 🥝 \(title) concurrentQueue.async")
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
                
                Text("DispatchQueue.global() has a pool of concurrent threads.")
                RunButton("From Main: DispatchQueue.global().async", toConcurrentGlobal_async)
            }

            VStack(alignment: .leading) {
                Text("queue.sync{ doWork() }").bold().dynamicTypeSize(.xxLarge)
                Text("blocks current thread until work is executed on current thread.")
                RunButton("From Main: serialQueue.sync", toSerialQueue_sync)
                RunButton("From Main: concurrentQueue.sync", toConcurrentQueue_sync)

                Text("Calling sync **from** and **to** the same **concurrent** queue is okay. Note the order work items are executed.")
                RunButton("From concurrentQueue.async: concurrentQueue.sync, .sync", {(title: String) -> Void in
                    concurrentQueue.async {
                        ThreadLogger.log("(3) \(title) outer async START")
                        concurrentQueue.sync {
                            longWorkTask("(4) 🍊 \(title) concurrentQueue.sync")
                        }
                        concurrentQueue.sync {
                            longWorkTask("(5) 🥝 \(title) concurrentQueue.sync")
                        }
                        ThreadLogger.log("(6) \(title) outer async END")
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
                RunButton("From concurrentQueue.async: concurrentQueue.async, .sync", {(title: String) -> Void in
                    concurrentQueue.async {
                        ThreadLogger.log("(3) \(title) outer async START") // Thread A
                        concurrentQueue.async {
                            longWorkTask("(4) 🍊 \(title) concurrentQueue.async") // Spins up new thread B
                        }
                        concurrentQueue.sync {
                            longWorkTask("(4) 🥝 \(title) concurrentQueue.sync") // Thread A
                        }
                        ThreadLogger.log("(5) \(title) outer async END") // Thread A
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
                RunButton("From concurrentQueue.async: concurrentQueue.sync, .async,\n.sync, async", {(title: String) -> Void in
                    concurrentQueue.async {
                        ThreadLogger.log("(3) \(title) outer async START")  // Thread A
                        concurrentQueue.sync {
                            longWorkTask("(4) 🍊 \(title) concurrentQueue.sync")  // Thread A
                        }
                        concurrentQueue.async {
                            longWorkTask("(5) 🥝 \(title) concurrentQueue.async") // Spins up new thread B
                        }
                        concurrentQueue.sync {
                            longWorkTask("(5) 🫐 \(title) concurrentQueue.sync")  // Thread A
                        }
                        concurrentQueue.async {
                            longWorkTask("(6) 🍇 \(title) concurrentQueue.async")  // Spins up new thread C
                        }
                        ThreadLogger.log("(7) \(title) outer async END")  // Thread A
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
            }
            
            VStack(alignment: .leading) {
                Text("Avoiding crashes with sync").bold().dynamicTypeSize(.xxLarge)
                
                Text("Calling sync **from** and **to** the same **serial** queue crashes, since the async and sync tasks are waiting for each other to finish.")
                RunButton("(CRASH) From Main: DispatchQueue.main.sync", toMainQueue_sync)
                RunButton("(CRASH) From serialQueue.async: serialQueue.sync", {(title: String) -> Void in
                    serialQueue.async {
                        ThreadLogger.log("(3) \(title) serialQueue.async")
                        serialQueue.sync { // CRASH because DISPATCH_WAIT_FOR_QUEUE here
                            ThreadLogger.log("(never) \(title) serialQueue.sync")
                        }
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
                
                Text("Similarily, calling sync on queues that forms a **directed cycle** crashes.")

                RunButton("(CRASH) From serialQueue.async: global().sync, serialQueue.sync", {(title: String) -> Void in
                    serialQueue.async {
                        ThreadLogger.log("(3) \(title) serialQueue.async start") // Thread A
                        concurrentQueue.sync {
                            ThreadLogger.log("(4) \(title) anyQueue.sync start") // Thread B
                            serialQueue.sync { // CRASH b/c thread A is blocked
                                ThreadLogger.log("(never) \(title) serialQueue.sync")
                            }
                        }
                    }
                    ThreadLogger.log("(2) \(title) END")
                })
            }.accentColor(.red)
            
            VStack(alignment: .leading) {
                Text("Settings").bold().dynamicTypeSize(.xxLarge)
                
                Toggle("Run Longer Work Items", isOn: $longerWorkItems).tint(.orange).padding(.trailing, 2)

                RunButton("Spawn blocked thread on concurrent queue", {(title: String) -> Void in
                    spawnCounter.increment()
                    let spawnNum = spawnCounter.count
                    concurrentQueue.async {
                        ThreadLogger.log("(3) \(title) | Spawn: #\(spawnNum) | async START")
                        while(true) {
                            sleep(1)
                            ThreadLogger.log("(4) \(title) | Spawn: #\(spawnNum) | async block")
                        }
                    }
                    ThreadLogger.log("(2) \(title) | Spawn: #\(spawnNum) END")
                }).accentColor(.orange)
            }
        }
    }
    
    // # MARK: Private
    
    func fromSerialQueue(_ fn: @escaping (_ title: String) -> Void) -> (_ title: String) -> Void {
        return {(title: String) -> Void in
            serialQueue.async {
                fn(title)
            }
        }
    }
    
    func toMainQueue_async(_ title: String) {
        DispatchQueue.main.async {
            longWorkTask("(3) 🥝 \(title) main.async")
        }
        DispatchQueue.main.async {
            longWorkTask("(4) 🍊 \(title) main.async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func toMainQueue_sync(_ title: String) {
        // EXC_BAD_INSTRUCTION Crash.
        // Calling `sync` and targeting the current queue results in deadlock,
        // because 'sync' blocks current thread until pending items has finished.
        DispatchQueue.main.sync { // 2
            ThreadLogger.log("(never) \(title) main.sync")
        }
        ThreadLogger.log("(never) \(title) END")
    }
    
    
    // serial queue guarantees that only one thread will being executing work on the queue at a time
    // It does not guarantee which specific thread will do that execution.
    // Dispatch maintains a pool of worker threads and, when work becomes available to execute, it will allocate one thread from that pool to run that work.
    func toSerialQueue_async(_ title: String) {
        serialQueue.async {
            longWorkTask("(3) 🥝 \(title) serialQueue.async")
        }
        serialQueue.async {
            longWorkTask("(4) 🍊 \(title) serialQueue.async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func toSerialQueue_sync(_ title: String) {
        serialQueue.sync {
            longWorkTask("(2) 🍊 \(title) serialQueue.async")
        }
        serialQueue.sync {
            longWorkTask("(2) 🥝 \(title) serialQueue.async")
        }
        ThreadLogger.log("(3) \(title) END")
    }
    
    func toConcurrentQueue_async(_ title: String) {
        concurrentQueue.async {
            longWorkTask("(3) 🍊 \(title) concurrentQueue.async")
        }
        concurrentQueue.async {
            longWorkTask("(3) 🥝 \(title) concurrentQueue.async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func toConcurrentQueue_sync(_ title: String) {
        concurrentQueue.sync {
            longWorkTask("(2) 🍊 \(title) concurrentQueue.sync")
        }
        concurrentQueue.sync {
            longWorkTask("(3) 🥝 \(title) concurrentQueue.sync")
        }
        ThreadLogger.log("(4) \(title) END")
    }
    
    func toConcurrentGlobal_async(_ title: String) {
        DispatchQueue.global().async {
            longWorkTask("(3) 🍊 \(title) DispatchQueue.global().async")
        }
        DispatchQueue.global().async {
            longWorkTask("(3) 🥝 \(title) DispatchQueue.global().async")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func toConcurrentGlobal_sync(_ title: String) {
        DispatchQueue.global().sync {
            longWorkTask("(3) 🍊 \(title) DispatchQueue.global().sync")
        }
        DispatchQueue.global().sync {
            longWorkTask("(3) 🥝 \(title) DispatchQueue.global().sync")
        }
        DispatchQueue.global().sync {
            longWorkTask("(3) 😍 \(title) DispatchQueue.global().sync")
        }
        ThreadLogger.log("(2) \(title) END")
    }
    
    func globalToSerialQueue_sync(_ title: String) {
        DispatchQueue.global().async {
            ThreadLogger.log("(3) \(title) serialQueue.async")
            toSerialQueue_sync(title)
        }
        ThreadLogger.log("(2) \(title) END")
    }
}
