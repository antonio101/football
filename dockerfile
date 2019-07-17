FROM erlang:21

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.8.2" \
	LANG=C.UTF-8

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="cf9bf0b2d92bc4671431e3fe1d1b0a0e5125f1a942cc4fdf7914b74f04efb835" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean

RUN mkdir project/ \
    && cd project \
    && git clone https://github.com/antonio101/football.git \
    && cd football \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix compile \
	&& cd /root

EXPOSE 4001

CMD ["/project/football/run_app.sh"]
