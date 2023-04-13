FROM ruby:3.2.2-bullseye

ENV LANG=C.UTF-8

WORKDIR /src/apps/rails

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 2000 app
RUN adduser --disabled-login --shell /sbin/nologin --gid 2000 --uid 2000 app
RUN chown app:app /src/apps/rails

USER 2000

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN BUNDLER_VERSION=`grep -A1 'BUNDLED WITH' Gemfile.lock | tail -n 1 | sed -e 's/ //g'` \
    && gem install bundler -v ${BUNDLER_VERSION} \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle config set jobs $(nproc) \
    && bundle _${BUNDLER_VERSION}_ install

CMD ["sh", "-c", "bundle install && rm -f tmp/pids/server.pid && rails s -p 3000 -b '0.0.0.0'"]
