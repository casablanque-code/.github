.PHONY: fmt lint test build run

fmt:
	cargo fmt --all

lint:
	cargo fmt --all -- --check
	cargo clippy --locked --all-targets --all-features -- -D warnings

test:
	cargo test --locked --all-features

build:
	cargo build --locked --release

run:
	cargo run --locked
