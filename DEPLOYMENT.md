# Deploying Butlr to Serverpod Cloud

This guide walks you through deploying the Butlr project to [Serverpod Cloud](https://serverpod.cloud/).

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart) (3.8.0+)
- A [Serverpod Cloud account](https://serverpod.cloud/)
- Your Novita AI API key (for the chat/task assistant)

## Step 1: Install the Serverpod Cloud CLI

```bash
dart pub global activate serverpod_cloud_cli
```

Ensure `~/.pub-cache/bin` (or `%LOCALAPPDATA%\Pub\Cache\bin` on Windows) is in your PATH.

## Step 2: Log in to Serverpod Cloud

```bash
scloud auth login
```

This opens a browser to authenticate. Complete the login flow.

## Step 3: Set Your Secrets

Your app needs the **Novita API key** for the AI chat feature. Set it as a secret:

```bash
cd butlrapp_server
scloud secret create SERVERPOD_PASSWORD_novitaApiKey "YOUR_NOVITA_API_KEY_HERE"
```

Replace `YOUR_NOVITA_API_KEY_HERE` with your actual Novita API key (e.g. from [Novita AI](https://novita.ai/)).

> **Note:** Secrets prefixed with `SERVERPOD_PASSWORD_` are available via `session.serverpod.getPassword('novitaApiKey')` in your endpoints.

## Step 4: Deploy

From the `butlrapp_server` directory:

```bash
scloud deploy
```

This will:

1. Run `serverpod generate` (pre_deploy)
2. Build your Docker image
3. Push to Serverpod Cloud
4. Run database migrations automatically
5. Start your server

## Step 5: Monitor the Deployment

```bash
scloud deployment show
```

To stream logs in real time:

```bash
scloud log --tail
```

To fetch recent logs (e.g., last 5 minutes):

```bash
scloud log --since 5m
```

## Your Deployed URLs

After deployment, your project will be available at:

| Service | URL |
|---------|-----|
| **API** | `https://butlr1.api.serverpod.space` |
| **Web App** | `https://butlr1.app.serverpod.space` |
| **Insights** | `https://butlr1.insights.serverpod.space` |

Your Flutter app is already configured to use `https://butlr1.api.serverpod.space` in production builds.

## Optional: Include Flutter Web App

To serve the Flutter web app from your Serverpod server (at `/app/`):

1. Ensure Flutter is installed and `flutter build web` works
2. Edit `butlrapp_server/scloud.yaml` and uncomment the `flutter_build` line:

```yaml
pre_deploy:
  - "serverpod generate"
  - "serverpod run flutter_build"
```

3. Redeploy with `scloud deploy`

> **Note:** The Serverpod Cloud build environment may need Flutter. If the build fails, build the Flutter web app locally and commit the `web/app` folder, or host the web app separately (e.g. Firebase Hosting, Vercel).

## Troubleshooting

### AI not working / "I'm not sure what you'd like me to do"
1. **Verify your Novita API key** – If you used `"YOUR_NOVITA_API_KEY"` literally, update it:
   ```powershell
   scloud secret delete SERVERPOD_PASSWORD_novitaApiKey
   scloud secret create SERVERPOD_PASSWORD_novitaApiKey "sk_your_actual_novita_key"
   ```
2. **Check Serverpod Cloud logs** – `scloud log --tail` to see Novita API errors (401 = invalid key)
3. **Get a valid key** – Create one at https://novita.ai/settings/key-management
4. **Redeploy** after updating the secret: `scloud deploy`

### "Novita API key not configured"
- Ensure you ran `scloud secret create SERVERPOD_PASSWORD_novitaApiKey "your-key"`
- Redeploy after adding secrets

### Deployment fails
- Run `scloud log --tail` to see real-time logs
- Check `scloud deployment show` for deployment status
- Ensure `serverpod generate` runs successfully locally: `cd butlrapp_server && serverpod generate`

### Database migrations
- Migrations run automatically on deploy
- To inspect the database: `scloud db connect` (if available)

## Useful Commands

| Command | Description |
|--------|-------------|
| `scloud deploy` | Deploy your app |
| `scloud deployment show` | Show deployment status |
| `scloud log --tail` | Stream live logs |
| `scloud secret list` | List configured secrets |
| `scloud domain list` | List domains (for custom domains) |
| `scloud help` | Full command reference |

## Custom Domains

To use your own domain (e.g. `api.myapp.com`):

```bash
scloud domain add api.myapp.com
```

Follow the DNS instructions provided. SSL certificates are provisioned automatically.
