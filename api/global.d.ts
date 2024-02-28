interface CommonNotificationData {
    _id: string;
    title: string;
    description: string;
    date: string;
}

interface CreateNotificationData {
    action_type: "create";
    notification_id: null;
}

interface DeleteNotificationData {
    action_type: "delete";
    notification_id: string;
}

export type NotificationData = CommonNotificationData & (CreateNotificationData | DeleteNotificationData);
