const fs = require('fs');
const path = require('path');
const file = path.join(__dirname, '..', 'swagger.json');
const data = JSON.parse(fs.readFileSync(file, 'utf8'));
const paths = Object.keys(data.paths).filter(k => k.startsWith('/api/DermaScan/'));
console.log(JSON.stringify(paths, null, 2));
for (const p of paths) {
  console.log('PATH', p);
  console.log(JSON.stringify(data.paths[p], null, 2).slice(0, 1200));
  console.log('---');
}
