-- NoidaTrade secure admin access + shared round controls
-- IMPORTANT: replace ADMIN_EMAIL_HERE with the exact email used for the admin's Supabase Auth account.
-- Run this entire script in Supabase Dashboard > SQL Editor.
create table if not exists public.noidatrade_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  created_at timestamptz not null default now()
);
alter table public.noidatrade_admins enable row level security;
revoke all on public.noidatrade_admins from anon, authenticated;
grant select on public.noidatrade_admins to authenticated;
drop policy if exists "Admins can read own admin record" on public.noidatrade_admins;
create policy "Admins can read own admin record"
on public.noidatrade_admins for select to authenticated
using (user_id = auth.uid() and lower(email) = lower(auth.jwt() ->> 'email'));

-- After creating the admin account in Supabase Authentication, add its UUID:
-- insert into public.noidatrade_admins (user_id, email)
-- select id, email from auth.users where lower(email) = lower('ADMIN_EMAIL_HERE');

create table if not exists public.noidatrade_round_controls (
  period text primary key,
  forced_size text check (forced_size in ('Big','Small')),
  is_manual boolean not null default false,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);
alter table public.noidatrade_round_controls enable row level security;
revoke all on public.noidatrade_round_controls from anon, authenticated;
grant select on public.noidatrade_round_controls to anon, authenticated;
grant insert, update, delete on public.noidatrade_round_controls to authenticated;
drop policy if exists "Public can read round controls" on public.noidatrade_round_controls;
create policy "Public can read round controls"
on public.noidatrade_round_controls for select to anon, authenticated using (true);
drop policy if exists "Admin email can insert controls" on public.noidatrade_round_controls;
drop policy if exists "Admin email can update controls" on public.noidatrade_round_controls;
drop policy if exists "Only registered admins can insert controls" on public.noidatrade_round_controls;
create policy "Only registered admins can insert controls"
on public.noidatrade_round_controls for insert to authenticated
with check (exists (select 1 from public.noidatrade_admins a where a.user_id = auth.uid() and lower(a.email) = lower(auth.jwt() ->> 'email')));
drop policy if exists "Only registered admins can update controls" on public.noidatrade_round_controls;
create policy "Only registered admins can update controls"
on public.noidatrade_round_controls for update to authenticated
using (exists (select 1 from public.noidatrade_admins a where a.user_id = auth.uid() and lower(a.email) = lower(auth.jwt() ->> 'email')))
with check (exists (select 1 from public.noidatrade_admins a where a.user_id = auth.uid() and lower(a.email) = lower(auth.jwt() ->> 'email')));
drop policy if exists "Only registered admins can delete controls" on public.noidatrade_round_controls;
create policy "Only registered admins can delete controls"
on public.noidatrade_round_controls for delete to authenticated
using (exists (select 1 from public.noidatrade_admins a where a.user_id = auth.uid() and lower(a.email) = lower(auth.jwt() ->> 'email')));
