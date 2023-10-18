# catenary-flutter
Cross-platform build of Catenary Maps for iOS, Android, and Web.

### Instructions

`cargo install flutter_rust_bridge_codegen`
`cargo install cargo-expand`

### Developers Common Installation / Running problems

#### No Configuration Found in Android Studio

Solution: Install Flutter to your plugins and restart Android Studio

### No Cargo command called ndk
Error:
```
error: no such command: `ndk`

        Did you mean `add`?

        View all installed commands with `cargo --list`
```
Solution:
1. Install toolchains: 
```
rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android
```

2. Install Cargo NDK

```
cargo install cargo-ndk
```

### Error: Could not find any NDK.
Error:
```
error: Could not find any NDK.
note: Set the environment ANDROID_NDK_HOME to your NDK installation's root directory,
or install the NDK using Android Studio.

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:cargoBuildDebug'.
> Process 'command 'sh'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.

* Get more help at https://help.gradle.org

```

Solution on Unix:
Change the path in your bash profile file by adding lines like this.
Your exact NDK path may differ
```
export ANDROID_NDK_HOME=/home/kyler/Android/Sdk/ndk/26.1.10909125
export PATH=$ANDROID_NDK_HOME:$PATH 
```