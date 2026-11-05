-- Run once in a new Supabase project's SQL Editor.
begin;

create table public.hobbies (
  id text primary key,
  name text not null
);
insert into public.hobbies values
  ('climbing', 'Rock climbing'), ('crochet', 'Crochet'),
  ('film', 'Film photography'), ('sourdough', 'Sourdough'),
  ('woodworking', 'Woodworking'), ('gardening', 'Gardening'),
  ('guitar', 'Guitar'), ('running', 'Running');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(trim(display_name)) between 1 and 40),
  bio text not null default '' check (char_length(bio) <= 160)
);
create table public.memberships (
  user_id uuid not null references public.profiles(id) on delete cascade,
  hobby_id text not null references public.hobbies(id),
  primary key (user_id, hobby_id)
);
create table public.community_posts (
  id uuid primary key default gen_random_uuid(),
  hobby_id text not null references public.hobbies(id),
  author_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 120),
  body text not null check (char_length(trim(body)) between 1 and 4000),
  kind text not null check (kind in ('Project', 'Question', 'Meet up')),
  created_at timestamptz not null default now()
);
create table public.community_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(trim(body)) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index community_posts_date on public.community_posts(created_at desc);
create index community_posts_hobby on public.community_posts(hobby_id);
create index community_comments_post on public.community_comments(post_id);

create function public.create_member_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, display_name) values (
    new.id,
    left(coalesce(nullif(trim(new.raw_user_meta_data->>'display_name'), ''), 'New member'), 40)
  );
  return new;
end;
$$;
create trigger on_member_created after insert on auth.users
  for each row execute function public.create_member_profile();
-- Support accounts created before this script was run.
insert into public.profiles (id, display_name)
select id, left(coalesce(nullif(trim(raw_user_meta_data->>'display_name'), ''), 'New member'), 40)
from auth.users on conflict do nothing;

alter table public.hobbies enable row level security;
alter table public.profiles enable row level security;
alter table public.memberships enable row level security;
alter table public.community_posts enable row level security;
alter table public.community_comments enable row level security;

-- Explicit privileges: access still requires the matching RLS policy.
revoke all on public.hobbies, public.profiles, public.memberships,
  public.community_posts, public.community_comments from anon, authenticated;
grant select on public.hobbies, public.profiles, public.memberships,
  public.community_posts, public.community_comments to authenticated;
grant update (display_name, bio) on public.profiles to authenticated;
grant insert, update, delete on public.memberships to authenticated;
grant insert on public.community_posts, public.community_comments to authenticated;

create policy "Members can discover hobbies" on public.hobbies
  for select to authenticated using (true);
create policy "Members can view public profiles" on public.profiles
  for select to authenticated using (true);
create policy "Members can edit own profile" on public.profiles
  for update to authenticated using (id = (select auth.uid()))
  with check (id = (select auth.uid()));
create policy "Members manage own memberships" on public.memberships
  for all to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy "Members can discover conversations" on public.community_posts
  for select to authenticated using (true);
create policy "Joined members can post as themselves" on public.community_posts
  for insert to authenticated with check (
    author_id = (select auth.uid()) and exists (
      select 1 from public.memberships m
      where m.user_id = (select auth.uid()) and m.hobby_id = community_posts.hobby_id
    )
  );
create policy "Members can read replies" on public.community_comments
  for select to authenticated using (true);
create policy "Joined members can reply as themselves" on public.community_comments
  for insert to authenticated with check (
    author_id = (select auth.uid()) and exists (
      select 1 from public.community_posts p
      join public.memberships m on m.hobby_id = p.hobby_id
      where p.id = community_comments.post_id and m.user_id = (select auth.uid())
    )
  );
commit;
