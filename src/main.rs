use std::{fmt::Display, process::ExitCode};

use clap::*;
use keid::compiler::{llvm::Context, *};

#[derive(Parser, Debug)]
#[command()]
struct Cli {
    /// The Keid source code files to compile
    files: Vec<String>,

    #[arg(long)]
    /// Skips all compilation, and instead links all binary objects (e.g. ELF, Mach-O, etc) in the target directory to a static library
    link_only: bool,

    #[arg(long, value_delimiter = ',', default_values_t = vec![EmitType::Object])]
    /// Comma separated list of the formats that will be emitted by the compiler
    emit: Vec<EmitType>,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum EmitType {
    LlvmIr,
    Object,
}

impl Display for EmitType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::LlvmIr => f.write_str("llvm-ir")?,
            Self::Object => f.write_str("object")?,
        }

        Ok(())
    }
}

fn main() -> ExitCode {
    let args = Cli::parse();
    if !args.link_only {
        let mut context = Context::new();
        let mut sigs = SignatureCompiler::new(&mut context);

        if args.files.len() == 0 {
            Cli::command().print_help().unwrap();
            return ExitCode::FAILURE;
        }

        for path in args.files {
            let contents = match std::fs::read_to_string(&path) {
                Ok(contents) => contents,
                Err(e) => {
                    println!("Failed to read file at `{}`, OS error {}", path, e.raw_os_error().unwrap());
                    return ExitCode::FAILURE;
                }
            };

            let path = std::fs::canonicalize(&path).unwrap();
            let path = path.as_os_str().to_str().unwrap();
            let keid_file = match keid::parser::parse(&path, &contents) {
                Ok(file) => file,
                Err(err) => {
                    eprintln!("Error in {}:\n{}", path, err);
                    std::process::exit(1);
                }
            };

            sigs.add_file(keid_file);
        }

        let resources = sigs.compile();

        let class_info = ClassInfoStorage::new(&mut context);
        let compiler = Compiler::new(class_info, context);
        if compiler.compile(resources) {
            return ExitCode::FAILURE;
        }
    }

    let linker = Linker::new();
    linker.link(ObjectFormat::Elf);

    ExitCode::SUCCESS
}
