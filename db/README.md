# 数据库设计（轻量版）

面向 Flyway `V1__init.sql` 的最小可用模型，全部对象放在 `core` schema 中，方便后续拆分成 `analytics`、`logs` 等子域。当前目标是“先跑通项目管理主流程，再为扩展留挂点”。

## 实体速览

| 实体 | 作用 | 关键字段 | 未来扩展位 |
| --- | --- | --- | --- |
| `core.users` | 平台账户 | `email`、`display_name`、`is_active`、`created_at` | 可追加职务、手机号、MFA、公钥等 |
| `core.projects` | 项目主档 | `code`、`name`、`status(project_status)`、计划/实际时间、`created_by` | 增补地理范围（PostGIS）、预算、外部系统 ID |
| `core.project_members` | 项目成员+角色 | `project_id`、`user_id`、`role(member_role)` | 扩充权限模型或链接组织/团队 |
| `core.project_stages` | 项目阶段（外业/内业/质检/交付等） | `project_id`、`name`、`sequence`、`status(stage_status)`、计划/实际时间、`lead_id` | 挂指标 JSONB、阶段模板 |
| `core.issues` | 问题/风险 | `project_id`、`stage_id`(可空)、`title`、`type(issue_type)`、`status(issue_status)`、`assignee_id` | 引入地理坐标、关联交付物、订阅者 |
| `core.issue_comments` | 问题讨论 | `issue_id`、`author_id`、`body`、`attachments_token` | 富文本、@mention、审核流 |
| `core.deliverables` | 成果记录 | `project_id`、`stage_id`、`category`、`storage_path`、`status(deliverable_status)` | 版本树、签署信息、评审表 |
| `core.attachments` | 二进制文件索引 | `id`、`bucket`、`object_path`、`checksum` | 统一被评论、成果等复用，后续接入 OSS/S3 |

> 说明：最小版本里只需要 `users`、`projects`、`project_members`、`project_stages`、`issues`、`issue_comments`。`deliverables` / `attachments` 可以先建空表或在下一版迁移补齐，但结构设计好让后端联调时不需要推翻。

## 设计要点

- **枚举化状态/类型**：`project_status`、`stage_status`、`issue_status`、`deliverable_status`、`issue_type`、`member_role` 使用 Postgres ENUM，避免自由文本带来的拼写漂移。
- **时间与审计**：所有主表都带 `created_at` / `updated_at`，后续可加触发器维护；如需审计，可平行建立 `core.audit_events`。
- **乐观锁**：给 `projects`、`issues` 预留 `version INT DEFAULT 0` 字段，后端可按需启用。
- **JSONB 扩展槽**：`project_stages.extra`, `issues.metadata` 之类字段让业务特化无需立刻改表。
- **附件引用**：`issue_comments.attachments_token` 仅存引用 ID，真正的文件索引集中在 `core.attachments`，保证未来成果/评论共用一套存储。
- **动态负责人**：不在 `projects` 表上固化 `owner_id`，而是通过 `project_members` 中的 `role = 'owner'`（或其他命名）表示负责人，可同时存在多人并保留历史记录。

## 枚举定义

| 枚举 | 取值 | 说明 |
| --- | --- | --- |
| `core.project_status` | `draft` / `active` / `completed` | 最精简的项目生命周期 |
| `core.stage_status` | `pending` / `in_progress` / `done` | 阶段推进状态 |
| `core.issue_type` | `task` / `risk` | 最常用的两类事项 |
| `core.issue_status` | `open` / `in_progress` / `closed` | 基础处理节点 |
| `core.deliverable_status` | `draft` / `submitted` / `approved` | 成果交付基础流程 |
| `core.member_role` | `owner` / `member` | 负责人 + 普通成员，后续可扩展 |

## 下一步演进建议

1. **阶段模板**：新增 `core.stage_templates` + `core.project_stage_templates`，先定义“外业→内业→质检→交付”默认序列。
2. **Deliverables/Reviews**：补 `core.deliverable_reviews`，支持质检结论、签字与版本追踪。
3. **PostGIS 支持**：当需要记录测区、多边形或点位时，在 `issues`/`projects` 上添加 `geometry` 字段并启用 `postgis` 扩展。
4. **组织/租户**：若要多团队共用，增加 `core.organizations`、`organization_members` 并在 `projects` 上挂外键。

该 README 将随着每个 Flyway 迁移更新，保持“模型说明 ⇄ SQL 实现”同步，方便后续评审与文档化。
