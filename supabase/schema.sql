create extension if not exists "pgcrypto";

create table if not exists public.word_books (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  level text not null default '自定义词书',
  description text not null default '',
  cover_style text not null default 'mint',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.words (
  id uuid primary key default gen_random_uuid(),
  book_id uuid not null references public.word_books(id) on delete cascade,
  word text not null,
  phonetic text not null default '',
  part_of_speech text not null default '',
  meaning text not null,
  is_wrong boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.words
add column if not exists part_of_speech text not null default '';

create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  book_id uuid not null references public.word_books(id) on delete cascade,
  review_mode text not null check (review_mode in ('full_book', 'wrong_words')),
  total_count integer not null default 0,
  known_count integer not null default 0,
  unknown_count integer not null default 0,
  review_index integer not null default 0,
  session_known integer not null default 0,
  session_unknown integer not null default 0,
  is_completed boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.study_sessions
add column if not exists review_index integer not null default 0;

alter table public.study_sessions
add column if not exists session_known integer not null default 0;

alter table public.study_sessions
add column if not exists session_unknown integer not null default 0;

alter table public.study_sessions
add column if not exists is_completed boolean not null default false;

create table if not exists public.study_records (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.study_sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  word_id uuid not null references public.words(id) on delete cascade,
  result text not null check (result in ('known', 'unknown')),
  created_at timestamptz not null default now()
);

alter table public.word_books enable row level security;
alter table public.words enable row level security;
alter table public.study_sessions enable row level security;
alter table public.study_records enable row level security;

create policy "users can read own books"
on public.word_books
for select
to authenticated
using (auth.uid() = owner_user_id);

create policy "users can insert own books"
on public.word_books
for insert
to authenticated
with check (auth.uid() = owner_user_id);

create policy "users can update own books"
on public.word_books
for update
to authenticated
using (auth.uid() = owner_user_id);

create policy "users can delete own books"
on public.word_books
for delete
to authenticated
using (auth.uid() = owner_user_id);

create policy "users can read own words"
on public.words
for select
to authenticated
using (
  exists (
    select 1 from public.word_books
    where public.word_books.id = words.book_id
      and public.word_books.owner_user_id = auth.uid()
  )
);

create policy "users can insert own words"
on public.words
for insert
to authenticated
with check (
  exists (
    select 1 from public.word_books
    where public.word_books.id = words.book_id
      and public.word_books.owner_user_id = auth.uid()
  )
);

create policy "users can update own words"
on public.words
for update
to authenticated
using (
  exists (
    select 1 from public.word_books
    where public.word_books.id = words.book_id
      and public.word_books.owner_user_id = auth.uid()
  )
);

create policy "users can delete own words"
on public.words
for delete
to authenticated
using (
  exists (
    select 1 from public.word_books
    where public.word_books.id = words.book_id
      and public.word_books.owner_user_id = auth.uid()
  )
);

create policy "users can manage own sessions"
on public.study_sessions
for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own records"
on public.study_records
for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
