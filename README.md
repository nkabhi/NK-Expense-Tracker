# Expense Tracker — setup guide (no coding needed)

This turns into an installable Android app using GitHub's free build servers.
You don't need Android Studio, a command line, or any coding knowledge.

## Step 1 — Create a GitHub account
Go to https://github.com and sign up. Free.

## Step 2 — Create a new repository
1. Click the **+** icon top-right → **New repository**
2. Name it `expense-tracker`
3. Keep it **Private** (recommended, since this is financial data)
4. Click **Create repository**

## Step 3 — Upload this folder
1. On your new repository's page, click **uploading an existing file**
2. Drag the entire `expense_tracker` folder (everything inside this zip)
   into the browser window
3. Scroll down, click **Commit changes**

   Note: GitHub's drag-and-drop uploader sometimes flattens folder structure.
   If that happens, use **GitHub Desktop** instead (a free app, also no
   command line) — install it from https://desktop.github.com, sign in,
   clone your empty repo, copy these files into the folder it creates on
   your computer, then click **Commit** and **Push** inside the app. This
   preserves folders correctly and is the more reliable option.

## Step 4 — Let it build
1. Click the **Actions** tab at the top of your repository
2. You'll see "Build Android APK" running (takes 3-5 minutes)
3. Once it shows a green checkmark, click into that run
4. Scroll down to **Artifacts**, click **expense-tracker-apk** to download it
   — this comes as a `.zip`, unzip it to get `app-release.apk`

## Step 5 — Install on your phone
1. Move `app-release.apk` onto your Android phone (email it to yourself,
   or use a USB cable, or Google Drive)
2. Tap the file on your phone
3. Android will warn about "unknown sources" — tap **Settings**, allow
   installs from this source, go back, tap **Install**
4. Open the app

## What to expect on first open
- The app will ask for SMS permission — allow it if you want auto-capture,
  or skip it and add everything manually from the **Add** tab
- Go to **Settings → Set up SMS auto-capture** to scan existing messages
  and start auto-capturing new ones
- Everything is stored encrypted, only on your phone — this app has no
  internet permission at all, so nothing can be sent anywhere

## Known limitations of this first version
- The SMS parser recognizes common wording ("debited", "credited", "Avl
  Bal") but every bank phrases messages slightly differently. Some
  messages may be missed or miscategorized at first — send me a few real
  examples (redact account numbers/amounts if you like) and I'll tune the
  patterns to your bank specifically.
- Investment values (SIP/PPF) are entered and updated manually, by design,
  since pulling live data would require internet access.
- iOS is not supported for SMS auto-capture — Apple blocks this at the
  OS level for all apps. A manual-entry-only iOS version can be built
  separately if you need it.
