#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Parse toc.md and generate SUMMARY.md for mdBook
 */

const TOC_FILE = path.join(__dirname, 'toc.md');
const SUMMARY_FILE = path.join(__dirname, 'book-src', 'SUMMARY.md');

function parseTocFile(content) {
    const lines = content.split('\n');
    const result = [];
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        
        if (!line) {
            continue; // Skip empty lines in input
        }
        
        // Handle title
        if (line.startsWith('# ')) {
            result.push('# Summary');
            result.push('');
            continue;
        }
        
        // Handle the introduction line specifically
        if (line.startsWith('[Introduction]')) {
            result.push(line);
            result.push('');
            continue;
        }
        
        // Handle section headers (## Section Name)
        if (line.startsWith('## ')) {
            const sectionLine = line.substring(3).trim();
            
            // Special case for Database with file reference
            if (sectionLine.startsWith('Database [') && sectionLine.includes(']')) {
                const filename = sectionLine.match(/\[(.*?)\]/)[1];
                result.push(`- [Database](${filename})`);
            } else {
                result.push(`- [${sectionLine}]()`);
            }
            
            // Text Processing doesn't have a blank line after the section header
            if (sectionLine !== 'Text Processing') {
                result.push('');
            }
            continue;
        }
        
        // Handle items (- Item Name | filename.md or - Item Name)
        if (line.startsWith('- ')) {
            const itemLine = line.substring(2);
            
            // Handle items with pipe separator
            if (itemLine.includes(' | ')) {
                const [title, filename] = itemLine.split(' | ');
                const cleanFilename = filename.trim();
                // Handle special case for Text Processing files which don't have './' prefix in original
                const prefix = (cleanFilename === '15-01-regex.md' || cleanFilename === '15-02-string.md') ? '' : './';
                result.push(`  - [${title.trim()}](${prefix}${cleanFilename})`);
            } else {
                // Handle items without filename (like ANSI Terminal)
                result.push(`  - [${itemLine.trim()}]()`);
            }
            
            // Check if this is the last item in a section (next line is empty or section header)
            const nextNonEmptyLine = findNextNonEmptyLine(lines, i);
            if (!nextNonEmptyLine || nextNonEmptyLine.startsWith('##')) {
                result.push('');
            }
            
            continue;
        }
    }
    
    // Remove any trailing empty lines, then add final newline
    while (result.length > 0 && result[result.length - 1] === '') {
        result.pop();
    }
    return result.join('\n') + '\n';
}

function findNextNonEmptyLine(lines, currentIndex) {
    for (let i = currentIndex + 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line) {
            return line;
        }
    }
    return null;
}

function generateSummary() {
    try {
        console.log('Reading toc.md...');
        const tocContent = fs.readFileSync(TOC_FILE, 'utf8');
        
        console.log('Parsing TOC content...');
        const summaryContent = parseTocFile(tocContent);
        
        console.log('Writing SUMMARY.md...');
        fs.writeFileSync(SUMMARY_FILE, summaryContent, 'utf8');
        
        console.log('Successfully generated SUMMARY.md from toc.md');
    } catch (error) {
        console.error('Error generating SUMMARY.md:', error.message);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    generateSummary();
}

module.exports = { generateSummary, parseTocFile };