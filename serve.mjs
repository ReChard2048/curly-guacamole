// 极简静态文件服务器：给知识树这种「html + fetch json」的页面用
//
// 用法:
//   node tools/serve.mjs                    # 只有自己这台机器能开（默认，最安全）
//   node tools/serve.mjs 8099               # 换端口
//   node tools/serve.mjs 8099 --lan         # 同一个局域网里的别人也能开
//   node tools/serve.mjs 8099 knowledge-tree --lan
//
// 不给目录参数时：旁边有 index.html 就用当前目录（在 knowledge-tree 里直接跑也行），
// 否则当成工作区根、服务 ./knowledge-tree。
//
// 默认只听 127.0.0.1（本机回环），别人的电脑连不上。
// 加了 --lan 才会听 0.0.0.0，局域网里任何人都能访问 —— 只在自己家的网络里用。
import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import { existsSync } from "node:fs";
import { networkInterfaces } from "node:os";
import { spawn } from "node:child_process";
import { extname, join, normalize, resolve, sep } from "node:path";

const argv = process.argv.slice(2);
const lan = argv.includes("--lan");
const open = argv.includes("--open");
const positional = argv.filter((a) => !a.startsWith("--"));
const port = Number(positional[0] || 8099);
const rootDir = resolve(positional[1] || (existsSync("index.html") ? "." : "knowledge-tree"));

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".webp": "image/webp",
  ".ico": "image/x-icon",
  ".txt": "text/plain; charset=utf-8",
  ".md": "text/markdown; charset=utf-8",
};

const server = createServer(async (req, res) => {
  try {
    const url = new URL(req.url, "http://localhost");
    let rel = decodeURIComponent(url.pathname);
    if (rel.endsWith("/")) rel += "index.html";
    const target = resolve(join(rootDir, normalize(rel)));
    if (target !== rootDir && !target.startsWith(rootDir + sep)) {
      res.writeHead(403).end("403");
      return;
    }
    const info = await stat(target);
    if (info.isDirectory()) {
      res.writeHead(302, { location: rel + "/" }).end();
      return;
    }
    const body = await readFile(target);
    res.writeHead(200, {
      "content-type": MIME[extname(target).toLowerCase()] || "application/octet-stream",
      "cache-control": "no-store",
    });
    res.end(body);
  } catch (err) {
    res.writeHead(err && err.code === "ENOENT" ? 404 : 500, { "content-type": "text/plain; charset=utf-8" });
    res.end(err && err.code === "ENOENT" ? "404 not found" : "500 " + err.message);
  }
});

// 找出局域网地址，好把能给别人用的 URL 打出来
// 跳过回环、回环内部的 IPv6，以及 169.254.* （自动分配地址，别人连不上）
function lanAddresses() {
  const out = [];
  for (const list of Object.values(networkInterfaces())) {
    for (const ni of list || []) {
      if (ni.family !== "IPv4" || ni.internal) continue;
      if (ni.address.startsWith("169.254.")) continue;
      out.push(ni.address);
    }
  }
  return out;
}

const host = lan ? "0.0.0.0" : "127.0.0.1";

server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    console.error(`端口 ${port} 已经被占用了。换个端口：node tools/serve.mjs ${port + 1}`);
  } else {
    console.error("起不来：" + err.message);
  }
  process.exit(1);
});

server.listen(port, host, () => {
  const localUrl = `http://localhost:${port}/`;
  console.log(`正在服务 ${rootDir}`);
  console.log(`  自己开：   ${localUrl}`);
  if (lan) {
    const addrs = lanAddresses();
    if (addrs.length) {
      console.log(`  给别人开（同一个 WiFi / 局域网）：`);
      for (const a of addrs) console.log(`             http://${a}:${port}/`);
      console.log(`  注意：Windows 防火墙第一次可能会弹窗，要选「允许访问」。`);
      console.log(`  这个地址只在你这台机器开着服务时有效，关掉窗口就没了。`);
    } else {
      console.log(`  没找到局域网地址 —— 可能没连 WiFi 或网线。`);
    }
  } else {
    console.log(`  现在是「只听本机」模式，别人的电脑打不开。`);
    console.log(`  要让同一个局域网里的人也能开，把窗口里的命令加上 --lan。`);
  }
  console.log(`\n关掉这个窗口服务就停了。`);

  if (open) {
    // 双击 .bat 的人希望页面自己弹出来。用独立的 shell 打开，不阻塞这边
    try {
      if (process.platform === "win32") {
        spawn("cmd", ["/c", "start", "", localUrl], { detached: true, stdio: "ignore", windowsHide: true }).unref();
      } else if (process.platform === "darwin") {
        spawn("open", [localUrl], { detached: true, stdio: "ignore" }).unref();
      } else {
        spawn("xdg-open", [localUrl], { detached: true, stdio: "ignore" }).unref();
      }
      console.log(`已尝试打开浏览器。没弹出来的话，手动开 ${localUrl}`);
    } catch (e) {
      console.log(`自动开浏览器失败了（${e.message}）。手动开 ${localUrl} 就行。`);
    }
  }
});
