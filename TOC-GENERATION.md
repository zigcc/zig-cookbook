# TOC Generation

This project includes an automated Table of Contents (TOC) generation system that creates the `book-src/SUMMARY.md` file from a simpler `toc.md` format.

## Usage

### Updating the TOC

1. Edit the `toc.md` file in the root directory
2. Run the generation script:
   ```bash
   node generate-summary.js
   # or
   make generate-summary
   # or 
   npm run generate-summary
   ```

### TOC Format

The `toc.md` file uses a simplified format:

```markdown
# Table of Contents

[Introduction](./intro.md)

## Section Name
- Item Title | filename.md
- Another Item | another-file.md
- Item without file

## Another Section
- More items | file.md
```

Special cases:
- Introduction link: `[Introduction](./intro.md)` 
- Section with custom file: `## Database [database.md]`
- Items without files are rendered as empty links: `- ANSI Terminal`

### Automatic Integration

The TOC generation is automatically integrated into:
- **Make**: `make serve` automatically regenerates the TOC
- **CI/CD**: GitHub Actions builds automatically run TOC generation
- **npm**: `npm run prebuild` runs before any build command

### Manual vs Generated Files

- **Edit**: `toc.md` (source of truth)  
- **Don't edit**: `book-src/SUMMARY.md` (auto-generated)

The `SUMMARY.md` file will be automatically regenerated and should not be manually edited.