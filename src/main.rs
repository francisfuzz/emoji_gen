use clap::Parser;
use emoji_gen::generate_emojis;

/// A simple CLI to generate random emojis
#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Args {
    /// Number of emojis to generate
    #[arg(short, long, default_value_t = 1)]
    count: usize,
}

fn main() {
    let args = Args::parse();
    let emojis = generate_emojis(args.count);
    println!("{}", emojis.join(" "));
}
