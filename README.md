# Swift iOS Concurrency
Grand central dispatch examples to validate the developer's understanding. The app includes different combinations of async, sync, serial, concurrent, DispatchQueue.main, DispatchQueue.global(), etc...

Emojis make it easy to visually scan the logs to see which work item occurred on which thread. In each example:
* Each work item is maked with a different fruit emoji. e.g. 🍊,🫐,🥝, or 🍇.
* Each work item is preceeded by a number indicating the order it occurs. e.g. "(4) 🍊"
* Each thread number is hashed to a combination of one or two squares. e.g. Main thread 1 is always 🟥, thread 6 is always 🟧, thread 15 is always ⬜️🟪, etc...

## Sync and async in a concurrent queue
Press the button to run this example. Note the code and the logs.

![Screenshot 2023-09-16 at 1 42 25 PM](https://github.com/p-sun/ios_concurrency/assets/9044578/0e9e1967-923a-4a4b-aa12-e03b0b0ff82b)

## Video Sample

https://github.com/p-sun/ios_concurrency/assets/9044578/4fc81fc5-1b19-457a-bbd6-929ff4d2d443
