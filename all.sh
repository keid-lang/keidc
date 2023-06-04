#!/bin/bash

rm ./*.ll
rm ./*.o
rm ./exec

export GLOBIGNORE="String.test.keid:StringBuilder.test.keid::array.test.keid:Class.test.keid"
cargo run -- --emit llvm-ir,object ../keid/assets/core/*.keid ../keid/assets/core/**/*.keid ../keid/assets/std/*.keid ../keid/assets/impl/std.linux.keid ../keid/assets/compiler/main.keid
unset GLOBIGNORE
