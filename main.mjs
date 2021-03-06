import { Farmbot } from 'farmbot';
import atob from "atob";
import { readFileSync } from 'fs';

global.atob = atob;

function readFile(path) {
  return new TextDecoder().decode(readFileSync(path)).trim();
}

const token = readFile("./token");
const fb = new Farmbot({ token });
await fb.connect();
fb
  .lua(readFile(process.argv[2]))
  .then(() => process.exit(0), () => process.exit(1));
