import { NotificationData } from "./global";
import { Request, Response } from "express";
import Sentry from "./_sentry";
import { sanityClient } from "./_sanityClient";

export const sendNotificationCallback = async (req: Request, res: Response) => {
    const { _id, description, title, date } = req.body as NotificationData;
    // Send notification to all users
    try {
        await sendNotificationToAllUsers({ _id, description, title, date } as Partial<NotificationData>);
        res.status(201).send("Notification sent");
    } catch (error) {
        Sentry.captureException(error);
        res.status(500).send("Failed to send notification");
    }
};

const sendNotificationToAllUsers = async ({ _id, description, title, date }: Partial<NotificationData>) => {
    let notificationId, response;

    try {
        // Send notification to all users using OneSignal API
        const notificationDate = new Date(date!);
        notificationDate.setSeconds(0);
        response = await fetch("https://api.onesignal.com/notifications/", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Accept: "application/json",
                Authorization: `Basic ${process.env.ONESIGNAL_TOKEN}`,
            },
            body: JSON.stringify({
                app_id: process.env.ONESIGNAL_APP_ID,
                contents: { en: description, pl: description },
                headings: { en: title, pl: title },
                send_after: notificationDate >= new Date() ? notificationDate.toUTCString() : new Date().toUTCString(),
                filters: [
                    // Send notification to users who have used the app in the last 14 days
                    { field: "last_session", relation: ">", value: "337" },
                ],
            }),
        });
        const responseBody = await response.json();
        if (!response.ok) {
            throw Error("Error sending notification: " + JSON.stringify(responseBody));
        }
        notificationId = responseBody.id;
    } catch (error) {
        Sentry.captureException(error);
        throw Error("Failed to send notification");
    }

    if (!notificationId) {
        Sentry.captureMessage(
            "Error sending notification: " + JSON.stringify({ _id, statusText: response.statusText }),
            "error"
        );
        throw Error("Failed to send notification");
    }
    try {
        const mutations = {
            set: {
                notification_id: notificationId,
            },
        };

        // Update the notification in Sanity adding notification_id parameter
        const sanityResponse = await sanityClient.patch(_id!, mutations).commit();

        if (!sanityResponse) {
            throw Error("Error updating notification");
        }
    } catch (error) {
        Sentry.captureException(error);

        // We should not try to send the notification again if the update fails
        return;
    }
};
