# Momentum Notifications API

The API for this project is built with Express.js and is located in the [`api/`](api/) directory. It is deployed to Vercel serverless functions.

The API uses Sentry for error tracking, OneSignal for push notifications and Sanity for data storage.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [API Documentation](#api-documentation)

## Installation

1. Clone the repository.
2. Install the dependencies using `yarn install`.

The API uses the following environment variables, which should be stored in a `.env` file in the `api/` directory:

- `API_SECRET`: The secret key used for authorization.
- `ONESIGNAL_APP_ID`: The ID of your OneSignal application.
- `ONESIGNAL_TOKEN`: The token for your OneSignal application.
- `SANITY_PROJECT_ID`: The ID of your Sanity project.
- `SANITY_TOKEN`: The token for your Sanity project.
- `SENTRY_DSN`: The DSN for your Sentry project.

## Usage

1. Start the server using `yarn start`.
2. Access the API endpoints at `http://localhost:3000`.

## API Documentation

The API has a single endpoint, `/api/notification`, which accepts POST requests. This endpoint requires an `action_type` in the request body, which can be one of the following:

- `create`: Creates a new notification. It's body looks like this:
  ```json
  {
    "action_type": "create",
    "_id": "notification_id",
    "title": "Notification Title",
    "description": "Notification Description",
    "date": "2024-01-01T00:00:00Z"
  }
  ```
- `delete`: Deletes an existing notification. It's body looks like this:
  ```json
  {
    "action_type": "delete",
    "notification_id": "notification_id"
  }
  ```

The `notification_id` is the unique identifier for the notification in the Sanity project.
