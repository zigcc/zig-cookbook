#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// 获取 en-US 目录路径
const enUsDir = path.join(__dirname, 'src', 'en-US');

// 正则表达式匹配带有序号的文件名 (如 01-01, 02-01 等)
const numberedFilePattern = /^(\d{2}-\d{2})-.+\.smd$/;

// 处理单个文件
function processFile(filePath, fileName) {
    const match = fileName.match(numberedFilePattern);
    if (!match) {
        console.log(`跳过非序号文件：${fileName}`);
        return;
    }

    const translationKey = match[1]; // 提取序号部分
    console.log(`处理文件：${fileName} -> 添加 translation_key: ${translationKey}`);

    // 读取文件内容
    let content = fs.readFileSync(filePath, 'utf8');

    // 检查是否已经有 .translation_key
    if (content.includes('.translation_key =')) {
        console.log(`  文件 ${fileName} 已经有 .translation_key，跳过`);
        return;
    }

    // 查找 frontmatter 的结束位置
    const frontmatterEnd = content.indexOf('---', 3);
    if (frontmatterEnd === -1) {
        console.log(`  文件 ${fileName} 没有有效的 frontmatter，跳过`);
        return;
    }

    // 在 frontmatter 结束前添加 .translation_key
    const beforeFrontmatterEnd = content.substring(0, frontmatterEnd);
    const afterFrontmatterEnd = content.substring(frontmatterEnd);
    
    // 添加 .translation_key 字段
    const newContent = beforeFrontmatterEnd + 
                      '.translation_key = "' + translationKey + '",\n' +
                      afterFrontmatterEnd;

    // 写回文件
    fs.writeFileSync(filePath, newContent, 'utf8');
    console.log(`  ✓ 已添加 .translation_key = "${translationKey}" 到 ${fileName}`);
}

// 主函数
function main() {
    console.log('开始处理 en-US 目录中的文件...\n');

    try {
        // 读取目录中的所有文件
        const files = fs.readdirSync(enUsDir);
        
        let processedCount = 0;
        let skippedCount = 0;

        // 处理每个文件
        files.forEach(fileName => {
            if (fileName.endsWith('.smd')) {
                const filePath = path.join(enUsDir, fileName);
                const stats = fs.statSync(filePath);
                
                if (stats.isFile()) {
                    if (numberedFilePattern.test(fileName)) {
                        processFile(filePath, fileName);
                        processedCount++;
                    } else {
                        console.log(`跳过非序号文件：${fileName}`);
                        skippedCount++;
                    }
                }
            }
        });

        console.log('\n处理完成！');
        console.log(`- 处理的文件：${processedCount}`);
        console.log(`- 跳过的文件：${skippedCount}`);

    } catch (error) {
        console.error('处理过程中发生错误：', error);
        process.exit(1);
    }
}

// 运行脚本
if (require.main === module) {
    main();
} 