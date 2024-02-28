import { Request, Response } from "express";
import Sentry from "./_sentry";

export const deleteNotificationCallback = async (req: Request, res: Response) => {
    const { notification_id } = req.body;
    // Delete notification
    await deleteNotification(notification_id);
    res.send("Notification deleted");
};

const deleteNotification = async (notificationId: string) => {
    // Delete notification using OneSignal API
    try {
        const response = await fetch(
            `https://api.onesignal.com/notifications/${notificationId}?app_id=${process.env.ONESIGNAL_APP_ID}`,
            {
                method: "DELETE",
                headers: {
                    "Content-Type": "application/json",
                    Accept: "application/json",
                    Authorization: `Basic ${process.env.ONESIGNAL_TOKEN}`,
                },
            }
        );
    } catch (error) {
        Sentry.captureException(error);
        return;
    }
};
