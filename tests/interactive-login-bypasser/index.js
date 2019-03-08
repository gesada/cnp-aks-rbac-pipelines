const puppeteer = require("puppeteer-core");
const debug = require("debug")("node:tests");
const { spawn } = require("child_process");

if (process.argv.length !== 3) {
  process.exit(1);
}

const credentialsPath = process.argv[2];
const credentials = require(credentialsPath);

const kubeCtl = spawn("kubectl", ["get", "pods"]);

const signInMessage =
  "To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code";

kubeCtl.stdout.on("data", data => {
  debug(`stdout: ${data}`);
});

kubeCtl.stderr.on("data", async data => {
  let page, browser;

  debug(`kubectl output: ${data}`);

  if (!data.toString().includes(signInMessage)) {
    return;
  }

  const code = data
    .toString()
    .split("code")[1]
    .substring(1, 10);

  try {
    const browserEndpoint = "ws://localhost:3000";

    debug(`${browserEndpoint}`);

    browser = await puppeteer.connect({
      browserWSEndpoint: browserEndpoint
    });

    page = await browser.newPage();

    await page.goto(`https://microsoft.com/devicelogin`, {
      waitUntil: "domcontentloaded"
    });

    await page.click("#code");
    await page.keyboard.type(code);
    await page.waitFor(2000);
    await page.click("#continueBtn");
    await page.waitFor(2000);
    // await page.click("#otherTileText");
    // await page.waitFor(2000);
    await page.click("input[type=email]");
    await page.waitFor(2000);
    await page.keyboard.type(credentials.email);
    await page.waitFor(1000);
    await page.click("#idSIButton9");
    await page.waitFor(1000);
    await page.click("input[type=password]");
    await page.waitFor(1000);
    await page.keyboard.type(credentials.password);
    await page.waitFor(1000);
    await page.click("#idSIButton9");
  } catch (err) {
    console.error(err);
  }
});

kubeCtl.on("close", code => {
  debug(`child process exited with code ${code}`);
  process.exit(code);
});
