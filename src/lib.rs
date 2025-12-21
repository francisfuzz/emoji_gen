use rand::seq::SliceRandom;

/// A constant list of emojis to choose from
const EMOJI_POOL: &[&str] = &[
    "😀", "😎", "🦀", "🔥", "🚀", "🍕", "🎉", "💻", "🤖", "🦄", "🍩", "🌍", "💡", "🐉", "🎲", "🎹",
    "🎨", "🌮", "⚡", "👽",
];

/// Core logic: Generates a vector of n random emojis.
/// Returns empty vector if count is 0.
pub fn generate_emojis(count: usize) -> Vec<&'static str> {
    if count == 0 {
        return Vec::new();
    }

    let mut rng = rand::thread_rng();
    (0..count)
        .map(|_| {
            *EMOJI_POOL
                .choose(&mut rng)
                .expect("EMOJI_POOL is non-empty")
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_single_emoji() {
        let result = generate_emojis(1);
        assert_eq!(result.len(), 1);
        assert!(EMOJI_POOL.contains(&result[0]));
    }

    #[test]
    fn test_generate_multiple_emojis() {
        let count = 5;
        let result = generate_emojis(count);
        assert_eq!(result.len(), count);
        for emoji in result {
            assert!(EMOJI_POOL.contains(&emoji));
        }
    }

    #[test]
    fn test_generate_zero_emojis() {
        let result = generate_emojis(0);
        assert!(result.is_empty());
    }
}
