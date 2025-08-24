#!/usr/bin/env node

const fs = require('fs');
const { generateSummary } = require('./generate-summary');

console.log('Testing TOC generation...');

// Save original SUMMARY.md if it exists
const summaryFile = 'book-src/SUMMARY.md';
let originalContent = null;

if (fs.existsSync(summaryFile)) {
    originalContent = fs.readFileSync(summaryFile, 'utf8');
}

try {
    // Generate SUMMARY.md
    generateSummary();
    
    // Read the generated content
    const generatedContent = fs.readFileSync(summaryFile, 'utf8');
    
    // Basic checks
    if (!generatedContent.includes('# Summary')) {
        throw new Error('Generated file missing "# Summary" title');
    }
    
    if (!generatedContent.includes('[Introduction](./intro.md)')) {
        throw new Error('Generated file missing introduction link');
    }
    
    if (!generatedContent.includes('- [File System]()')) {
        throw new Error('Generated file missing File System section');
    }
    
    if (!generatedContent.includes('- [Database](database.md)')) {
        throw new Error('Generated file missing Database link');
    }
    
    if (!generatedContent.includes('15-01-regex.md')) {
        throw new Error('Generated file missing regex link (without ./ prefix)');
    }
    
    console.log('✅ All tests passed!');
    console.log('✅ TOC generation is working correctly');
    
} catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
} finally {
    // Restore original content if we had it
    if (originalContent !== null) {
        fs.writeFileSync(summaryFile, originalContent, 'utf8');
    }
}