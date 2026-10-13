-- Deutsch Freunde B2 : à coller dans Supabase > SQL Editor > Run
create table if not exists profiles(id uuid primary key references auth.users on delete cascade,name text,level text default 'B2');
create table if not exists groups(id uuid primary key default gen_random_uuid(),name text not null,code text unique not null default substr(md5(random()::text||clock_timestamp()::text),1,6),owner uuid default auth.uid(),created_at timestamptz default now());
create table if not exists members(group_id uuid references groups on delete cascade,user_id uuid references auth.users on delete cascade default auth.uid(),primary key(group_id,user_id));
create table if not exists messages(id bigint generated always as identity primary key,group_id uuid not null references groups on delete cascade,user_id uuid not null default auth.uid() references auth.users,topic text not null,body text not null check(length(body)<=2000),reply_to bigint,created_at timestamptz default now());
create table if not exists progress(user_id uuid default auth.uid() references auth.users on delete cascade,theme_id text,status text default 'cours',notes jsonb default '{}',primary key(user_id,theme_id));
create table if not exists drafts(id bigint generated always as identity primary key,user_id uuid default auth.uid() references auth.users on delete cascade,kind text,body text,created_at timestamptz default now());
create table if not exists vocab(id bigint generated always as identity primary key,user_id uuid default auth.uid() references auth.users on delete cascade,de text not null,fr text not null,syn text,example text,pos text,known boolean default false);

create or replace function is_member(g uuid) returns boolean language sql security definer set search_path=public stable as $$select exists(select 1 from members where group_id=g and user_id=auth.uid())$$;
create or replace function shares_group(u uuid) returns boolean language sql security definer set search_path=public stable as $$select exists(select 1 from members a join members b on a.group_id=b.group_id where a.user_id=auth.uid() and b.user_id=u)$$;
create or replace function create_group(gname text) returns uuid language plpgsql security definer set search_path=public as $$declare gid uuid;begin if auth.uid() is null then raise exception 'non connecté';end if;insert into groups(name,owner) values(left(gname,60),auth.uid()) returning id into gid;insert into members values(gid,auth.uid());return gid;end$$;
create or replace function join_group(gcode text) returns uuid language plpgsql security definer set search_path=public as $$declare gid uuid;begin if auth.uid() is null then raise exception 'non connecté';end if;select id into gid from groups where code=lower(trim(gcode));if gid is null then raise exception 'code inconnu';end if;insert into members values(gid,auth.uid()) on conflict do nothing;return gid;end$$;
create or replace function handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$begin insert into profiles(id,name) values(new.id,coalesce(new.raw_user_meta_data->>'name',split_part(new.email,'@',1)));return new;end$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();

alter table profiles enable row level security;alter table groups enable row level security;alter table members enable row level security;alter table messages enable row level security;alter table progress enable row level security;alter table drafts enable row level security;alter table vocab enable row level security;
create policy p_sel on profiles for select to authenticated using(id=auth.uid() or shares_group(id));
create policy p_upd on profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy g_sel on groups for select to authenticated using(is_member(id));
create policy m_sel on members for select to authenticated using(is_member(group_id));
create policy m_del on members for delete to authenticated using(user_id=auth.uid());
create policy msg_sel on messages for select to authenticated using(is_member(group_id));
create policy msg_ins on messages for insert to authenticated with check(user_id=auth.uid() and is_member(group_id));
create policy msg_del on messages for delete to authenticated using(user_id=auth.uid());
create policy pr_all on progress for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy dr_all on drafts for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy vo_all on vocab for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
revoke execute on function create_group(text),join_group(text) from public,anon;
grant execute on function create_group(text),join_group(text) to authenticated;
alter publication supabase_realtime add table messages;
