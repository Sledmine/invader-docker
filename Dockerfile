FROM archlinux:base
WORKDIR /home/invader
RUN useradd --shell=/bin/false build && usermod -L build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install build tools
# TODO Confirm "go" version required (go>=1.17)
RUN pacman -Sy && \
    pacman -S p7zip git base-devel fakeroot sudo go --noconfirm && \
    git clone http://aur.archlinux.org/yay-git.git && \
    chmod a+rwx ./yay-git && \
    mkdir -p /home/build/.cache && \
    chmod a+rwx /home/build/.cache
USER build
RUN cd yay-git && \
    makepkg -si --noconfirm
# Install invader
RUN yay -S invader-git --noconfirm