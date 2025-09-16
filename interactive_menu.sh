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
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}📋 使用说明:${NC}"
    echo -e "${GREEN}   ↑/↓ 箭头键 - 导航菜单${NC}"
    echo -e "${GREEN}   空格键     - 选择/取消选择项目${NC}"
    echo -e "${GREEN}   回车键     - 确认安装选择的项目${NC}"
    echo -e "${GREEN}   ESC键      - 退出程序${NC}"
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

# 绘制菜单
draw_menu() {
    clear_screen
    show_welcome

    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${CYAN}                        请选择要安装的服务                    ${NC}${BLUE}║${NC}"
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

# 安装 Nginx
install_nginx() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${YELLOW}🔧 开始安装 Nginx 服务器...${NC}"
    echo -e "${CYAN}================================${NC}"

    echo -e "${GREEN}✓ 更新包列表...${NC}"
    echo -e "${BLUE}  模拟命令: apt update${NC}"
    sleep 1

    echo -e "${GREEN}✓ 安装 Nginx...${NC}"
    echo -e "${BLUE}  模拟命令: apt install -y nginx${NC}"
    sleep 1

    echo -e "${GREEN}✓ 启动 Nginx 服务...${NC}"
    echo -e "${BLUE}  模拟命令: systemctl start nginx${NC}"
    sleep 1

    echo -e "${GREEN}✓ 设置开机自启...${NC}"
    echo -e "${BLUE}  模拟命令: systemctl enable nginx${NC}"
    sleep 1

    echo -e "${GREEN}✅ Nginx 安装完成！${NC}"
    echo -e "${YELLOW}   服务端口: 80 (HTTP), 443 (HTTPS)${NC}"
    echo -e "${YELLOW}   配置文件: /etc/nginx/nginx.conf${NC}"
    echo ""
}

# 安装 NginxUI
install_nginxui() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${YELLOW}🔧 开始安装 NginxUI 管理界面...${NC}"
    echo -e "${CYAN}================================${NC}"

    echo -e "${GREEN}✓ 检查依赖项...${NC}"
    echo -e "${BLUE}  模拟检查: Docker 环境${NC}"
    sleep 1

    echo -e "${GREEN}✓ 下载 NginxUI 镜像...${NC}"
    echo -e "${BLUE}  模拟命令: docker pull uozi/nginx-ui:latest${NC}"
    sleep 1

    echo -e "${GREEN}✓ 创建配置目录...${NC}"
    echo -e "${BLUE}  模拟命令: mkdir -p /etc/nginxui${NC}"
    sleep 1

    echo -e "${GREEN}✓ 启动 NginxUI 容器...${NC}"
    echo -e "${BLUE}  模拟命令: docker run -d --name nginxui -p 8080:80 uozi/nginx-ui${NC}"
    sleep 1

    echo -e "${GREEN}✅ NginxUI 安装完成！${NC}"
    echo -e "${YELLOW}   访问地址: http://your-server:8080${NC}"
    echo -e "${YELLOW}   默认用户: admin${NC}"
    echo -e "${YELLOW}   默认密码: admin${NC}"
    echo ""
}

# 安装 Docker
install_docker() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${YELLOW}🔧 开始安装 Docker 容器引擎...${NC}"
    echo -e "${CYAN}================================${NC}"

    echo -e "${GREEN}✓ 更新包列表...${NC}"
    echo -e "${BLUE}  模拟命令: apt update${NC}"
    sleep 1

    echo -e "${GREEN}✓ 安装依赖包...${NC}"
    echo -e "${BLUE}  模拟命令: apt install -y apt-transport-https ca-certificates curl gnupg lsb-release${NC}"
    sleep 1

    echo -e "${GREEN}✓ 添加 Docker GPG 密钥...${NC}"
    echo -e "${BLUE}  模拟命令: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor${NC}"
    sleep 1

    echo -e "${GREEN}✓ 添加 Docker 仓库...${NC}"
    echo -e "${BLUE}  模拟命令: add-apt-repository docker${NC}"
    sleep 1

    echo -e "${GREEN}✓ 安装 Docker Engine...${NC}"
    echo -e "${BLUE}  模拟命令: apt install -y docker-ce docker-ce-cli containerd.io${NC}"
    sleep 1

    echo -e "${GREEN}✓ 启动 Docker 服务...${NC}"
    echo -e "${BLUE}  模拟命令: systemctl start docker${NC}"
    sleep 1

    echo -e "${GREEN}✓ 设置开机自启...${NC}"
    echo -e "${BLUE}  模拟命令: systemctl enable docker${NC}"
    sleep 1

    echo -e "${GREEN}✅ Docker 安装完成！${NC}"
    echo -e "${YELLOW}   版本信息: docker --version${NC}"
    echo -e "${YELLOW}   用户组: usermod -aG docker \$USER${NC}"
    echo ""
}

# 执行安装
execute_installations() {
    local has_selection=false

    # 检查是否有选择的项目
    for i in "${!selected[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            has_selection=true
            break
        fi
    done

    if [ "$has_selection" = false ]; then
        clear_screen
        show_welcome
        echo -e "${RED}❌ 错误: 请至少选择一个要安装的服务！${NC}"
        echo ""
        echo -e "${PURPLE}按任意键返回菜单...${NC}"
        read -n 1 -s
        return
    fi

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

    # 显示欢迎界面和菜单
    show_welcome

    # 处理菜单交互
    if handle_menu; then
        # 用户按了回车，执行安装
        execute_installations
    else
        # 用户按了ESC，退出
        clear_screen
        echo -e "${GREEN}感谢使用 Linux 服务安装工具！${NC}"
        echo -e "${CYAN}再见！${NC}"
    fi

    show_cursor
}

# 运行主程序
main
