#!/bin/bash
cargo run -- --emit llvm-ir,object ../keid/assets/core/**/*.keid ../keid/assets/std/**/*.keid ../keid/assets/impl/std.linux.keid ../keid/assets/compiler/main.keid
