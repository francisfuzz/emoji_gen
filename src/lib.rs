use rand::prelude::IndexedRandom;
use std::sync::LazyLock;

/// A lazily-initialized pool of all Unicode emojis.
/// Built from the `emojis` crate, which provides comprehensive Unicode emoji coverage.
static EMOJI_POOL: LazyLock<Vec<&'static str>> =
    LazyLock::new(|| emojis::iter().map(|e| e.as_str()).collect());

/// Core logic: Generates a vector of n random emojis.
/// Returns empty vector if count is 0.
pub fn generate_emojis(count: usize) -> Vec<&'static str> {
    if count == 0 {
        return Vec::new();
    }

    let mut rng = rand::rng();
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
        // Verify the emoji is in our pool (LazyLock derefs to Vec)
        assert!(EMOJI_POOL.contains(&result[0]));
        // Verify it's a valid Unicode emoji
        assert!(emojis::get(result[0]).is_some());
    }

    #[test]
    fn test_generate_multiple_emojis() {
        let count = 5;
        let result = generate_emojis(count);
        assert_eq!(result.len(), count);
        for emoji in result {
            assert!(EMOJI_POOL.contains(&emoji));
            assert!(emojis::get(emoji).is_some());
        }
    }

    #[test]
    fn test_generate_zero_emojis() {
        let result = generate_emojis(0);
        assert!(result.is_empty());
    }

    #[test]
    fn test_emoji_pool_size() {
        // Verify we have a comprehensive emoji pool (1800+ emojis from emojis crate)
        assert!(
            EMOJI_POOL.len() > 1800,
            "Expected large emoji pool, got {}",
            EMOJI_POOL.len()
        );
    }
}
