FROM node:latest

ARG PORT=80

WORKDIR /app

COPY --link package.json package.json
COPY yarn.lock yarn.lock

RUN yarn

COPY --link . .

ENV PORT=$PORT
EXPOSE ${PORT}

CMD ["yarn", "start"]