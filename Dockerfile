# Stage 1: Byg curl-impersonate
FROM archlinux:latest AS builder

RUN pacman -Syu --noconfirm \
    git \
    base-devel \
    && pacman -Scc --noconfirm

RUN useradd -m builder && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN su builder -c "git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm"
RUN su builder -c "yay -S --noconfirm curl-impersonate"

# Stage 2: Det endelige image
FROM archlinux:latest

RUN pacman -Syu --noconfirm \
    python \
    python-flask \
    imagemagick \
    ghostscript \
    cups \
    jq \
    && pacman -Scc --noconfirm

# Kopiér kun curl-impersonate binaries fra builder
COPY --from=builder /usr/bin/curl* /usr/bin/

WORKDIR /app
COPY app.py mondaymandala.sh setup-printer.sh ./
COPY templates/ ./templates/
RUN chmod +x mondaymandala.sh setup-printer.sh

CMD ["./setup-printer.sh"]
