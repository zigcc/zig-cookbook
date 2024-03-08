#!/usr/bin/env node

const execSync = require("child_process").execSync;
const fs = require('fs');
const os = require('os');
const path = require('path');
const process = require('process');
const spawnSync = require('child_process').spawnSync;

function run(command) {
  console.log(command);
  let env = Object.assign({}, process.env);
  delete env.CI; // for Homebrew on macos-11.0
  execSync(command, {stdio: 'inherit', env: env});
}

function addToPath(newPath) {
  fs.appendFileSync(process.env.GITHUB_PATH, `${newPath}\n`);
}

// install
const mysqlVersion = '8.0';
const rootPass = '123';
const database = 'public';

// install
run(`brew install mysql@${mysqlVersion}`);

// start
const prefix = process.arch == 'arm64' ? '/opt/homebrew' : '/usr/local';
bin = `${prefix}/opt/mysql@${mysqlVersion}/bin`;
run(`${bin}/mysql.server start`);

// add user
run(`${bin}/mysql -e "CREATE USER '$USER'@'localhost' IDENTIFIED BY ''"`);
run(`${bin}/mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$USER'@'localhost'"`);
run(`${bin}/mysql -e "FLUSH PRIVILEGES"`);

// init
run(`${bin}/mysqladmin -proot password '${rootPass}'`);
run(`${bin}/mysqladmin create ${database}`);

// set path
addToPath(bin);
