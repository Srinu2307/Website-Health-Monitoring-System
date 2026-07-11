# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Initial Release

### Added
- Core execution engine `website_monitor.sh` using Bash 4+.
- Modular architecture with `check_dns`, `check_icmp`, `check_http` functions.
- Multi-target support via `-f targets.txt`.
- Output formatting for terminal (colorized).
- JSON export reporting.
- Advanced Risk Classification matrix (Low, Medium, High, Critical).
- HTML response content inspection using regex.
- Configuration templates via `config.env.example`.
- Full GitHub documentation suite (README, SECURITY, CONTRIBUTING, Architecture).
