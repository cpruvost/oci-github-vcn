const CORE = require('@actions/core');
// const GitHub = require('@actions/github');
const FS = require('fs');
const OS = require('os');
const Util = require('util');
const execSync = Util.promisify(require('child_process').execSync);

try {

  if(process.platform !== 'linux') {
    throw new Error('This action runs only on Linux currently');
  }

  const someInput = CORE.getInput('regionscript');
  CORE.debug(`Region Script Count : ${someInput}`)
  const mode = CORE.getInput('mode');
  CORE.debug(`Mode : ${mode}`)

  //Test with a simple script
  //execSync(`chmod +x ./some-bash-script.sh`);
  //execSync(`bash ./some-bash-script.sh ${someInput}`, {stdio: 'inherit'});

  if (mode.trim() === "ocicli")
  {
    execSync(`chmod +x ./ociresources.sh`);
    //execSync(`bash ./ociresources.sh ${someInput}`, {stdio: 'inherit'});
    execSync(`bash ./ociresources.sh`, {stdio: 'inherit'});
  }  
  else
  {
    execSync(`chmod +x ./ociresourcesrest.sh`);
    //execSync(`bash ./ociresourcesrest.sh ${someInput}`, {stdio: 'inherit'});
    execSync(`bash ./ociresourcesrest.sh`, {stdio: 'inherit'});
  }

  
} catch (error) {
  CORE.setFailed(error.message);
}