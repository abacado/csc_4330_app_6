-- Lets members start their own communities and edit the ones they started.
-- Run once in the Supabase SQL Editor, after 202611040001_community_mvp.sql.
begin;

alter table public.hobbies
  add column tagline text not null default ''
    check (char_length(tagline) <= 80),
  add column icon text not null default 'eco'
    check (icon ~ '^[a-z_]{1,32}$'),
  add column tint integer not null default 5143119 -- 0x4E7A4F
    check (tint between 0 and 16777215),
  add column created_by uuid references public.profiles(id) on delete set null,
  add column created_at timestamptz not null default now();

alter table public.hobbies
  add constraint hobbies_id_format check (id ~ '^[a-z0-9-]{2,60}$'),
  add constraint hobbies_name_length
    check (char_length(trim(name)) between 2 and 40);

-- No two communities share a name, ignoring case and surrounding spaces.
create unique index hobbies_name_unique on public.hobbies (lower(trim(name)));

-- Creating: members may only create communities in their own name.
grant insert (id, name, tagline, icon, tint, created_by)
  on public.hobbies to authenticated;
create policy "Members can start communities" on public.hobbies
  for insert to authenticated
  with check (created_by = (select auth.uid()));

-- Editing: only the creator, and only the descriptive columns.
grant update (name, tagline, icon, tint) on public.hobbies to authenticated;
create policy "Creators can edit their communities" on public.hobbies
  for update to authenticated
  using (created_by = (select auth.uid()))
  with check (created_by = (select auth.uid()));

-- No delete grant: communities stay, so members' posts are never lost.
commit;
