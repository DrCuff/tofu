FROM alpine:3.20 AS tofu

RUN apk add -q curl git gpg gpg-agent

RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o /install-opentofu.sh

RUN chmod +x /install-opentofu.sh
RUN /install-opentofu.sh --install-method standalone --install-path / --symlink-path -

