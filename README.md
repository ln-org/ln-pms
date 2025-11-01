# LN-PMS

面向测绘/地理信息领域的项目管理系统

---

## 目录结构

LN-PMS

``` bash
ln-pms/
├─ api/         # 后端(Java 21 + Spring Boot 3.? + JPA）
├─ web/         # 前端()
├─ db/          # 数据库构建与迁移(Postgre17.6 + Flyway)
├─ docker/      # 仅容器化 PostgreSQL + Flyway
├─ storage/     # 非结构化数据存储(还没决定用什么)
└─ docs/        # 设计文档与架构说明
```

---

## 主要功能

LN-PMS 的结构与 GitHub 类似：
* **Project(项目)**：相当于仓库（Repo），管理项目基本信息、进度与负责人
* **Stage(阶段)**：相当于Milestone, 对应项目阶段（外业、内业、质检、交付）
* **Issue(问题)**：记录外业/内业问题、风险与处理状态
* **Comment(讨论)**：问题处理过程与附件记录，形成时间线
* **Deliverable(成果)**：项目成果与交付记录（报告、影像、数据等）

---

## 部署模式概述

* **数据库**：仅 DB 容器 + 用 Flyway 临时容器做独立迁移
* **后端 / 前端**：本机运行开发，生产可独立部署
* **非结构化数据**：待定

