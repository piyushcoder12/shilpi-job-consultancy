-- Shilpi Job Consultancy: multi-admin blog CMS
-- Run this in Supabase SQL Editor. Keep Row Level Security enabled.
create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.blogs (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 140),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  category text not null default 'Career Guidance',
  excerpt text not null check (char_length(excerpt) between 5 and 260),
  content text not null check (char_length(content) >= 20),
  cover_image_url text,
  status text not null default 'draft' check (status in ('draft','published')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists blogs_published_idx on public.blogs(status,published_at desc);
alter table public.admin_users enable row level security;
alter table public.blogs enable row level security;

create or replace function public.is_shilpi_admin() returns boolean
language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.admin_users where user_id=auth.uid()) $$;
revoke all on function public.is_shilpi_admin() from public;
grant execute on function public.is_shilpi_admin() to anon, authenticated;

drop policy if exists "admins can read own admin row" on public.admin_users;
create policy "admins can read own admin row" on public.admin_users for select to authenticated using (user_id=auth.uid());
drop policy if exists "public can read published blogs" on public.blogs;
create policy "public can read published blogs" on public.blogs for select to anon, authenticated using (status='published');
drop policy if exists "admins can read all blogs" on public.blogs;
create policy "admins can read all blogs" on public.blogs for select to authenticated using (public.is_shilpi_admin());
drop policy if exists "admins can insert blogs" on public.blogs;
create policy "admins can insert blogs" on public.blogs for insert to authenticated with check (public.is_shilpi_admin());
drop policy if exists "admins can update blogs" on public.blogs;
create policy "admins can update blogs" on public.blogs for update to authenticated using (public.is_shilpi_admin()) with check (public.is_shilpi_admin());
drop policy if exists "admins can delete blogs" on public.blogs;
create policy "admins can delete blogs" on public.blogs for delete to authenticated using (public.is_shilpi_admin());

-- Public cover images; only an authenticated admin may upload, update or delete.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('blog-covers','blog-covers',true,3145728,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true,file_size_limit=3145728,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "public can view blog covers" on storage.objects;
create policy "public can view blog covers" on storage.objects for select to anon,authenticated using (bucket_id='blog-covers');
drop policy if exists "admin can upload blog covers" on storage.objects;
create policy "admin can upload blog covers" on storage.objects for insert to authenticated with check (bucket_id='blog-covers' and public.is_shilpi_admin());
drop policy if exists "admin can update blog covers" on storage.objects;
create policy "admin can update blog covers" on storage.objects for update to authenticated using (bucket_id='blog-covers' and public.is_shilpi_admin()) with check (bucket_id='blog-covers' and public.is_shilpi_admin());
drop policy if exists "admin can delete blog covers" on storage.objects;
create policy "admin can delete blog covers" on storage.objects for delete to authenticated using (bucket_id='blog-covers' and public.is_shilpi_admin());

-- MULTIPLE ADMIN SETUP:
-- 1) In Supabase Dashboard > Authentication > Users, invite/create each admin account.
-- 2) Copy each invited user's UUID. Run one insert per person, for example:
-- insert into public.admin_users(user_id, display_name) values
-- ('PASTE-FIRST-USER-UUID-HERE', 'Owner'),
-- ('PASTE-SECOND-USER-UUID-HERE', 'Content Admin');
-- Repeat for every approved admin. All rows in admin_users can manage blogs.
-- Do not enable public sign-ups. Only trusted people should be added here.
