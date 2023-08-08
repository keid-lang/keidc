use std::{fmt::Display, process::ExitCode};

use clap::*;
use keid::compiler::{
    llvm::{Context, LLVMTargetData, Target},
    *,
};

#[derive(Parser, Debug)]
#[command()]
struct Cli {
    /// Paths to Keid source code files to compile
    files: Vec<String>,

    /// Skip all compilation, and instead link all binary objects (e.g. ELF, Mach-O, etc) in the target directory to a static library
    #[arg(long)]
    link_only: bool,

    /// Interprets the output LLVM IR within the LLVM JIT execution engine.
    #[arg(long)]
    interpret: bool,

    /// Comma separated list of the formats that will be emitted by the compiler
    #[arg(long, value_delimiter = ',', default_values_t = vec![EmitType::Object])]
    emit: Vec<EmitType>,

    /// LLVM target triple to compile to
    #[arg(long)]
    target: Option<String>,

    /// Directory to write output files to
    #[arg(short, long)]
    out_dir: Option<String>,

    /// Build in release mode with all optimizations
    #[arg(long)]
    release: bool,

    /// Print verbose debug information
    #[arg(long)]
    print: Option<PrintOption>,
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

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum PrintOption {
    TargetList,
}

fn main() -> ExitCode {
    keid::compiler::llvm::initialize();

    let args = Cli::parse();

    match args.print {
        Some(PrintOption::TargetList) => {
            todo!();
            // println!("Available targets:");

            // let mut targets: Vec<String> = Target::get_available_targets().into_iter().map(|target| target.name).collect();
            // targets.sort();
            // for target in targets {
            //     println!("  {}", target);
            // }

            // return ExitCode::SUCCESS;
        }
        None => (),
    }

    let out_dir = args.out_dir.clone().unwrap_or(".".to_owned());
    let out_dir = match std::fs::canonicalize(&out_dir) {
        Ok(out_dir) => out_dir,
        Err(e) => {
            println!(
                "Failed to resolve path: `{}`, OS error {}",
                out_dir,
                e.raw_os_error().unwrap()
            );
            return ExitCode::FAILURE;
        }
    };

    if !args.link_only {
        for emit in &args.emit {
            let target_triple = match emit {
                EmitType::LlvmIr => "__llvm_ir".to_owned(),
                EmitType::Object => {
                    // todo!()
                    // if Target::get_from_name(&target_triple).is_none() {
                    //     println!("Unknown target triple: `{}`", target_triple);
                    //     return ExitCode::FAILURE;
                    // }
                    args.target
                        .clone()
                        .unwrap_or_else(|| Target::get_host_target_triple().to_owned())
                }
            };

            let target = LLVMTargetData::new(&target_triple, !args.release, true).unwrap();
            let mut context = Context::new(target.clone());
            let mut sigs = SignatureCompiler::new();

            if args.files.is_empty() || args.emit.is_empty() {
                Cli::command().print_help().unwrap();
                return ExitCode::FAILURE;
            }

            for path in &args.files {
                let contents = match std::fs::read_to_string(&path) {
                    Ok(contents) => contents,
                    Err(e) => {
                        println!(
                            "Failed to read file at `{}`, OS error {}",
                            path,
                            e.raw_os_error().unwrap()
                        );
                        return ExitCode::FAILURE;
                    }
                };

                let path = std::fs::canonicalize(&path).unwrap();
                let path = path.as_os_str().to_str().unwrap();
                let keid_file = match keid::parser::parse(path, &contents) {
                    Ok(file) => file,
                    Err(err) => {
                        eprintln!("Error in {}:\n{}", path, err);
                        std::process::exit(1);
                    }
                };

                sigs.add_file(keid_file);
            }

            let resources = sigs.compile(out_dir.to_str().unwrap(), &mut context);

            let class_info = ClassInfoStorage::new(&mut context);
            let mut compiler = Compiler::new(&target_triple, class_info, context);
            if compiler.compile(resources, &target) {
                for (path_name, error) in compiler.get_errors() {
                    let pest_error = error
                        .as_pest_error(
                            &String::from_utf8(std::fs::read(&path_name).expect("file error"))
                                .unwrap(),
                        )
                        .with_path(&path_name);

                    println!("{}", pest_error);
                }
                return ExitCode::FAILURE;
            }
            let artifacts = compiler.create_artifacts(out_dir.to_str().unwrap(), &target); // invert release to debug
            for artifact in artifacts {
                let artifact_ext = match artifact.kind {
                    CompilationArtifactType::KeidPackage => "kpkg",
                    CompilationArtifactType::NativeObject => "o",
                    CompilationArtifactType::LlvmIr => "ll",
                };
                std::fs::write(
                    out_dir.join(format!("{}.{}", artifact.name, artifact_ext)),
                    artifact.data,
                )
                .unwrap();
            }

            if args.interpret {
                println!("Executing interpreter...");
                compiler.interpret();
                println!("Interpreter finished!")
            }
        }
    }

    let linker = Linker::new();
    linker.link(ObjectFormat::Elf, out_dir);

    ExitCode::SUCCESS
}
