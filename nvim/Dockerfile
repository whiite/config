FROM alpine:latest

RUN apk add --no-cache neovim git build-base

# Create a group and user
RUN addgroup -S editorgroup && adduser -S editoruser -G editorgroup
USER editoruser
WORKDIR /home/editoruser/.config/nvim

# Copy config files
COPY ./init.lua .
COPY ./lua/ ./lua/
COPY ./lazy-lock.json .

# Sync plugins
RUN nvim --headless "+Lazy! sync" +qa

WORKDIR /home/editoruser
CMD [ "nvim" ]
