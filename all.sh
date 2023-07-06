#!/bin/bash

rm ./*.ll
rm ./*.o
rm ./exec

cd ../keid/rtdbg ; cargo build --release ; cd ../../keidc ; cp ../keid/rtdbg/target/release/librtdbg.a .
cargo run -- --emit llvm-ir,object ../keid/assets/core/*.keid ../keid/assets/core/**/*.keid ../keid/assets/std/*.keid ../keid/assets/impl/linux/**/*.keid ../keid/assets/compiler/main.keid
