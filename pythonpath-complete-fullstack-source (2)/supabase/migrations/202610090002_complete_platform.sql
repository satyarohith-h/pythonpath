-- PythonPath full-stack schema. Run once in Supabase SQL Editor.
create table if not exists public.pythonpath_profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text,
 role text not null default 'learner' check(role in ('learner','admin')),
 xp integer not null default 0 check(xp>=0),
 current_streak integer not null default 0 check(current_streak>=0),
 last_active_date date,
 created_at timestamptz not null default now()
);
alter table public.pythonpath_profiles add column if not exists role text not null default 'learner';
create table if not exists public.pythonpath_lessons (
 id text primary key,title text not null,module text not null default 'Python foundations',
 level text not null default 'Beginner',order_index integer not null unique,
 summary text not null default '',content jsonb not null default '{}'::jsonb,
 published boolean not null default true,created_at timestamptz not null default now()
);
create table if not exists public.pythonpath_progress (
 user_id uuid not null references auth.users(id) on delete cascade,
 lesson_id text not null references public.pythonpath_lessons(id) on delete cascade,
 status text not null default 'in_progress' check(status in ('in_progress','completed')),
 score integer,completed_at timestamptz,updated_at timestamptz not null default now(),
 primary key(user_id,lesson_id)
);
create table if not exists public.pythonpath_quiz_attempts (
 id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,
 lesson_id text references public.pythonpath_lessons(id) on delete set null,
 score integer not null default 0,total_questions integer not null default 0,
 answers jsonb not null default '[]'::jsonb,created_at timestamptz not null default now()
);
create table if not exists public.pythonpath_projects (
 id uuid primary key default gen_random_uuid(),slug text not null unique,title text not null,
 description text not null default '',level text not null default 'Beginner',
 instructions jsonb not null default '[]'::jsonb,published boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.pythonpath_attendance (
 user_id uuid not null references auth.users(id) on delete cascade,activity_date date not null default current_date,
 minutes_learned integer not null default 0 check(minutes_learned>=0),created_at timestamptz not null default now(),
 primary key(user_id,activity_date)
);
create table if not exists public.pythonpath_certificates (
 id uuid primary key default gen_random_uuid(),user_id uuid not null unique references auth.users(id) on delete cascade,
 certificate_code text not null unique,issued_at timestamptz not null default now(),verified boolean not null default true,
 completed_lessons integer not null default 12
);
alter table public.pythonpath_profiles enable row level security;
alter table public.pythonpath_lessons enable row level security;
alter table public.pythonpath_progress enable row level security;
alter table public.pythonpath_quiz_attempts enable row level security;
alter table public.pythonpath_projects enable row level security;
alter table public.pythonpath_attendance enable row level security;
alter table public.pythonpath_certificates enable row level security;

drop policy if exists "profile own read" on public.pythonpath_profiles;
create policy "profile own read" on public.pythonpath_profiles for select to authenticated using(auth.uid()=id);
drop policy if exists "profile own insert" on public.pythonpath_profiles;
create policy "profile own insert" on public.pythonpath_profiles for insert to authenticated with check(auth.uid()=id);
drop policy if exists "profile own update" on public.pythonpath_profiles;
create policy "profile own update" on public.pythonpath_profiles for update to authenticated using(auth.uid()=id) with check(auth.uid()=id);
drop policy if exists "published lessons readable" on public.pythonpath_lessons;
create policy "published lessons readable" on public.pythonpath_lessons for select to anon,authenticated using(published=true);
drop policy if exists "own progress read" on public.pythonpath_progress;
create policy "own progress read" on public.pythonpath_progress for select to authenticated using(auth.uid()=user_id);
drop policy if exists "own progress insert" on public.pythonpath_progress;
create policy "own progress insert" on public.pythonpath_progress for insert to authenticated with check(auth.uid()=user_id);
drop policy if exists "own progress update" on public.pythonpath_progress;
create policy "own progress update" on public.pythonpath_progress for update to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists "own quiz attempts read" on public.pythonpath_quiz_attempts;
create policy "own quiz attempts read" on public.pythonpath_quiz_attempts for select to authenticated using(auth.uid()=user_id);
drop policy if exists "own quiz attempts insert" on public.pythonpath_quiz_attempts;
create policy "own quiz attempts insert" on public.pythonpath_quiz_attempts for insert to authenticated with check(auth.uid()=user_id);
drop policy if exists "published projects readable" on public.pythonpath_projects;
create policy "published projects readable" on public.pythonpath_projects for select to anon,authenticated using(published=true);
drop policy if exists "own attendance read" on public.pythonpath_attendance;
create policy "own attendance read" on public.pythonpath_attendance for select to authenticated using(auth.uid()=user_id);
drop policy if exists "own attendance insert" on public.pythonpath_attendance;
create policy "own attendance insert" on public.pythonpath_attendance for insert to authenticated with check(auth.uid()=user_id);
drop policy if exists "own attendance update" on public.pythonpath_attendance;
create policy "own attendance update" on public.pythonpath_attendance for update to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists "own certificates read" on public.pythonpath_certificates;
create policy "own certificates read" on public.pythonpath_certificates for select to authenticated using(auth.uid()=user_id);

-- Only admins can insert/update published lesson content.
drop policy if exists "admin lesson insert" on public.pythonpath_lessons;
create policy "admin lesson insert" on public.pythonpath_lessons for insert to authenticated with check(exists(select 1 from public.pythonpath_profiles p where p.id=auth.uid() and p.role='admin'));
drop policy if exists "admin lesson update" on public.pythonpath_lessons;
create policy "admin lesson update" on public.pythonpath_lessons for update to authenticated using(exists(select 1 from public.pythonpath_profiles p where p.id=auth.uid() and p.role='admin')) with check(exists(select 1 from public.pythonpath_profiles p where p.id=auth.uid() and p.role='admin'));

insert into public.pythonpath_lessons(id,title,module,level,order_index,summary,content,published) values
('starter-1','Meet Python','Python foundations','Beginner',1,'An introduction to Python','{"minutes":5}',true),
('starter-2','Variables & values','Python foundations','Beginner',2,'Store values using variables','{"minutes":7}',true),
('starter-3','Numbers & math','Python foundations','Beginner',3,'Perform arithmetic','{"minutes":6}',true),
('starter-4','Strings & text','Python foundations','Beginner',4,'Work with text','{"minutes":8}',true),
('starter-5','Getting input','Python foundations','Beginner',5,'Read user input','{"minutes":7}',true),
('starter-6','Make decisions','Python foundations','Beginner',6,'Use if and else','{"minutes":9}',true),
('starter-7','For loops','Python foundations','Beginner',7,'Repeat actions with for','{"minutes":8}',true),
('starter-8','While loops','Python foundations','Beginner',8,'Repeat while a condition is true','{"minutes":8}',true),
('starter-9','Lists','Python foundations','Beginner',9,'Store ordered collections','{"minutes":9}',true),
('starter-10','Functions','Python foundations','Beginner',10,'Create reusable functions','{"minutes":10}',true),
('starter-11','Dictionaries','Python foundations','Beginner',11,'Map keys to values','{"minutes":9}',true),
('starter-12','Mini project','Python foundations','Beginner',12,'Combine concepts in a project','{"minutes":15}',true)
on conflict(id) do update set title=excluded.title,summary=excluded.summary,published=true;
