# MomentumKonf App

This project is a Dart application built with the Flutter framework. It includes a comprehensive set of UI components and utilizes the OneSignal API for push notifications (web only). The application is cross-platform and can be run on Android, iOS, and web.

## Installation 

To install and run this project, follow these steps:

1. Ensure that you have [Flutter](https://flutter.dev/docs/get-started/install) and [Dart](https://dart.dev/get-dart) installed on your machine.

2. Clone the repository:

```sh
git clone https://github.com/MomentumConf/Momentum24_app.git
```

3. Navigate into the project directory:

```sh
cd Momentum24_app
```

4. Install the dependencies:
```sh
flutter pub get
```

5. Run the application:
```sh
flutter run

# Or run on web
flutter run -d chrome
```

## Testing
TBD

## Deployment

This project can be deployed using [Vercel](https://vercel.com/), a platform with native Flutter support. Follow these steps to deploy your project:

1. Install the Vercel CLI:

```sh
npm i -g vercel
```

2. Login to your Vercel account (create one if you don't have it):
```sh
vercel login
```

3. Navigate to your project directory:
```sh
cd Momentum24_app
```

4. Run the build & deploy commands:
```sh
vercel build && vercel deploy --prebuilt

# Or deploy directly to production
vercel build --prod && vercel --prod deploy --prebuilt
```

After running the command, your project will be deployed, and you will receive a link to the deployed site.


## Authors
Contributors to the project.  
[`@bkazula`](https://github.com/bkazula)