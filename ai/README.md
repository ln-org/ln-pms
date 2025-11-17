# LN-PMS AI 模块（轻量版 Prompt + LLM API）

本目录 `ln-pms/ai/` 是 LN-PMS 项目的 AI 扩展，只做「Prompt 设计 + 开源 LLM 调用」，不涉及微服务、复杂算法或本地模型。

## 🎯 目标

- 训练学生的 Prompt Engineering 能力：通过编写提示词解决「文档生成 / 评论助手 / NL→SQL」三个场景。
- 统一调用开源大模型：Qwen、DeepSeek、LLaMA、OpenLLM 等，只需一行配置即可切换。
- 保持与主应用解耦：AI 逻辑由轻量脚本完成，后端仅通过现有 API 传数据。

> ⚠️ 这里只需输出 Prompt + JSON，不要写模型、微服务或训练逻辑。 后端直接解析json 进行 API 调用。

---

## 📂 目录结构

```
ai/
├── prompts/           # 学生要编写或优化的 Prompt 模板（JSON）
│   ├── docs_gen.json
│   ├── comment_ai.json
│   └── nl2sql.json
├── api/               
├── samples/           # 可选：示例输入或脚本效果对照
└── README.md          # 当前文档（你正在读）
```

> 学生只动 `prompts/`， `api/` 里的 JSON。

---

## 📚 实验内容（Prompts 要实现的功能）

### 1️⃣ 项目文档智能生成（`prompts/docs_gen.json`）

让模型自动产出：

- 项目周报/ 月报（结构化 Markdown）
- 阶段进度总结（计划 vs 实际、延期风险）
- Deliverable 说明文档（成果、交付规范）
- Issue 汇总报告（问题分类 + 解决建议）

**示例片段**：

```json
{
  "weekly_report": {
    "prompt": "你是一个测绘项目经理，请根据以下项目数据生成本周报告，格式：\n# 标题\n## 进展\n## 风险\n## 下周计划\n项目数据：{{project_data}}",
    "model": "qwen2.5:7b"
  }
}
```

### 2️⃣ 智能评论助手（`prompts/comment_ai.json`）

Prompt 需支持：

- 评论摘要（提取关键观点、决策、待办）
- 回复建议（不同语气、直击痛点）
- 情感/紧急度分析
- 智能提醒（识别@、承诺、截止）

**示例片段**：

```json
{
  "summary": {
    "prompt": "总结这个项目的所有评论要点：\n{{comments}}",
    "model": "deepseek-chat"
  },
  "emotion": {
    "prompt": "判断以下文本情绪（平静/焦虑/紧急）：\n{{text}}",
    "model": "qwen2.5:1.8b"
  }
}
```

### 3️⃣ 自然语言查询（`prompts/nl2sql.json`）

Prompt 将自然语言转成 SQL：

- 支持基础查询（进行中项目、张三负责的项目）
- 支持聚合统计（每项目 Issue 数，季度完成数量）
- 可选：复杂查询（迟滞阶段、无交付成果、负责人）

**示例片段**：

```json
{
  "nl2sql": {
    "prompt": "请根据以下数据库结构生成 SELECT 语句：\n数据库：{{schema}}\n问题：{{query}}",
    "model": "llama3.1:8b"
  }
}
```

只需编辑 prompt 字段，确保逻辑清晰即可。

---

## 🧠 学生任务清单

1. ✅ 编辑 `prompts/*.json`，为每个场景设计高质量 Prompt。
2. ✅ 使用 `samples/` 中的输入（或自造数据）运行 `api/llm_client.py`，观察 LLM 输出。
3. ✅ 输出要求结构化（Markdown、JSON、列表等），方便项目后端解析。
4. ✅ 对于复杂需求，采用 Chain-of-Thought 分步 Prompt，并写清思路。
5. ✅ 提交 Prompt 说明：目标、模型、关键变量、预期格式。

> 不要修改 `llm_client.py`（除非老师授权），也不需写微服务；重点在 Prompt 质量。

---

## 🧪 评测标准（老师打分参考）

| 项目 | 得分比重 | 说明 |
|------|----------|------|
| Prompt 设计 | 40% | 是否能稳定输出规范结构；是否可读、易维护 |
| 功能效果 | 40% | 文档生成是否清晰、评论摘要有无关键点、NL→SQL 正确率 |
| JSON 组织 | 10% | 文件层级清晰，字段命名规范 |
| 文档说明 | 10% | 是否写清 Prompt 思路、模型选择、变量含义 |

---

## 🛠️ 使用说明

1. 准备 `prompts/*.json`，每个 Prompt 可包含 `prompt`、`model`、`temperature`、`format` 等字段。
2. 执行 `api/llm_client.py`（老师可直接调用、有命令行入口），示例：

```python
auth = {"api_key": "", "base_url": "http://127.0.0.1:11434/v1"}
prompt_cfg = load_json("prompts/docs_gen.json")["weekly_report"]
result = call_llm(prompt_cfg, {"project_data": "..."})
```

3. 检查 `samples/` 输出与预期结构是否一致。

---

## ⚙️ API 配置（JSON 数据驱动）

`api/llm_api_schema.json` 描述了调用开源模型的统一配置，后端可以直接读取并解析。
例如：

```json
{
  "client": {
    "endpoint": "${AI_LLM_BASE_URL}",
    "headers": {
      "Authorization": "Bearer ${AI_LLM_API_KEY}"
    },
    "body_template": {
      "model": "{{model}}",
      "messages": [
        {
          "role": "user",
          "content": "{{prompt}}"
        }
      ]
    }
  },
  "prompts_key": "prompts/*.json"
}
```

后端只需：

1. 读取该 JSON，拼接实际 `model`/`prompt`、变量；
2. 使用 HTTP 客户端（如 `RestTemplate` 或 `HttpClient`）向 `endpoint` 发起 POST；
3. 将 `body_template` 中的占位符替换为 `prompt_cfg` 的值；
4. 处理模型返回内容（目前只解析 `choices[0].message.content`）。

这样即便后端不是 Python 也能复用这个配置，只要遵守 JSON 模板即可。

---

## ✅ 提交内容

- `prompts/*.json`：Prompt 模板与配置。
- `samples/`：可选的示例输入/输出（Markdown、文本、SQL）。
- 文档：简单说明 Prompt 设计思路与测试命令。

请按照教师要求提交分支，命名如 `feature/ai-lab-{学号}`，并在 README 中附加测试说明。

---

> 祝你在 Prompt 设计实训中获得好成绩！如需使用不同模型，只需在 JSON 中修改 `model` 与 `base_url`，不涉及代码改动。
