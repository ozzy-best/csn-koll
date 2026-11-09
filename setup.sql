-- Kör i Supabase: SQL Editor > New query > Run
create table public.incomes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  employer text not null check (char_length(employer) between 1 and 80),
  amount numeric(12,2) not null check (amount > 0),
  paid_date date not null,
  category text default '',
  description text default '',
  created_at timestamptz default now()
);
create table public.limits (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  year int not null,
  half int not null check (half in (1,2)),
  amount numeric(12,2) not null check (amount >= 0),
  primary key (user_id, year, half)
);
alter table public.incomes enable row level security;
alter table public.limits enable row level security;
create policy "own incomes" on public.incomes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own limits" on public.limits for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
alter publication supabase_realtime add table public.incomes, public.limits;


