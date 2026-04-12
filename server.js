const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const fs = require("fs");
const { exec, spawn } = require("child_process");
const path = require("path");

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static(__dirname));

const BASH = "C:\\msys64\\usr\\bin\\bash.exe";
const PROJECT = "/f/bongoscript_project";

io.on("connection", (socket) => {
    let proc = null;
    let killTimer = null;

    socket.on("run", (data) => {
        // Kill any previous process
        if (proc) { proc.kill(); proc = null; }
        clearTimeout(killTimer);

        const code = (data.code || "").replace(/\r\n/g, "\n");
        fs.writeFileSync("input.txt", code + "\n");

        // Step 1: Transpile BongoScript -> C
        const translateCmd = 'cmd /c "banglish.exe < input.txt"';
        exec(translateCmd, { cwd: __dirname }, (err1, stdout1, stderr1) => {
            const translationOutput = (stdout1 || "") + (stderr1 || "");

            // Check if output.c was actually generated/updated
            if (err1) {
                socket.emit("output", `Translation Error: ${err1.message}`);
                socket.emit("done", 1);
                return;
            }

            // Check if output.c exists and has content
            try {
                const outputC = fs.readFileSync(path.join(__dirname, "output.c"), "utf8");
                if (!outputC.trim()) {
                    socket.emit("output", "Translation Error: Generated C code is empty.");
                    socket.emit("done", 1);
                    return;
                }
                // Send generated C code to UI
                socket.emit("ccode", outputC);
            } catch (e) {
                socket.emit("output", "Translation Error: output.c not found.");
                socket.emit("done", 1);
                return;
            }

            // Step 2: Compile with GCC via MSYS2
            const compileCmd = `"${BASH}" -lc "cd ${PROJECT} && gcc output.c -o runme.exe 2>&1"`;
            exec(compileCmd, { cwd: __dirname, timeout: 10000 }, (err2, stdout2) => {
                if (err2) {
                    socket.emit("output", `Compile Error:\n${stdout2 || err2.message}`);
                    socket.emit("done", 1);
                    return;
                }

                // Step 3: Run interactively through bash so MSYS2 handles stdin properly
                socket.emit("started");

                proc = spawn(BASH, ["-c", `cd ${PROJECT} && ./runme.exe`], {
                    cwd: __dirname,
                    stdio: ["pipe", "pipe", "pipe"],
                    env: { ...process.env, MSYS_NO_PATHCONV: "1" }
                });

                // 30s timeout
                killTimer = setTimeout(() => {
                    if (proc) {
                        proc.kill();
                        socket.emit("output", "\n[Timed out after 30s]");
                        socket.emit("done", 1);
                    }
                }, 30000);

                proc.stdout.on("data", (chunk) => {
                    socket.emit("output", chunk.toString());
                });

                proc.stderr.on("data", (chunk) => {
                    socket.emit("output", chunk.toString());
                });

                proc.on("close", (exitCode) => {
                    clearTimeout(killTimer);
                    proc = null;
                    socket.emit("done", exitCode || 0);
                });

                proc.on("error", (err) => {
                    clearTimeout(killTimer);
                    proc = null;
                    socket.emit("output", `Runtime Error: ${err.message}`);
                    socket.emit("done", 1);
                });
            });
        });
    });

    socket.on("input", (text) => {
        if (proc && proc.stdin.writable) {
            proc.stdin.write(text + "\n");
        }
    });

    socket.on("kill", () => {
        if (proc) {
            clearTimeout(killTimer);
            proc.kill();
            proc = null;
            socket.emit("output", "\n[Terminated]");
            socket.emit("done", 1);
        }
    });

    socket.on("disconnect", () => {
        clearTimeout(killTimer);
        if (proc) { proc.kill(); proc = null; }
    });
});

server.listen(3000, () => console.log("Server running on port 3000"));