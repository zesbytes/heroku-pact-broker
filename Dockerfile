FROM ruby:2.4.1-alpine

# our gemfile includes gem pg, which has a native extension assuming libpq-fe.h exists when compiling, therefore we install postgresql-dev
# our gemfile includes gem thin, which has a dependency on eventmachine, which has a native extension assuming libstdc++.so.6 exists at runtime, therefore we install libstdc++
RUN apk update && apk add --no-cache postgresql-dev libstdc++

WORKDIR /app
COPY app /app
RUN chmod 777 /app

RUN bundle lock && rm -rf ~/.bundle/cache

# we temporarily install build-base so gem native extensions can be compiled when installed. We remove after gems are installed
RUN apk add --no-cache --virtual .build-deps build-base && \
  bundle install --deployment --no-cache --clean --without='development test' && \
  apk del .build-deps

COPY startup.sh .

CMD ["./startup.sh"]
