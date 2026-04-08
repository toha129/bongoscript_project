const express = require("express");
const fs = require("fs");
const { exec } = require("child_process");
const path = require("path");

const app = express();
app.use(express.json());
app.use(express.static(__dirname));

app.post("/compile", (req, res) => {
    // Ensure Unix-style line endings (LF) for the parser
    const code = req.body.code.replace(/\r\n/g, '\n');
    const userInput = (req.body.userInput || '').replace(/\r\n/g, '\n');
    fs.writeFileSync("input.txt", code + '\n');
    fs.writeFileSync("user_input.txt", userInput);

    // Step 1: Translate BongoScript -> C
    const translateCmd = 'cmd /c "banglish.exe < input.txt"';
    exec(translateCmd, { cwd: __dirname }, (err1) => {
        if (err1) {
            return res.status(500).send(`Translation Error: ${err1.message}`);
        }

        // Step 2: Compile output.c and run it via MSYS2 bash
        const bashPath = 'C:\\msys64\\usr\\bin\\bash.exe';
        const scriptPath = path.join(__dirname, 'compile_and_run.sh');
        exec(`"${bashPath}" -l "${scriptPath}"`, { cwd: __dirname, timeout: 10000 }, (err2, stdout, stderr) => {
            if (err2) {
                return res.status(500).send(`Error: ${stderr || err2.message}`);
            }
            res.send(stdout);
        });
    });
});

app.listen(3000, () => console.log("Server running on port 3000"));