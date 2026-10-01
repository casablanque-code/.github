fn greeting() -> &'static str {
    "hello from template-rust"
}

fn main() {
    println!("{}", greeting());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn greets() {
        assert_eq!(greeting(), "hello from template-rust");
    }
}
