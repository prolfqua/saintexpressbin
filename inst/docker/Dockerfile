FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends libc6 libstdc++6 && \
    rm -rf /var/lib/apt/lists/*
COPY SAINTexpress-spc SAINTexpress-int /usr/local/bin/
RUN chmod +x /usr/local/bin/SAINTexpress-spc /usr/local/bin/SAINTexpress-int
