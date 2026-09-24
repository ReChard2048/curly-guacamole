前置知识点考核通过后解锁后继知识点，形如「二叉树 → 二叉排序树」。
当前为早期版本，知识点覆盖范围规划为 GESP-1 ～ NOIP。

当前版本：v3。版本号显示在页面左上角。变更知识点后请同步更新 tree.json 的 version 字段。

部署
本地： 执行 start.bat，依赖 Node.js。

不要直接打开 index.html。

无 Node 环境： 使用 知识树-单文件版.html，知识树与 45 个题库已全部内联，双击即可运行，可直接分发。

修改题库后需重新打包：

```bat
node tools/build-single.mjs
node tools/test-single.mjs
test-single.mjs 会校验单文件版是否为最新产物，过期会直接报错并给出命令。
```

单文件版约 300 KB，进度存储于浏览器 localStorage，跨设备不共享。

局域网访问
```bat
cd /d <你的目录>\knowledge-tree
start-lan.bat
```
控制台会输出 http://192.168.x.x:8099/ 形式的地址，同一子网内可直接访问。

仅在进程存活期间有效。

首次运行需在 Windows 防火墙放行 8099 端口。

不建议在公共网络下开启。

不加 lan 参数时仅监听 127.0.0.1。

分发文件夹： 直接发送 knowledge-tree 目录，对方双击 start.bat 即可运行，需对方具备 Node.js 环境。

该目录自带 serve.mjs 副本，无需上一级 tools/。

无 Node 环境时，start.bat 会给出提示，或改用单文件版。

new/ 为历史素材，bank/ 为生效题库，程序只读 bank/。

规则
权重 = 本次答对题数 / 本次题数，全对才记 100%。

节点达到 100% 后永久保持，子节点永久解锁（父子门槛，方案 A）。

通过一次后，该节点的 hidden 题库永久启用，后续可抽「visible + hidden」或「仅 hidden」，用于防止背题。

抽题优先选取「最近三轮未出现」的题目，与上一次不重复；选项顺序每次打乱（判断题固定为「正确 / 错误」）。

重考不限次数。重考未达 100% 不会回退已通过节点的权重。

进度存储于 localStorage，支持导出 / 导入。

gateMode
分类节点（如「编程基础」「控制结构」）若也计入门槛，会导致整棵树死锁。tree.json 中的 gateMode 控制该行为：

"transparent"（默认）：无题库节点不参与门槛判定，门禁上溯至最近的有题库祖先。分类节点在树中标记为「分类」。

"strict"：严格父子，每层均需考核，分类节点也需配置题库。

切换仅需修改 tree.json 中该字段，无需改动代码。

添加知识点
在 tree.json 的 children 中追加节点对象，id 全局唯一，并创建 bank/<id>.json。刷新页面即可生效，无需改动代码。

```jsonc
{
  "version": 1,
  "title": "CSP-J 知识树",
  "examSize": 10,          // 每次抽题数，节点可覆盖
  "passScore": 100,        // 通过线
  "gateMode": "transparent",
  "root": {
    "id": "basics-variables",
    "name": "变量与数据类型",
    "desc": "简介",
    "bank": "bank/basics-variables.json",   // 可省略，默认 bank/<id>.json
    "examSize": 10,                          // 可省略，继承顶层
    "children": [ /* 节点对象，可嵌套 */ ]
  }
}
```
题库格式
文件名必须严格等于 <节点 id>.json。
节点 id 为 ds-tree-lca，文件必须为 bank/ds-tree-lca.json。
命名不符时页面显示「题库待补」—— 程序仅按节点 id 检索。
node tools/check-bank.mjs 会直接报出正确文件名。

```jsonc
{
  "id": "basics-variables",
  "name": "变量与数据类型",
  "visible": [ /* 公开题，默认抽题范围 */ ],
  "hidden":  [ /* 隐藏题，通过后永久启用 */ ]
}
题型
jsonc
// 单选
{ "type": "single", "q": "题干", "options": ["A", "B", "C"], "answer": 1 }

// 多选，answer 为下标数组，全对才计分
{ "type": "multi", "q": "题干", "options": ["A", "B", "C"], "answer": [0, 2] }

// 判断，answer 支持 true / false / "T" / "F" / "对"
{ "type": "judge", "q": "题干", "answer": true }

// 程序阅读，代码放 code 字段，题干内也可写 ```cpp 围栏
{
  "type": "single",
  "q": "阅读以下程序，输出是？",
  "code": "int a = 7, b = 2;\ncout << a / b;",
  "options": ["3.5", "3", "4", "3.0"],
  "answer": 1,
  "explain": "两个 int 相除为整除。"
}
```
可选字段：id（用于「最近三轮未出现」的去重）、explain（结算解析）、code。
type 支持中文别名：单选 / 多选 / 判断。

出题建议
JSON 内换行写 \n，代码放 code 字段，避免转义。

每个知识点建议 visible ≥ 30、hidden ≥ 30。当前多数节点为 visible 10～20、hidden 5～10，「每次不重复」尚无法完全保证，优先补齐题量。

校验
题库：

bat
node tools/check-bank.mjs
扫描 tree.json 与全部题库，报告 JSON 语法错误、answer 下标越界、判断题 answer 类型错误、multi 的 answer 非数组、选项重复、题量不足等。改题库后建议执行。

程序本体：

bat
node tools/test-tree.mjs
以桩 DOM 执行 index.html 内实际脚本，覆盖加载态、抽题去重、判分、100% 解锁、hidden 启用、存档。每次请求注入 20ms 人工延迟，可检测加载顺序。退出码 0 为全过。改动 index.html 后执行。

启动流程
启动时扫描全部节点题库，判定哪些节点持有题库、哪些为分类节点 —— 门槛判定依赖该结果。

因此流程为「先扫描，后渲染」，扫描期间显示「正在读取题库…」。

不要改回先渲染：否则扫描完成前所有节点均被视为无题库，整棵树显示为「题库待补」且不上锁。

请求并发数为 8。本机实测：93 个请求串行 1154ms，并发 8 为 32ms。

常见问题
localhost 指向错误主机
localhost 指向本机。跨设备访问必须使用 start-lan.bat 输出的 192.168.x.x 地址。

Cannot find module ...\knowledge-tree\tools\serve.mjs
旧版缺少 knowledge-tree/serve.mjs。新版已内置该副本，文件夹可独立分发。

修改 start.bat / start-lan.bat
脚本内仅允许 ASCII 字符。cmd.exe 读取 UTF-8 批处理中的多字节字符时会按字节错位，截断命令行。中文提示统一由 serve.mjs 输出。换行必须为 CRLF，LF-only 会导致 goto 找不到标签。

目录结构
```text
knowledge-tree/
├── index.html                 # 程序本体
├── tree.json                  # 知识树结构
├── 知识树-单文件版.html        # 单文件产物
├── start.bat                  # 本机启动
├── start-lan.bat              # 局域网启动
├── serve.mjs                  # 静态服务（tools/serve.mjs 副本）
├── README.md
├── LICENSE                    # PolyForm Noncommercial 1.0.0
├── new/                       # 历史素材，非数据源
└── bank/
    ├── ds-tree-lca.json       # 文件名 = 节点 id
    └── ...
```
serve.mjs 存在两份：tools/serve.mjs 与 knowledge-tree/serve.mjs。修改其一后需同步另一份，diff tools/serve.mjs knowledge-tree/serve.mjs 可检查差异。

扩展
新增题型：在 index.html 的 qType / normalize / 渲染三处添加分支；未知 type 回退为单选。

通过线 / 题数：修改顶层 passScore、examSize，单节点可覆盖。

多棵树：重命名 tree.json，修改 index.html 中 loadTree() 的路径。

进度后端化：替换 loadProgress / saveProgress 两个函数。

tools/
check-bank.mjs —— 题库校验。

test-tree.mjs —— 程序本体自测（桩 DOM）。

build-single.mjs —— 单文件打包。

test-single.mjs —— 单文件离线自测 + 过期检查。

_kt-harness.mjs —— 测试共用桩 DOM，非命令行工具。

serve.mjs —— 本地静态服务。

node tools/serve.mjs 8099：仅本机

node tools/serve.mjs 8099 --lan：局域网，并输出可访问地址

--open：启动后自动打开浏览器

授权
PolyForm Noncommercial License 1.0.0，全文见 LICENSE。
