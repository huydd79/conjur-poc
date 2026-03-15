FROM alpine:3.18

# 1. Install dependencies
RUN apk add --no-cache bash openssl curl

# 2. Install Summon core
RUN curl -sSL https://raw.githubusercontent.com/cyberark/summon/master/install.sh | bash

# 3. Install Summon-Conjur Provider
# We create the provider directory and download the binary
RUN mkdir -p /usr/local/lib/summon && \
    curl -sSL https://github.com/cyberark/summon-conjur/releases/latest/download/summon-conjur-linux-amd64.tar.gz \
    | tar -C /usr/local/lib/summon -xz

RUN mkdir -p /app /app/output
WORKDIR /app

COPY entrypoint.sh test.sh /app/
RUN chmod +x /app/entrypoint.sh /app/test.sh

ENTRYPOINT ["/app/entrypoint.sh"]