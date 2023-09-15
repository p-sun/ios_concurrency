# Swift iOS Concurrency
Grand central dispatch examples to validate the developer's understanding. The app includes different combinations of async, sync, serial, concurrent, DispatchQueue.main, DispatchQueue.global(), etc...

Emojis make it easy to visually scan the logs to see which work item occurred on which thread. In each example:
* Each work item is maked with a different fruit emoji. e.g. 🍊,🫐,🥝, or 🍇.
* Each work item is preceeded by a number indicating the order it occurs. e.g. "(4) 🍊"
* Each thread number is hashed to a combination of one or two squares. e.g. Main thread 1 is always 🟥, thread 6 is always 🟧, thread 15 is always ⬜️🟪, etc...

## Sync and async in a concurrent queue
Press the button to run this example. Note the code and the logs.

![__con268081491-b2b9b5b7404-4660-ad2c-6f73a35a469a](https://github.com/p-sun/ios_concurrency/assets/9044578/5eb229d4-36c3-4d48-888c-67c6c92b2ad0)

## Video Sample

https://github.com/p-sun/ios_concurrency/assets/9044578/5b7e0e19-ea8a-48fa-a46e-d2e1f6d17ef4
