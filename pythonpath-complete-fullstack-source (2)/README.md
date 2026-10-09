# PythonPath — Complete full-stack source package

English-only, responsive Python learning platform source. Includes Supabase Auth OTP frontend integration, RLS database schema, progress sync, AI tutor Edge Function, admin Edge Function, certificate issuance Edge Function, and a scheduled reminder template.

## What is implemented in source
- Responsive UI with default 125% text scale and a text-size selector.
- 12 beginner lessons, quiz, browser Pyodide playground, XP and local progress.
- Supabase email OTP sign-in.
- Supabase profile/progress/attendance sync (review/test before production).
- AI tutor endpoint (`ai-tutor`) that calls OpenAI Responses API from the server.
- Admin endpoint (`admin-users`) with role verification and server-side admin operations.
- Server-issued certificate records (`issue-certificate`); browser PDF export is currently a participation document unless wired to this endpoint.
- Scheduled reminder function template (`send-reminder`) using Resend; configure an approved sender and scheduler.

## Deploy frontend
1. Upload the repository contents to GitHub.
2. Render Static Site: build command blank, publish directory `public`.
3. Replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY` in `public/index.html`.
4. Configure Supabase Auth Site URL and Redirect URLs for your deployed site.

## Database
Run `supabase/migrations/202610090002_complete_platform.sql` in Supabase SQL Editor. This migration is designed to create missing tables and update lesson seeds. If you already ran the earlier PythonPath migration, inspect for policy/table conflicts before running. The script uses `create table if not exists`, and adds `role`; still take a database backup before production changes.

## Deploy Edge Functions
Install Supabase CLI and link your project, then:
```bash
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy ai-tutor
supabase functions deploy admin-users
supabase functions deploy issue-certificate
supabase functions deploy send-reminder
```
Configure secrets through Supabase project secrets/CLI, never in GitHub:
```bash
supabase secrets set OPENAI_API_KEY=YOUR_OPENAI_KEY
supabase secrets set AI_MODEL=gpt-4.1-mini
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY
supabase secrets set RESEND_API_KEY=YOUR_RESEND_KEY
supabase secrets set REMINDER_FROM_EMAIL=PythonPath <verified-sender@example.com>
supabase secrets set REMINDER_SECRET=LONG_RANDOM_SECRET
```
Supabase supplies `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and the service role environment secret in hosted Edge Functions in the standard environment; if your project environment does not expose them, set them as secrets securely. Never place the service-role key in browser code.

## Promote the first administrator
After you have signed in at least once, run this in Supabase SQL Editor, replacing the email:
```sql
update public.pythonpath_profiles p
set role='admin'
from auth.users u
where p.id=u.id and u.email='YOUR_ADMIN_EMAIL';
```
Admin UI and endpoint check the profile role. Keep admin membership restricted.

## Email OTP
Supabase Auth → URL Configuration: set Site URL to the deployed Render URL and add it to Redirect URLs. Configure Auth email templates/provider settings and test deliverability. If you use custom SMTP, enter credentials only in the Supabase dashboard secrets/settings; never paste them into this repository.

## Honest limitations before production
- The playground uses Pyodide in the user's browser, not an isolated server-side sandbox. Do not run untrusted code on a server until a separate container-isolated execution service is implemented.
- XP is currently partly client-derived and should be made server-authoritative to prevent cheating.
- Certificate PDF UI is a client-side PDF; use `issue-certificate` and add a verification page/QR code before describing PDFs as official, tamper-resistant certificates.
- `send-reminder` is a starter scheduled function. Configure scheduler, verified email domain, consent/preferences, bounce handling, unsubscribe rules, and rate limits before enabling reminders.
- Configure rate limits/CAPTCHA for auth, monitor AI spend, and apply per-user quotas before public launch.
- Run tests on staging, review RLS, and inspect function logs before production use.
