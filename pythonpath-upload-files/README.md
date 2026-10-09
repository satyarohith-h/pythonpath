# PythonPath Starter MVP

A responsive, beginner-friendly Python learning dashboard.

## What's included
- Dashboard with XP, streak, progress, achievements, and weekly activity
- 12 starter lessons with examples and practice tasks
- Browser-based Python playground powered by Pyodide (downloads runtime from CDN on first run)
- Mini quiz with score and XP
- Local browser progress storage
- Responsive desktop/mobile layout

## Deploy on GitHub Pages
1. Create or open your repository: https://github.com/satyarohith-h/pythonpath
2. Upload `index.html` and `README.md` to the repository root.
3. Commit the files to the default branch.
4. In the repository, open **Settings → Pages**.
5. Under **Build and deployment**, choose **Deploy from a branch**.
6. Select your default branch and `/ (root)`, then Save.
7. Wait for GitHub Pages to publish the site. The URL will appear on the Pages settings screen.

## Important limitations
This is a frontend starter, not the complete production platform. It does not yet include server-side user accounts, OTP email verification, password reset, cloud-synced progress, a real AI tutor backend, certificates, an admin dashboard, or a secured server-side code execution service. Progress is stored in local browser storage. The Python playground runs client-side via Pyodide and requires an internet connection to load the runtime.
