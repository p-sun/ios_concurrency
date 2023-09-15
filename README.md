# Swift iOS Concurrency
Grand central dispatch examples to validate the developer's understanding. The app includes different combinations of async, sync, serial, concurrent, DispatchQueue.main, DispatchQueue.global(), etc...

Emojis make it easy to visually scan the logs to see which work item occurred on which thread. In each example:
* Each work item is maked with a different fruit emoji. e.g. 🍊,🫐,🥝, or 🍇.
* Each work item is preceeded by a number indicating the order it occurs. e.g. "(4) 🍊"
* Each thread number is hashed to a combination of one or two squares. e.g. Main thread 1 is always 🟥, thread 6 is always 🟧, thread 15 is always ⬜️🟪, etc...

## Sync and async in a concurrent queue
Press the button to run this example. Note the code and the logs.

![__con268081491-b2b9b5b7-9404-4660-ad2c-6f73a35a469a](https://github.com/p-sun/ios_concurrency/assets/9044578/11523a08-2cda-4efc-89d0-67c52006b121)

## Video Sample

https://github.com/p-sun/ios_concurrency/assets/9044578/fbe320ea-fcc5-4e60-82a0-5959a42694ec
