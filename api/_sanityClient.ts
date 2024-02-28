import { createClient } from "@sanity/client";

export const sanityClient = createClient({
    apiVersion: "2021-06-07",
    projectId: process.env.SANITY_PROJECT_ID,
    dataset: "production",
    token: process.env.SANITY_TOKEN,
});
