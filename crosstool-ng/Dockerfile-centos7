# 使用 CentOS 7 作为基础镜像
FROM centos:7

# --- 配置参数 ---
# 定义 crosstool-NG 的版本，方便后续修改
ARG CTNG_VERSION=1.28.0
# 为容器内的非 root 用户定义 UID 和 GID
ARG CTNG_UID=1000
ARG CTNG_GID=1000

# --- 环境变量 ---
# 将 crosstool-NG 的安装路径加入 PATH，这样 ct-ng 命令可以直接使用
ENV PATH=/opt/ctng/bin:$PATH

# --- 系统配置和依赖安装 ---
# 将所有安装步骤合并到一个 RUN 层，以减小镜像体积+


# ------------------[ EOL HOTFIX START ]------------------
# 1. 切换 CentOS 官方仓库指向 vault.centos.org
#    这是因为 CentOS 7 已 EOL，mirrorlist 不再工作
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://mirrors.aliyun.com/centos-vault|g' /etc/yum.repos.d/CentOS-* 

RUN yum install -y epel-release && \
    sed -i 's/metalink=/#metalink=/g' /etc/yum.repos.d/epel.repo && \
    sed -i 's|#baseurl=http://download.fedoraproject.org/pub/epel|baseurl=https://mirrors.aliyun.com/epel-archive|g' /etc/yum.repos.d/epel.repo 

RUN yum install -y \
        autoconf \
        automake \
        bison \
        bzip2 \
        file \
        flex \
        gcc-c++ \
        git \
        gperf \
        help2man \
        libtool \
        make \
        ncurses-devel \
        patch \
        perl-Thread-Queue \
        python36-devel \
        rsync \
        texinfo \
        unzip \
        wget \
        which \
        curl \
        xz && \
    yum clean all && \
    groupadd -g ${CTNG_GID} ctng && \
    useradd -d /home/ctng -m -g ${CTNG_GID} -u ${CTNG_UID} -s /bin/bash ctng && \
    wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 && \
    chmod a+x /sbin/dumb-init

# --- 安装 crosstool-NG ---
# 同样，将所有步骤合并到一个 RUN 层
RUN mkdir -p /opt/ctng-src/ && \
    curl -sL https://github.com/crosstool-ng/crosstool-ng/releases/download/crosstool-ng-${CTNG_VERSION}/crosstool-ng-${CTNG_VERSION}.tar.bz2 -o \
     /opt/ctng-src/crosstool-ng-${CTNG_VERSION}.tar.bz2 && \
    tar xf /opt/ctng-src/crosstool-ng-${CTNG_VERSION}.tar.bz2 -C /opt/ctng-src && \
    cd /opt/ctng-src/crosstool-ng-${CTNG_VERSION} && \
    ./bootstrap && \
    ./configure --prefix=/opt/ctng && \
    make && \
    make install && \
    cd / && \
    rm -rf /opt/ctng-src

# --- 容器默认配置 ---
# 设置默认工作目录
WORKDIR /home/ctng/work
# 切换到非 root 用户
USER ctng

# 使用 dumb-init 启动容器，并将 bash作为默认命令
ENTRYPOINT [ "/sbin/dumb-init", "--" ]
CMD [ "/bin/bash" ]