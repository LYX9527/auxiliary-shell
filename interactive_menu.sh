#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 隐藏光标
hide_cursor() {
    printf '\033[?25l'
}

# 显示光标
show_cursor() {
    printf '\033[?25h'
}

# 清屏
clear_screen() {
    clear
}

# 显示欢迎界面
show_welcome() {
    clear_screen
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}${YELLOW}                     Linux 服务安装工具                       ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GREEN}  版本: 0.0.1                                                 ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}  作者: @yltf https://github.com/LYX9527                      ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}  日期: $(date '+%Y-%m-%d')                                            ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}  适用: ubuntu 系统                                           ${NC}${CYAN}║${NC}"
    if [ -n "$SERVER_IP" ] && [ "$SERVER_IP" != "localhost" ]; then
        echo -e "${CYAN}║${PURPLE}  服务器IP: ${SERVER_IP}$(printf '%*s' $((41 - ${#SERVER_IP})) '')${NC}${CYAN}║${NC}"
    else
        echo -e "${CYAN}║${YELLOW}  服务器IP: 获取失败，请手动确认                               ${NC}${CYAN}║${NC}"
    fi
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}📋 使用说明:${NC}"
    echo -e "${GREEN}   ↑/↓ 箭头键 - 导航菜单${NC}"
    echo -e "${GREEN}   空格键     - 选择/取消选择项目${NC}"
    echo -e "${GREEN}   回车键     - 确认安装选择的项目${NC}"
    echo -e "${GREEN}   ESC键      - 退出程序${NC}"
    echo ""
    echo -e "${CYAN}🔧 支持的安装模式:${NC}"
    echo -e "${BLUE}   • 模拟模式 - 显示命令但不实际执行${NC}"
    echo -e "${BLUE}   • 真实模式 - 执行预制的安装步骤${NC}"
    echo ""
}

# 菜单选项
declare -a menu_options=(
    "Nginx 服务器"
    "NginxUI 管理界面"
    "Docker 容器引擎"
)

# 选择状态数组 (0=未选择, 1=已选择)
declare -a selected=(0 0 0)

# 当前光标位置
current_pos=0

# 获取服务器IP地址
SERVER_IP=""
get_server_ip() {
    echo -n "正在获取服务器IP地址..."
    SERVER_IP=$(curl -s --connect-timeout 5 https://ip.yltf.org 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$SERVER_IP" ]; then
        echo " 完成"
        return 0
    else
        echo " 失败，将使用localhost"
        SERVER_IP="localhost"
        return 1
    fi
}

# =============================================================================
# 预制安装步骤配置 (兼容bash 3.x)
# =============================================================================

# 通用依赖包命令
COMMON_DEPS_CMD="sudo apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring software-properties-common apt-transport-https"

# 获取步骤信息的函数
get_step_info() {
    local service="$1"
    local step_num="$2"
    local info_type="$3"  # desc, cmd, critical

    case "$service" in
        "nginx")
            case "$step_num" in
                1)
                    case "$info_type" in
                        "desc") echo "安装依赖包" ;;
                        "cmd") echo "sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                2)
                    case "$info_type" in
                        "desc") echo "下载并添加 Nginx GPG 密钥" ;;
                        "cmd") echo "curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                3)
                    case "$info_type" in
                        "desc") echo "验证 GPG 密钥" ;;
                        "cmd") echo "gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg" ;;
                        "critical") echo "false" ;;
                    esac
                    ;;
                4)
                    case "$info_type" in
                        "desc") echo "添加 Nginx 官方仓库" ;;
                        "cmd") echo "echo \"deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu \`lsb_release -cs\` nginx\" | sudo tee /etc/apt/sources.list.d/nginx.list" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                5)
                    case "$info_type" in
                        "desc") echo "更新包列表" ;;
                        "cmd") echo "sudo apt update" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                6)
                    case "$info_type" in
                        "desc") echo "安装 Nginx" ;;
                        "cmd") echo "sudo apt install nginx" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                7)
                    case "$info_type" in
                        "desc") echo "验证 Nginx 安装" ;;
                        "cmd") echo "nginx -v" ;;
                        "critical") echo "false" ;;
                    esac
                    ;;
            esac
            ;;
        "docker")
            case "$step_num" in
                1)
                    case "$info_type" in
                        "desc") echo "安装基础依赖包" ;;
                        "cmd") echo "apt-get install ca-certificates curl gnupg lsb-release" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                2)
                    case "$info_type" in
                        "desc") echo "安装额外依赖包" ;;
                        "cmd") echo "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                3)
                    case "$info_type" in
                        "desc") echo "下载并添加 Docker GPG 密钥" ;;
                        "cmd") echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                4)
                    case "$info_type" in
                        "desc") echo "添加 Docker 官方仓库" ;;
                        "cmd") echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                5)
                    case "$info_type" in
                        "desc") echo "更新包列表" ;;
                        "cmd") echo "sudo apt update" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                6)
                    case "$info_type" in
                        "desc") echo "安装 Docker CE" ;;
                        "cmd") echo "sudo apt install -y docker-ce docker-ce-cli containerd.io" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                7)
                    case "$info_type" in
                        "desc") echo "验证 Docker 安装" ;;
                        "cmd") echo "docker -v" ;;
                        "critical") echo "false" ;;
                    esac
                    ;;
                8)
                    case "$info_type" in
                        "desc") echo "启用 Docker 服务" ;;
                        "cmd") echo "sudo systemctl enable docker" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                9)
                    case "$info_type" in
                        "desc") echo "设置 Docker 配置环境" ;;
                        "cmd") echo "DOCKER_CONFIG=\${DOCKER_CONFIG:-\$HOME/.docker}" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                10)
                    case "$info_type" in
                        "desc") echo "创建 CLI 插件目录" ;;
                        "cmd") echo "mkdir -p \$DOCKER_CONFIG/cli-plugins" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                11)
                    case "$info_type" in
                        "desc") echo "下载 Docker Compose 插件" ;;
                        "cmd") echo "curl -SL https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64 -o \$DOCKER_CONFIG/cli-plugins/docker-compose" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                12)
                    case "$info_type" in
                        "desc") echo "显示配置目录路径" ;;
                        "cmd") echo "echo \$DOCKER_CONFIG" ;;
                        "critical") echo "false" ;;
                    esac
                    ;;
                13)
                    case "$info_type" in
                        "desc") echo "设置 Docker Compose 执行权限" ;;
                        "cmd") echo "chmod +x \$DOCKER_CONFIG/cli-plugins/docker-compose" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
                14)
                    case "$info_type" in
                        "desc") echo "验证 Docker Compose 安装" ;;
                        "cmd") echo "docker compose version" ;;
                        "critical") echo "false" ;;
                    esac
                    ;;
            esac
            ;;
        "nginxui")
            case "$step_num" in
                1)
                    case "$info_type" in
                        "desc") echo "执行 NginxUI 一键安装脚本" ;;
                        "cmd") echo "bash -c \"\$(curl -L https://cloud.nginxui.com/install.sh)\" @ install -r https://cloud.nginxui.com/" ;;
                        "critical") echo "true" ;;
                    esac
                    ;;
            esac
            ;;
    esac
}

# 定义每个服务的步骤数量
get_step_count() {
    case "$1" in
        "nginx") echo "7" ;;
        "docker") echo "14" ;;
        "nginxui") echo "1" ;;
        *) echo "0" ;;
    esac
}

# =============================================================================
# 安装执行函数
# =============================================================================

# 执行单个命令步骤
execute_step() {
    local desc="$1"
    local cmd="$2"
    local critical="$3"
    local simulate="${4:-true}"  # 默认模拟模式

    echo -e "${GREEN}✓ ${desc}...${NC}"

    if [ "$simulate" = "true" ]; then
        # 模拟模式 - 仅显示命令
        echo -e "${BLUE}  模拟命令: ${cmd}${NC}"
        sleep 1
        return 0
    else
        # 真实执行模式
        echo -e "${PURPLE}  执行命令: ${cmd}${NC}"

        # 执行命令
        if eval "$cmd" 2>/dev/null; then
            echo -e "${GREEN}    执行成功${NC}"
            return 0
        else
            echo -e "${RED}    执行失败${NC}"
            if [ "$critical" = "true" ]; then
                echo -e "${RED}❌ 关键步骤失败，安装中止！${NC}"
                return 1
            else
                echo -e "${YELLOW}⚠️  非关键步骤失败，继续安装...${NC}"
                return 0
            fi
        fi
    fi
}

# 通用安装函数
execute_service_installation() {
    local service_name="$1"
    local service_display_name="$2"
    local simulate="${3:-true}"  # 默认模拟模式

    echo -e "${CYAN}================================${NC}"
    echo -e "${YELLOW} 开始安装 ${service_display_name}...${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""

    # 获取步骤总数
    local total_steps=$(get_step_count "$service_name")

    # 执行所有步骤
    for ((i=1; i<=total_steps; i++)); do
        local desc=$(get_step_info "$service_name" "$i" "desc")
        local cmd=$(get_step_info "$service_name" "$i" "cmd")
        local critical=$(get_step_info "$service_name" "$i" "critical")

        # 执行步骤
        if ! execute_step "$desc" "$cmd" "$critical" "$simulate"; then
            return 1  # 如果关键步骤失败，退出安装
        fi
    done

    echo ""
    echo -e "${GREEN}✅ ${service_display_name} 安装完成！${NC}"

    # 显示服务特定的后续信息
    case "$service_name" in
        "nginx")
            echo -e "${YELLOW}   访问地址: http://${SERVER_IP} (端口80)${NC}"
            echo -e "${YELLOW}   HTTPS地址: https://${SERVER_IP} (端口443)${NC}"
            echo -e "${YELLOW}   配置文件: /etc/nginx/nginx.conf${NC}"
            echo -e "${YELLOW}   管理命令: sudo systemctl start|stop|restart nginx${NC}"
            ;;
        "docker")
            echo -e "${YELLOW}   Docker版本: docker -v${NC}"
            echo -e "${YELLOW}   Compose版本: docker compose version${NC}"
            echo -e "${YELLOW}   用户组: 注销重新登录后生效${NC}"
            echo -e "${YELLOW}   管理命令: sudo systemctl start|stop|restart docker${NC}"
            ;;
        "nginxui")
            echo -e "${YELLOW}   访问地址: http://${SERVER_IP}:9000${NC}"
            echo -e "${YELLOW}   配置文件: /usr/local/etc/nginx-ui/app.ini${NC}"
            echo -e "${YELLOW}   服务管理: systemctl start|stop|restart nginxui${NC}"
            echo -e "${YELLOW}   说明: 首次访问将引导设置管理员账号${NC}"
            ;;
    esac
    echo ""

    return 0
}

# 模式选择变量 (true=模拟模式, false=真实安装模式)
SIMULATE_MODE=true

# =============================================================================
# 查看预制安装步骤
# =============================================================================

# 显示某个服务的预制安装步骤
show_service_steps() {
    local service_name="$1"
    local service_display_name="$2"

    clear_screen
    show_welcome

    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${CYAN}                    ${service_display_name} 预制安装步骤                   ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"

    # 获取步骤总数
    local total_steps=$(get_step_count "$service_name")

    # 显示所有步骤
    for ((i=1; i<=total_steps; i++)); do
        local desc=$(get_step_info "$service_name" "$i" "desc")
        local cmd=$(get_step_info "$service_name" "$i" "cmd")
        local critical=$(get_step_info "$service_name" "$i" "critical")

        # 显示步骤
        local critical_mark=""
        if [ "$critical" = "true" ]; then
            critical_mark="${RED}[必需]${NC}"
        else
            critical_mark="${YELLOW}[可选]${NC}"
        fi

        echo -e "${BLUE}║${NC} ${GREEN}步骤 $i:${NC} $desc $critical_mark"
        echo -e "${BLUE}║${NC}   ${PURPLE}命令:${NC} $cmd"
        echo -e "${BLUE}║${NC}"
    done

    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${CYAN}总共 $total_steps 个安装步骤${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}[必需]${NC} 步骤失败将中止安装${NC}"
    echo -e "${BLUE}║${NC} ${YELLOW}[可选]${NC} 步骤失败将继续安装${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${PURPLE}按任意键返回...${NC}"
    read -n 1 -s
}

# 绘制菜单
draw_menu() {
    clear_screen
    show_welcome

    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${CYAN}                      请选择要安装的服务                      ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"

    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local checkbox=""
        local cursor=""
        local color=""

        # 设置复选框状态
        if [ "${selected[$i]}" -eq 1 ]; then
            checkbox="${GREEN}[✓]${NC}"
        else
            checkbox="${RED}[ ]${NC}"
        fi

        # 设置光标和颜色
        if [ "$i" -eq "$current_pos" ]; then
            cursor="${YELLOW}➤ ${NC}"
            color="${BOLD}${WHITE}"
        else
            cursor="  "
            color=""
        fi

        echo -e "${BLUE}${NC} ${cursor}${checkbox} ${color}${option}${NC}$(printf '%*s' $((48 - ${#option})) '')${BLUE}${NC}"
    done

    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${PURPLE}提示: 使用空格键选择项目，回车键开始安装${NC}                     ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# 读取键盘输入
read_key() {
    local key
    IFS= read -rsn1 key

    case "$key" in
        $'\033')  # ESC序列
            read -rsn2 key
            case "$key" in
                '[A') echo "UP" ;;
                '[B') echo "DOWN" ;;
                '[C') echo "RIGHT" ;;
                '[D') echo "LEFT" ;;
                *) echo "ESC" ;;
            esac
            ;;
        ' ') echo "SPACE" ;;
        '') echo "ENTER" ;;
        $'\x1b') echo "ESC" ;;
        q|Q) echo "QUIT" ;;
        *) echo "OTHER" ;;
    esac
}

# 处理菜单导航
handle_menu() {
    local menu_length=${#menu_options[@]}

    while true; do
        draw_menu
        local key=$(read_key)

        case "$key" in
            "UP")
                if [ "$current_pos" -gt 0 ]; then
                    current_pos=$((current_pos - 1))
                else
                    current_pos=$((menu_length - 1))
                fi
                ;;
            "DOWN")
                if [ "$current_pos" -lt $((menu_length - 1)) ]; then
                    current_pos=$((current_pos + 1))
                else
                    current_pos=0
                fi
                ;;
            "SPACE")
                if [ "${selected[$current_pos]}" -eq 1 ]; then
                    selected[$current_pos]=0
                    echo -e "${YELLOW}已取消选择: ${menu_options[$current_pos]}${NC}" >&2
                else
                    selected[$current_pos]=1
                    echo -e "${GREEN}已选择: ${menu_options[$current_pos]}${NC}" >&2
                fi
                sleep 0.2  # 短暂停顿显示反馈
                ;;
            "ENTER")
                return 0
                ;;
            "ESC")
                return 1
                ;;
        esac
    done
}

# 安装 Nginx (使用预制步骤)
install_nginx() {
    execute_service_installation "nginx" "Nginx 服务器" "$SIMULATE_MODE"
}

# 安装 NginxUI (使用预制步骤)
install_nginxui() {
    execute_service_installation "nginxui" "NginxUI 管理界面" "$SIMULATE_MODE"
}

# 安装 Docker (使用预制步骤)
install_docker() {
    execute_service_installation "docker" "Docker 容器引擎" "$SIMULATE_MODE"
}

# 显示选择确认
show_confirmation() {
    local has_selection=false
    local selected_items=()

    # 收集选中的项目
    for i in "${!selected[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            has_selection=true
            selected_items+=("${menu_options[$i]}")
        fi
    done

    if [ "$has_selection" = false ]; then
        clear_screen
        show_welcome
        echo -e "${RED}❌ 错误: 请至少选择一个要安装的服务！${NC}"
        echo ""
        echo -e "${PURPLE}按任意键返回菜单...${NC}"
        read -n 1 -s
        return 1
    fi

    clear_screen
    show_welcome

    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${YELLOW}                           安装确认                           ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${CYAN}您已选择安装以下服务:${NC}                                        ${BLUE}║${NC}"

    for item in "${selected_items[@]}"; do
        echo -e "${BLUE}${NC}   ${GREEN} ${item}${NC}$(printf '%*s' $((50 - ${#item})) '')${BLUE}${NC}"
    done

    echo -e "${BLUE}║${NC}                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${YELLOW}注意事项:${NC}                                                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   ${RED}• 安装过程需要管理员权限${NC}                                   ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   ${RED}• 请确保网络连接正常${NC}                                       ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   ${RED}• 安装可能需要几分钟时间${NC}                                   ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${PURPLE}安装模式选择:${NC}                                               ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}[1] 模拟安装 ${YELLOW}(仅显示命令，不实际执行)${NC}                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   ${RED}[2] 真实安装 ${YELLOW}(实际执行命令，需要sudo权限)${NC}               ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   ${CYAN}[0] 返回菜单${NC}                                              ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    while true; do
        echo -n -e "${BOLD}${YELLOW}请选择安装模式 [1/2/0]: ${NC}"
        read -n 1 choice
        echo ""

        case "$choice" in
            1)
                echo -e "${GREEN}✅ 选择模拟安装模式${NC}"
                SIMULATE_MODE=true
                sleep 1
                return 0
                ;;
            2)
                echo -e "${RED}✅ 选择真实安装模式 - 请确保有sudo权限！${NC}"
                SIMULATE_MODE=false
                sleep 1
                return 0
                ;;
            0)
                echo -e "${YELLOW}❌ 返回菜单...${NC}"
                sleep 1
                return 1
                ;;
            *)
                echo -e "${RED}⚠️  请输入 1、2 或 0${NC}"
                ;;
        esac
    done
}

# 执行安装
execute_installations() {

    clear_screen
    show_welcome
    echo -e "${BOLD}${GREEN}🚀 开始执行安装任务...${NC}"
    echo ""

    # 执行选中的安装任务
    for i in "${!selected[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            case $i in
                0) install_nginx ;;
                1) install_nginxui ;;
                2) install_docker ;;
            esac
        fi
    done

    echo -e "${BOLD}${GREEN}🎉 所有安装任务完成！${NC}"
    echo ""
    echo -e "${YELLOW}📝 安装总结:${NC}"
    for i in "${!selected[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            echo -e "${GREEN}  ✅ ${menu_options[$i]} - 安装成功${NC}"
        fi
    done
    echo ""
    echo -e "${PURPLE}按任意键退出程序...${NC}"
    read -n 1 -s
}

# 主程序
main() {
    # 设置终端
    hide_cursor
    trap 'show_cursor; exit' EXIT

    # 获取服务器IP地址
    get_server_ip

    # 显示欢迎界面和菜单
    show_welcome

    # 处理菜单交互
    while true; do
        if handle_menu; then
            # 用户按了回车，显示确认页面
            if show_confirmation; then
                # 用户确认安装，执行安装
                execute_installations
                break
            else
                # 用户取消安装，返回菜单
                continue
            fi
        else
            # 用户按了ESC，退出
            clear_screen
            echo -e "${GREEN}感谢使用 Linux 服务安装工具！${NC}"
            echo -e "${CYAN}再见！${NC}"
            break
        fi
    done

    show_cursor
}

# 运行主程序
main
