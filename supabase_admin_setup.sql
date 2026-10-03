-- NoidaTrade shared Big/Small controls
-- Replace YOUR_ADMIN_EMAIL with the exact email of the Supabase Auth admin account.
create table if not exists public.noidatrade_round_controls (
  period text primary key,
  forced_size text check (forced_size in ('Big','Small')),
  is_manual boolean not null default false,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);
alter table public.noidatrade_round_controls enable row level security;
grant select on public.noidatrade_round_controls to anon, authenticated;
grant insert, update on public.noidatrade_round_controls to authenticated;
drop policy if exists "Public can read round controls" on public.noidatrade_round_controls;
create policy "Public can read round controls"
on public.noidatrade_round_controls for select to anon, authenticated using (true);
drop policy if exists "Admin email can insert controls" on public.noidatrade_round_controls;
create policy "Admin email can insert controls"
on public.noidatrade_round_controls for insert to authenticated
with check ((auth.jwt() ->> 'email') = 'YOUR_ADMIN_EMAIL');
drop policy if exists "Admin email can update controls" on public.noidatrade_round_controls;
create policy "Admin email can update controls"
on public.noidatrade_round_controls for update to authenticated
using ((auth.jwt() ->> 'email') = 'YOUR_ADMIN_EMAIL')
with check ((auth.jwt() ->> 'email') = 'YOUR_ADMIN_EMAIL');
