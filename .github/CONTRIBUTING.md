# Contributing to Card3D

Contributions are welcome! Please follow these steps to ensure your code meets project standards:

## How to Contribute

- **Fork the repository** and create your branch from `main`.
- **Make your changes** with clear, descriptive commit messages.
- **Test your changes** locally before submitting a pull request.


## Linting GDScript
We use `gdlint` to help maintain code quality and consistency.

See [gdtoolkit](https://github.com/Scony/gdtoolkit) for installation and usage instructions.

To lint all `.gd` files:

```bash
gdlint $(find . -name "*.gd")
```


## Guidelines

- Ensure all code passes linting and formatting checks.
- Make sure the pipeline passes on GitHub Actions.
- Add clear documentation and comments to new features.

## Pull Requests

- Open a pull request with a clear description of your changes.
- Make sure your branch is up to date with `main`.
- Address any CI or code review feedback.