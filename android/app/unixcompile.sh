cd ../../
echo "Running Flutter Rust Bridge Codegen"
#flutter_rust_bridge_codegen --rust-input rust/src/api.rs --dart-output lib/bridge_generated.dart --dart-decl-output lib/bridge_definitions.dart
cd rust/
cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64  -o ../android/app/src/main/jniLibs build $profileMode