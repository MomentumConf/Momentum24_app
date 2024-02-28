import express from "express";
import Sentry from "./_sentry";

import { sendNotificationCallback } from "./_sendNotification";
import { deleteNotificationCallback } from "./_deleteNotification";

const app = express();

const API_TOKEN = process.env.API_SECRET;

app.use(express.json());

app.post("/api/notification", (req, res) => {
    if (req.headers.authorization !== `Bearer ${API_TOKEN}`) {
        return res.status(401).send("Unauthorized");
    }

    const { action_type } = req.body;
    if (action_type === "create") {
        sendNotificationCallback(req, res);
    } else if (action_type === "delete") {
        deleteNotificationCallback(req, res);
    } else {
        Sentry.captureMessage("Invalid action_type: " + action_type, "error");
        res.status(400).send("Invalid action_type");
    }
});

export default app;
