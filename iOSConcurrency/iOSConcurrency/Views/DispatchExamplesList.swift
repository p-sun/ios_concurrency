import Foundation
import SwiftUI

struct DispatchExamplesList_Previews: PreviewProvider {
    static var previews: some View {
        DispatchExamplesList()
    }
}

class Counter {
    private (set) var count = 0
    
    func increment() {
        count += 1
    }
}

func DQSection<Content: View>(_ header: String, @ViewBuilder _ content: () -> Content) -> some View {
    VStack(alignment: .leading) {
        Text(header).bold().dynamicTypeSize(.xxLarge)
        content()
    }
}

func DQRunButton(_ title: String, _ action: @escaping (_ title: String) -> Void) -> some View {
    Button(action: {
        ThreadLogger.log("\(title) | (1) START")
        action(title)
    }) {
        HStack {
            Text(title).multilineTextAlignment(.leading)
            Spacer()
        }
    }.buttonStyle(.borderedProminent)
}

struct DispatchExamplesList: View {
    var spawnCounter = Counter()
    let serialQueue = DispatchQueue(label: "paige.serial.queue")
    let concurrentQueue = DispatchQueue(label: "paige.concurrent.queue", attributes: .concurrent)
    
    @State var longerWorkItems = false
    func longWorkTask(_ title: String, _ text: String) {
        let sleepTime: UInt32 = longerWorkItems ? 300000 : 100000 // 1/3s vs 1/10s
        for _ in 10...14 {
            ThreadLogger.log("\(title) | \(text)")
            usleep(sleepTime) // 1000000 = 1 sec
        }
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 30) {
            DQSection("queue.async{ doWork() }") {
                
                Text("executes work on that queue.")
                DQRunButton("From Main: DispatchQueue.main.async", {(title: String) -> Void in
                    DispatchQueue.main.async {
                        longWorkTask(title, "(3) 🥝 main.async")
                    }
                    DispatchQueue.main.async {
                        longWorkTask(title, "(4) 🍊 main.async")
                    }
                    ThreadLogger.log("\(title) | (2)  END")
                })
                
                // serial queue guarantees that only one thread will being executing work on the queue at a time
                // It does not guarantee which specific thread will do that execution.
                // Dispatch maintains a pool of worker threads and, when work becomes available to execute, it will allocate one thread from that pool to run that work.
                Text("Serial queue executes one work item at a time.")
                DQRunButton("From Main: serialQueue.async", { (title: String) -> Void in
                    serialQueue.async {
                        longWorkTask(title, "(3) 🥝 serialQueue.async")
                    }
                    serialQueue.async {
                        longWorkTask(title, "(4) 🍊 serialQueue.async")
                    }
                    ThreadLogger.log("\(title) | (2) END")
                })
                
                Text("Concurrent queue can execute multiple work items at once.")
                DQRunButton("From Main: concurrentQueue.async", { (title: String) -> Void in
                    concurrentQueue.async {
                        longWorkTask(title, "(3) 🍊 concurrentQueue.async")
                    }
                    concurrentQueue.async {
                        longWorkTask(title, "(3) 🥝 concurrentQueue.async")
                    }
                    ThreadLogger.log("\(title) | (2) END")
                })
                
                Text("DispatchQueue.global() has a pool of concurrent threads.")
                DQRunButton("From Main: DispatchQueue.global().async", { title in
                    DispatchQueue.global().async {
                        longWorkTask(title, "(3) 🍊 DispatchQueue.global().async")
                    }
                    DispatchQueue.global().async {
                        longWorkTask(title, "(3) 🥝 DispatchQueue.global().async")
                    }
                    ThreadLogger.log("\(title) | (2) END")
                })
            }
            
            DQSection("queue.sync{ doWork() }") {
                Text("blocks current thread until work is executed on current thread.")
                DQRunButton("From Main: serialQueue.sync", { title in
                    serialQueue.sync {
                        longWorkTask(title, "(2) 🍊 serialQueue.async")
                    }
                    serialQueue.sync {
                        longWorkTask(title, "(2) 🥝 serialQueue.async")
                    }
                    ThreadLogger.log("\(title) | (3) END")
                })
                
                DQRunButton("From Main: concurrentQueue.sync", { title in
                    concurrentQueue.sync {
                        longWorkTask(title, "(2) 🍊 concurrentQueue.sync")
                    }
                    concurrentQueue.sync {
                        longWorkTask(title, "(3) 🥝 concurrentQueue.sync")
                    }
                    ThreadLogger.log("\(title) | (4) END")
                })
                
                Text("Calling sync **from** and **to** the same **concurrent** queue is okay. Note the order work items are executed.")
                DQRunButton("From concurrentQueue.async: concurrentQueue.sync, .sync", {(title: String) -> Void in
                    concurrentQueue.async {
                        ThreadLogger.log("\(title) | (3) outer async START")
                        concurrentQueue.sync {
                            longWorkTask(title, "(4) 🍊 concurrentQueue.sync")
                        }
                        concurrentQueue.sync {
                            longWorkTask(title, "(5) 🥝 concurrentQueue.sync")
                        }
                        ThreadLogger.log("\(title) | (6) outer async END")
                    }
                    ThreadLogger.log("\(title) | (2) END")
                })
                
                DQRunButton("From concurrentQueue.async: concurrentQueue.async, .sync", {(title: String) -> Void in
                    concurrentQueue.async {
                        ThreadLogger.log("\(title) | (3) outer async START") // Thread A
                        concurrentQueue.async {
                            longWorkTask(title, "(4) 🍊 concurrentQueue.async") // Spins up new thread B
                        }
                        concurrentQueue.sync {
                            longWorkTask(title, "(4) 🥝 concurrentQueue.sync") // Thread A
                        }
                        ThreadLogger.log("\(title) | (5) outer async END") // Thread A
                    }
                    ThreadLogger.log("\(title) | (2) END")
                })
                
                DQRunButton("From concurrentQueue.async: concurrentQueue.sync, async, sync, async", {(title: String) -> Void in
                    concurrentQueue.async {
                        ThreadLogger.log("\(title) | (3) | outer async START")  // Thread A
                        concurrentQueue.sync {
                            longWorkTask(title, "(4) 🍊 | concurrentQueue.sync")  // Thread A
                        }
                        concurrentQueue.async {
                            longWorkTask(title, "(5) 🥝 | concurrentQueue.async") // Spins up new thread B
                        }
                        concurrentQueue.sync {
                            longWorkTask(title, "(5) 🫐 | concurrentQueue.sync")  // Thread A
                        }
                        concurrentQueue.async {
                            longWorkTask(title, "(6) 🍇 | concurrentQueue.async")  // Spins up new thread C or reuses thread B
                        }
                        ThreadLogger.log("\(title) | (7) | outer async END")  // Thread A
                    }
                    ThreadLogger.log("\(title) | (2) | END")
                })
            }
            
            // https://developer.apple.com/documentation/dispatch/dispatchworkitemflags/1780674-barrier
            DQSection("DispatchWorkItemFlags - Barrier") {
                
                DQRunButton("No barrier. From Main: concurrentQueue.async, async, sync, async", {(title: String) -> Void in
                    concurrentQueue.async {
                        longWorkTask(title, "(2) 🍊 | concurrentQueue.async")  // Thread A
                    }
                    concurrentQueue.async {
                        longWorkTask(title, "(2) 🥝 | concurrentQueue.async") // Spins up new thread B
                    }
                    concurrentQueue.sync {
                        longWorkTask(title, "(2) 🫐 | concurrentQueue.sync")  // Main
                    }
                    ThreadLogger.log("\(title) | (3) | END")
                })
                
                Text("Prior scheduled work completes, then barrier work completes, then work scheduled after executes.")
                DQRunButton("Sync With barrier. From Main: concurrentQueue.async, async, sync with barrier, async", {(title: String) -> Void in
                    concurrentQueue.async {
                        longWorkTask(title, "(2) 🍊 | concurrentQueue.async") // Thread A
                    }
                    concurrentQueue.async {
                        longWorkTask(title, "(2) 🥝 | concurrentQueue.async") // Spins up new thread B
                    }
                    concurrentQueue.sync(flags: .barrier) {
                        longWorkTask(title, "(3) 🫐 | concurrentQueue.sync") // Main
                    }
                    ThreadLogger.log("\(title) | (4) | END")
                })
                
                DQRunButton("Async with barrier. From Main: concurrentQueue.async, async, async with barrier, async", {(title: String) -> Void in
                    concurrentQueue.async {
                        longWorkTask(title, "(3) 🍊 | concurrentQueue.async")  // Thread A
                    }
                    concurrentQueue.async {
                        longWorkTask(title, "(3) 🥝 | concurrentQueue.async") // Spins up new thread B
                    }
                    concurrentQueue.async(flags: .barrier) {
                        longWorkTask(title, "(4) 🫐 | concurrentQueue.sync")
                    }
                    concurrentQueue.async {
                        longWorkTask(title, "(5) 🍇 | concurrentQueue.sync")
                    }
                    ThreadLogger.log("\(title) | (2) | END")
                })
            }
            
            DQSection("Avoiding crashes with sync") {
                Text("Calling sync **from** and **to** the same **serial** queue crashes, since the async and sync tasks are waiting for each other to finish.")
                DQRunButton("(CRASH) From Main: DispatchQueue.main.sync", { title in
                    // EXC_BAD_INSTRUCTION Crash.
                    // Calling `sync` and targeting the current queue results in deadlock,
                    // because 'sync' blocks current thread until pending items has finished.
                    DispatchQueue.main.sync { // 2
                        ThreadLogger.log("\(title) | (never) main.sync")
                    }
                    ThreadLogger.log("\(title) | (never) END")
                })
                
                DQRunButton("(CRASH) From serialQueue.async: serialQueue.sync", {(title: String) -> Void in
                    serialQueue.async {
                        ThreadLogger.log("\(title) | (3) serialQueue.async")
                        serialQueue.sync { // CRASH because DISPATCH_WAIT_FOR_QUEUE here
                            ThreadLogger.log("\(title) | (never) serialQueue.sync")
                        }
                    }
                    ThreadLogger.log("\(title) | (2) END")
                })
                
                Text("Similarily, calling sync on queues that forms a **directed cycle** crashes.")
                DQRunButton("(CRASH) From serialQueue.async: global().sync, serialQueue.sync", {(title: String) -> Void in
                    serialQueue.async {
                        ThreadLogger.log("\(title) | (3) serialQueue.async start") // Thread A
                        concurrentQueue.sync {
                            ThreadLogger.log("\(title) | (4) anyQueue.sync start") // Thread B
                            serialQueue.sync { // CRASH b/c thread A is blocked
                                ThreadLogger.log("\(title) | (never) serialQueue.sync")
                            }
                        }
                    }
                    ThreadLogger.log("\(title) | (2) END")
                })
            }.accentColor(.red)
            
            DQSection("Settings") {
                
                Toggle("Run Longer Work Items", isOn: $longerWorkItems).tint(.orange).padding(.trailing, 2)
                
                DQRunButton("Spawn blocked thread on concurrent queue", {(title: String) -> Void in
                    spawnCounter.increment()
                    let spawnNum = spawnCounter.count
                    concurrentQueue.async {
                        ThreadLogger.log("\(title) | (3) | Spawn: #\(spawnNum) | async START")
                        while(true) {
                            sleep(1)
                            ThreadLogger.log("\(title) | (4) | Spawn: #\(spawnNum) | async block")
                        }
                    }
                    ThreadLogger.log("\(title) | (2) | Spawn: #\(spawnNum) END")
                }).accentColor(.orange)
            }
        }
    }
    
    func fromSerialQueue(_ fn: @escaping (_ title: String) -> Void) -> (_ title: String) -> Void {
        return {(title: String) -> Void in
            serialQueue.async {
                fn(title)
            }
        }
    }
}
