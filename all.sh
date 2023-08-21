#!/bin/bash

MODE=debug
if [ "$1" = "--release" ]; then
  MODE=release
  cargo build --release
elif [ -z "$1" ]; then
  cargo build
else
  echo "usage: all.sh [--release]"
  exit 1
fi

rm ./*.ll
rm ./*.o
rm ./*.kpkg
rm ./exec

cd ../keid/rtdbg
cargo build --release
cd ../../keidc
cp ../keid/rtdbg/target/release/librtdbg.a .
cp $(find $LLVM_SYS_150_PREFIX -name libunwind.a) .

./target/$MODE/keidc --target x86_64-unknown-linux-gnu --emit llvm-ir,object ../keid/assets/core/*.keid ../keid/assets/core/**/*.keid ../keid/assets/std/*.keid ../keid/assets/impl/linux/**/*.keid ../keid/assets/compiler/*.keid ../keid/assets/compiler/**/*.keid
