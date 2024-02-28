import * as Sentry from "@sentry/node";

Sentry.init({
    dsn: process.env.SENTRY_DSN,
    debug: true,
    environment: process.env.NODE_ENV,
    tracesSampleRate: 1.0,
});

export default Sentry;
