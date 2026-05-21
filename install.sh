#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# install.sh — SDD 工作流 Skill 安装脚本
#
# 两种安装方式:
#   全局安装（推荐，一次安装到处可用）:
#     ./install.sh --global
#
#   项目内安装（含完整框架）:
#     ./install.sh                              # 安装 code_copilot/ 到当前项目
#     ./install.sh --sync --tool=opencode       # 同步 OpenCode 配置
#     ./install.sh --sync --all-tools           # 同步所有工具配置
# ============================================================================

VERSION="1.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "${BLUE}[STEP]${NC} $1"; }

INSTALL_MODE="project"
SYNC_TOOL=""
SYNC_ALL=false

for arg in "$@"; do
    case "$arg" in
        --global)   INSTALL_MODE="global" ;;
        --sync)     INSTALL_MODE="sync" ;;
        --all-tools) SYNC_ALL=true ;;
        --tool=*)   SYNC_TOOL="${arg#--tool=}" ;;
        --help|--usage)
            echo "SDD 工作流 Skill 安装脚本 v${VERSION}"
            echo ""
            echo "用法:"
            echo "  ./install.sh --global              # 全局安装（推荐）"
            echo "  ./install.sh                        # 项目内安装"
            echo "  ./install.sh --sync --tool=opencode # 同步 OpenCode 配置"
            echo "  ./install.sh --sync --all-tools     # 同步所有工具"
            echo ""
            echo "全局安装后:"
            echo "  1. Skills 复制到 ~/.config/opencode/skills/"
            echo "  2. 重启 OpenCode 后自动发现"
            echo "  3. 所有项目均可使用 skill open_spec 等命令"
            exit 0
            ;;
        --version)  echo "v${VERSION}"; exit 0 ;;
    esac
done

# ============================================================================
# 全局安装: 将 skills 安装到 ~/.config/opencode/skills/
# OpenCode 启动时自动扫描此目录，无需任何配置
# ============================================================================
install_global() {
    local global_dir="${HOME}/.config/opencode/skills"

    log_step "全局安装 SDD 工作流 Skills v${VERSION}..."
    log_info "目标: ${global_dir}/"

    mkdir -p "$global_dir"

    local count=0
    for skill_dir in "${TEMPLATE_DIR}/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
            local sname; sname=$(basename "$skill_dir")
            local target="${global_dir}/${sname}"
            mkdir -p "$target"
            if [[ -f "${skill_dir}SKILL.md" ]]; then
                cp "${skill_dir}SKILL.md" "${target}/SKILL.md"
                local sdesc; sdesc=$(grep '^description:' "${skill_dir}SKILL.md" 2>/dev/null | head -1 | sed 's/description: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' || echo "未知")
                log_info "  安装: ${sname} — ${sdesc}"
                ((count++))
            fi
        fi
    done

    echo ""
    log_info "全局安装完成! ${count} 个 Skills 已安装到:"
    echo "  ${global_dir}/"
    echo ""
    echo "重启 OpenCode 后即可使用:"
    echo "  skill open_setup   # 初始化项目"
    echo "  skill open_spec    # 创建变更提案"
    echo "  skill open_apply   # 执行编码"
    echo "  skill open_review  # 代码审查"
    echo "  skill open_debug   # 系统调试"
    echo "  skill open_archive # 归档归档"
}

# ============================================================================
# 项目内安装（原有逻辑，保持兼容）
# ============================================================================
install_project() {
    local PROJECT_DIR
    PROJECT_DIR="$(pwd)"
    local TARGET_DIR="code_copilot"

    log_step "安装 code_copilot 框架 v${VERSION} 到当前项目..."

    if [[ -d "$TARGET_DIR" ]]; then
        log_warn "${TARGET_DIR}/ 已存在，将保留已有文件（仅补充缺失文件）"
    fi

    mkdir -p "${TARGET_DIR}/rules"
    mkdir -p "${TARGET_DIR}/knowledge"
    mkdir -p "${TARGET_DIR}/agents"
    mkdir -p "${TARGET_DIR}/skills"
    mkdir -p "${TARGET_DIR}/changes/templates"
    mkdir -p "${TARGET_DIR}/archives"

    for f in "${TEMPLATE_DIR}/rules"/*.md; do
        local base; base=$(basename "$f")
        if [[ ! -f "${TARGET_DIR}/rules/${base}" ]]; then
            cp "$f" "${TARGET_DIR}/rules/${base}"
            log_info "  创建: ${TARGET_DIR}/rules/${base}"
        else
            log_info "  跳过: ${TARGET_DIR}/rules/${base}（已存在）"
        fi
    done

    if [[ ! -f "${TARGET_DIR}/knowledge/index.md" ]]; then
        cp "${TEMPLATE_DIR}/knowledge/index.md" "${TARGET_DIR}/knowledge/index.md"
        log_info "  创建: ${TARGET_DIR}/knowledge/index.md"
    fi

    for f in "${TEMPLATE_DIR}/agents"/*.md; do
        cp "$f" "${TARGET_DIR}/agents/"
        log_info "  更新: ${TARGET_DIR}/agents/$(basename "$f")"
    done

    for skill_dir in "${TEMPLATE_DIR}/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
            local sname; sname=$(basename "$skill_dir")
            mkdir -p "${TARGET_DIR}/skills/${sname}"
            if [[ -f "${skill_dir}SKILL.md" ]]; then
                cp "${skill_dir}SKILL.md" "${TARGET_DIR}/skills/${sname}/SKILL.md"
                log_info "  更新: ${TARGET_DIR}/skills/${sname}/SKILL.md"
            fi
        fi
    done

    for f in "${TEMPLATE_DIR}/changes/templates"/*.md; do
        cp "$f" "${TARGET_DIR}/changes/templates/"
        log_info "  更新: ${TARGET_DIR}/changes/templates/$(basename "$f")"
    done

    log_info "${TARGET_DIR}/ 安装完成"
}

# ============================================================================
# 同步: 从 code_copilot/ 生成指定工具配置
# ============================================================================
sync_single_tool() {
    local tool="$1"
    local TARGET_DIR="code_copilot"
    if [[ ! -d "$TARGET_DIR" ]]; then
        log_error "${TARGET_DIR}/ 不存在，请先运行 ./install.sh（无参数）安装框架"
        exit 1
    fi
    local PROJECT_DIR
    PROJECT_DIR="$(pwd)"
    local project_name
    project_name=$(basename "$PROJECT_DIR")

    case "$tool" in
        claude)
            {
                echo "# ${project_name} — AI 协作指南"
                echo ""
                echo "## Skill 工作流"
                echo ""
                echo "| 命令 | 说明 |"
                echo "|------|------|"
                for skill_file in "${TARGET_DIR}/skills"/*.md; do
                    if [[ -f "$skill_file" ]]; then
                        local sname; sname=$(basename "$skill_file" .md)
                        local sdesc; sdesc=$(grep '^description:' "$skill_file" 2>/dev/null | head -1 | sed 's/description: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' || echo "")
                        echo "| \`/${sname}\` | ${sdesc} |"
                    fi
                done
                echo ""
                echo "## 规则（始终生效）"
                echo ""
                for rule_file in "${TARGET_DIR}/rules"/*.md; do
                    [[ -f "$rule_file" ]] && echo "- @${rule_file}"
                done
                echo ""
                echo "## 知识库"
                echo ""
                echo "- @${TARGET_DIR}/knowledge/index.md"
                echo ""
                if [[ -d "${TARGET_DIR}/changes" ]] && find "${TARGET_DIR}/changes" -maxdepth 1 -mindepth 1 -type d ! -name templates 2>/dev/null | grep -q .; then
                    echo "## 进行中的变更"
                    echo ""
                    find "${TARGET_DIR}/changes" -maxdepth 1 -mindepth 1 -type d ! -name templates 2>/dev/null | while read -r d; do
                        echo "- @${d}/spec.md"
                    done
                fi
            } > CLAUDE.md
            log_info "  生成: CLAUDE.md"

            mkdir -p .claude/rules .claude/skills
            rm -f .claude/rules/*.md .claude/skills/*.md 2>/dev/null || true
            rm -rf .claude/skills/*/ 2>/dev/null || true
            cp "${TARGET_DIR}/rules"/*.md .claude/rules/ 2>/dev/null || true
            for skill_dir in "${TARGET_DIR}/skills"/*/; do
                if [[ -d "$skill_dir" ]]; then
                    local sname; sname=$(basename "$skill_dir")
                    mkdir -p ".claude/skills/${sname}"
                    if [[ -f "${skill_dir}SKILL.md" ]]; then
                        cp "${skill_dir}SKILL.md" ".claude/skills/${sname}/SKILL.md"
                    fi
                fi
            done
            log_info "  生成: .claude/rules/ + .claude/skills/"
            ;;

        opencode)
            # 生成 .opencode/skills/ 目录（OpenCode 原生 skill 系统）
            mkdir -p .opencode/skills
            rm -rf .opencode/skills/* 2>/dev/null || true
            for skill_dir in "${TARGET_DIR}/skills"/*/; do
                if [[ -d "$skill_dir" ]]; then
                    local sname; sname=$(basename "$skill_dir")
                    mkdir -p ".opencode/skills/${sname}"
                    if [[ -f "${skill_dir}SKILL.md" ]]; then
                        cp "${skill_dir}SKILL.md" ".opencode/skills/${sname}/SKILL.md"
                        log_info "  生成: .opencode/skills/${sname}/SKILL.md"
                    fi
                fi
            done

            # 生成/更新 opencode.json（确保 skills 路径被注册）
            local oc_json="opencode.json"
            if [[ ! -f "$oc_json" ]]; then
                cat > "$oc_json" <<-JSONEOF
{
  "\$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": [".opencode/skills"]
  }
}
JSONEOF
                log_info "  生成: ${oc_json}（含 skills 路径注册）"
            else
                # 已有 opencode.json，确保 skills.paths 包含 .opencode/skills
                if ! grep -q '".opencode/skills"' "$oc_json" 2>/dev/null; then
                    log_warn "${oc_json} 已存在但未包含 .opencode/skills 路径，请手动添加"
                fi
            fi

            # 生成 AGENTS.md（引用 rules 和 skills）
            {
                echo "# ${project_name} — AI 协作指南"
                echo ""
                echo "## 规则（始终生效）"
                echo ""
                for rule_file in "${TARGET_DIR}/rules"/*.md; do
                    [[ -f "$rule_file" ]] && cat "$rule_file" && echo -e "\n---\n"
                done
                echo ""
                echo "## 可用 Skill"
                echo ""
                echo "使用 skill 工具加载以下 skill："
                echo ""
                for skill_dir in "${TARGET_DIR}/skills"/*/; do
                    if [[ -d "$skill_dir" ]]; then
                        local sname; sname=$(basename "$skill_dir")
                        if [[ -f "${skill_dir}SKILL.md" ]]; then
                            local sdesc; sdesc=$(grep '^description:' "${skill_dir}SKILL.md" 2>/dev/null | head -1 | sed 's/description: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' || echo "")
                            echo "- \`${sname}\` — ${sdesc}"
                        fi
                    fi
                done
            } > AGENTS.md
            log_info "  生成: AGENTS.md + opencode.json + .opencode/skills/"
            ;;

        cursor)
            mkdir -p .cursor/rules
            {
                for rule_file in "${TARGET_DIR}/rules"/*.md; do
                    [[ -f "$rule_file" ]] && cat "$rule_file" && echo -e "\n---\n"
                done
            } > ".cursor/rules/project-rules.md"
            {
                for skill_dir in "${TARGET_DIR}/skills"/*/; do
                    if [[ -d "$skill_dir" ]] && [[ -f "${skill_dir}SKILL.md" ]]; then
                        cat "${skill_dir}SKILL.md" && echo -e "\n---\n"
                    fi
                done
            } > ".cursor/rules/workflow.md"
            log_info "  生成: .cursor/rules/"
            ;;

        copilot)
            mkdir -p .github
            {
                echo "# AI 编码指令"
                echo ""
                for rule_file in "${TARGET_DIR}/rules"/*.md; do
                    if [[ -f "$rule_file" ]] && grep -q 'alwaysApply: true' "$rule_file" 2>/dev/null; then
                        sed '/^---$/,/^---$/d' "$rule_file"
                        echo -e "\n---\n"
                    fi
                done
            } > ".github/copilot-instructions.md"
            log_info "  生成: .github/copilot-instructions.md"
            ;;

        *)
            log_error "未知工具: ${tool}，支持: claude, opencode, cursor, copilot"
            exit 1
            ;;
    esac
}

sync_tool_configs() {
    log_step "同步工具配置..."

    if [[ "$SYNC_ALL" == true ]]; then
        sync_single_tool "claude"
        sync_single_tool "opencode"
        sync_single_tool "cursor"
        sync_single_tool "copilot"
        log_info "所有工具配置已同步"
    elif [[ -n "$SYNC_TOOL" ]]; then
        sync_single_tool "$SYNC_TOOL"
    else
        log_warn "未指定工具，使用 --tool=claude|cursor|opencode|copilot 或 --all-tools"
        log_info "  示例: ./install.sh --sync --tool=claude"
        log_info "        ./install.sh --sync --all-tools"
    fi
}

# ============================================================================
# 主流程
# ============================================================================
echo ""
echo "=================================="
echo "  SDD 工作流 Skills v${VERSION}"
echo "=================================="
echo ""

case "$INSTALL_MODE" in
    global)
        install_global
        ;;
    project)
        install_project
        echo ""
        log_info "项目内安装完成!"
        echo ""
        echo "  code_copilot/    框架目录（单一事实来源）"
        echo ""
        log_warn "下一步:"
        echo "  1. 在 AI 工具中执行 open_setup 让 AI 扫描代码填充 rules/"
        echo "  2. 使用 open_spec 开始第一个需求"
        echo ""
        echo "  生成工具配置（可选）:"
        echo "    ./install.sh --sync --tool=opencode   # AGENTS.md + .opencode/skills/"
        echo "    ./install.sh --sync --tool=claude     # CLAUDE.md + .claude/"
        echo "    ./install.sh --sync --all-tools       # 全部生成"
        echo ""
        echo "  全局安装（推荐，一次安装到处可用）:"
        echo "    ./install.sh --global"
        echo ""
        echo "  可用 Skill:"
        echo "    open_setup    — 分析项目，填充 rules/"
        echo "    open_spec     — 创建变更提案（自动评估复杂度）"
        echo "    open_apply    — 按 Spec 逐步执行编码"
        echo "    open_review   — 两阶段审查 + 修正循环"
        echo "    open_archive  — 归档 + 知识沉淀"
        echo "    open_debug    — 系统化调试流程"
        ;;
    sync)
        sync_tool_configs
        echo ""
        log_info "同步完成!"
        ;;
esac
